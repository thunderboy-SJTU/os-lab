
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 30 80 00       	mov    0x803000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 b5 00 00 00       	call   800104 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800066:	e8 7f 05 00 00       	call   8005ea <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	89 c2                	mov    %eax,%edx
  800072:	c1 e2 07             	shl    $0x7,%edx
  800075:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80007c:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800081:	85 f6                	test   %esi,%esi
  800083:	7e 07                	jle    80008c <libmain+0x38>
		binaryname = argv[0];
  800085:	8b 03                	mov    (%ebx),%eax
  800087:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	89 34 24             	mov    %esi,(%esp)
  800093:	e8 9c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800098:	e8 0b 00 00 00       	call   8000a8 <exit>
}
  80009d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a3:	89 ec                	mov    %ebp,%esp
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ae:	e8 c8 0a 00 00       	call   800b7b <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 6b 05 00 00       	call   80062a <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	89 1c 24             	mov    %ebx,(%esp)
  8000cd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000db:	89 d1                	mov    %edx,%ecx
  8000dd:	89 d3                	mov    %edx,%ebx
  8000df:	89 d7                	mov    %edx,%edi
  8000e1:	51                   	push   %ecx
  8000e2:	52                   	push   %edx
  8000e3:	53                   	push   %ebx
  8000e4:	54                   	push   %esp
  8000e5:	55                   	push   %ebp
  8000e6:	56                   	push   %esi
  8000e7:	57                   	push   %edi
  8000e8:	54                   	push   %esp
  8000e9:	5d                   	pop    %ebp
  8000ea:	8d 35 f2 00 80 00    	lea    0x8000f2,%esi
  8000f0:	0f 34                	sysenter 
  8000f2:	5f                   	pop    %edi
  8000f3:	5e                   	pop    %esi
  8000f4:	5d                   	pop    %ebp
  8000f5:	5c                   	pop    %esp
  8000f6:	5b                   	pop    %ebx
  8000f7:	5a                   	pop    %edx
  8000f8:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f9:	8b 1c 24             	mov    (%esp),%ebx
  8000fc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800100:	89 ec                	mov    %ebp,%esp
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
  80010a:	89 1c 24             	mov    %ebx,(%esp)
  80010d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800111:	b8 00 00 00 00       	mov    $0x0,%eax
  800116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800119:	8b 55 08             	mov    0x8(%ebp),%edx
  80011c:	89 c3                	mov    %eax,%ebx
  80011e:	89 c7                	mov    %eax,%edi
  800120:	51                   	push   %ecx
  800121:	52                   	push   %edx
  800122:	53                   	push   %ebx
  800123:	54                   	push   %esp
  800124:	55                   	push   %ebp
  800125:	56                   	push   %esi
  800126:	57                   	push   %edi
  800127:	54                   	push   %esp
  800128:	5d                   	pop    %ebp
  800129:	8d 35 31 01 80 00    	lea    0x800131,%esi
  80012f:	0f 34                	sysenter 
  800131:	5f                   	pop    %edi
  800132:	5e                   	pop    %esi
  800133:	5d                   	pop    %ebp
  800134:	5c                   	pop    %esp
  800135:	5b                   	pop    %ebx
  800136:	5a                   	pop    %edx
  800137:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800138:	8b 1c 24             	mov    (%esp),%ebx
  80013b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80013f:	89 ec                	mov    %ebp,%esp
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 08             	sub    $0x8,%esp
  800149:	89 1c 24             	mov    %ebx,(%esp)
  80014c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800150:	b8 10 00 00 00       	mov    $0x10,%eax
  800155:	8b 7d 14             	mov    0x14(%ebp),%edi
  800158:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80015b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015e:	8b 55 08             	mov    0x8(%ebp),%edx
  800161:	51                   	push   %ecx
  800162:	52                   	push   %edx
  800163:	53                   	push   %ebx
  800164:	54                   	push   %esp
  800165:	55                   	push   %ebp
  800166:	56                   	push   %esi
  800167:	57                   	push   %edi
  800168:	54                   	push   %esp
  800169:	5d                   	pop    %ebp
  80016a:	8d 35 72 01 80 00    	lea    0x800172,%esi
  800170:	0f 34                	sysenter 
  800172:	5f                   	pop    %edi
  800173:	5e                   	pop    %esi
  800174:	5d                   	pop    %ebp
  800175:	5c                   	pop    %esp
  800176:	5b                   	pop    %ebx
  800177:	5a                   	pop    %edx
  800178:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800179:	8b 1c 24             	mov    (%esp),%ebx
  80017c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800180:	89 ec                	mov    %ebp,%esp
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 28             	sub    $0x28,%esp
  80018a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80018d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800190:	bb 00 00 00 00       	mov    $0x0,%ebx
  800195:	b8 0f 00 00 00       	mov    $0xf,%eax
  80019a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	89 df                	mov    %ebx,%edi
  8001a2:	51                   	push   %ecx
  8001a3:	52                   	push   %edx
  8001a4:	53                   	push   %ebx
  8001a5:	54                   	push   %esp
  8001a6:	55                   	push   %ebp
  8001a7:	56                   	push   %esi
  8001a8:	57                   	push   %edi
  8001a9:	54                   	push   %esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	8d 35 b3 01 80 00    	lea    0x8001b3,%esi
  8001b1:	0f 34                	sysenter 
  8001b3:	5f                   	pop    %edi
  8001b4:	5e                   	pop    %esi
  8001b5:	5d                   	pop    %ebp
  8001b6:	5c                   	pop    %esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5a                   	pop    %edx
  8001b9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8001ba:	85 c0                	test   %eax,%eax
  8001bc:	7e 28                	jle    8001e6 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c2:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8001c9:	00 
  8001ca:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  8001d1:	00 
  8001d2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  8001e1:	e8 7e 0d 00 00       	call   800f64 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8001e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001ec:	89 ec                	mov    %ebp,%esp
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    

008001f0 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	89 1c 24             	mov    %ebx,(%esp)
  8001f9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800202:	b8 11 00 00 00       	mov    $0x11,%eax
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	89 cb                	mov    %ecx,%ebx
  80020c:	89 cf                	mov    %ecx,%edi
  80020e:	51                   	push   %ecx
  80020f:	52                   	push   %edx
  800210:	53                   	push   %ebx
  800211:	54                   	push   %esp
  800212:	55                   	push   %ebp
  800213:	56                   	push   %esi
  800214:	57                   	push   %edi
  800215:	54                   	push   %esp
  800216:	5d                   	pop    %ebp
  800217:	8d 35 1f 02 80 00    	lea    0x80021f,%esi
  80021d:	0f 34                	sysenter 
  80021f:	5f                   	pop    %edi
  800220:	5e                   	pop    %esi
  800221:	5d                   	pop    %ebp
  800222:	5c                   	pop    %esp
  800223:	5b                   	pop    %ebx
  800224:	5a                   	pop    %edx
  800225:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800226:	8b 1c 24             	mov    (%esp),%ebx
  800229:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80022d:	89 ec                	mov    %ebp,%esp
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 28             	sub    $0x28,%esp
  800237:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80023a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80023d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800242:	b8 0e 00 00 00       	mov    $0xe,%eax
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 cb                	mov    %ecx,%ebx
  80024c:	89 cf                	mov    %ecx,%edi
  80024e:	51                   	push   %ecx
  80024f:	52                   	push   %edx
  800250:	53                   	push   %ebx
  800251:	54                   	push   %esp
  800252:	55                   	push   %ebp
  800253:	56                   	push   %esi
  800254:	57                   	push   %edi
  800255:	54                   	push   %esp
  800256:	5d                   	pop    %ebp
  800257:	8d 35 5f 02 80 00    	lea    0x80025f,%esi
  80025d:	0f 34                	sysenter 
  80025f:	5f                   	pop    %edi
  800260:	5e                   	pop    %esi
  800261:	5d                   	pop    %ebp
  800262:	5c                   	pop    %esp
  800263:	5b                   	pop    %ebx
  800264:	5a                   	pop    %edx
  800265:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800266:	85 c0                	test   %eax,%eax
  800268:	7e 28                	jle    800292 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80026e:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800275:	00 
  800276:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  80027d:	00 
  80027e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800285:	00 
  800286:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  80028d:	e8 d2 0c 00 00       	call   800f64 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800292:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800295:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800298:	89 ec                	mov    %ebp,%esp
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    

0080029c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	89 1c 24             	mov    %ebx,(%esp)
  8002a5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002a9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	51                   	push   %ecx
  8002bb:	52                   	push   %edx
  8002bc:	53                   	push   %ebx
  8002bd:	54                   	push   %esp
  8002be:	55                   	push   %ebp
  8002bf:	56                   	push   %esi
  8002c0:	57                   	push   %edi
  8002c1:	54                   	push   %esp
  8002c2:	5d                   	pop    %ebp
  8002c3:	8d 35 cb 02 80 00    	lea    0x8002cb,%esi
  8002c9:	0f 34                	sysenter 
  8002cb:	5f                   	pop    %edi
  8002cc:	5e                   	pop    %esi
  8002cd:	5d                   	pop    %ebp
  8002ce:	5c                   	pop    %esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5a                   	pop    %edx
  8002d1:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d2:	8b 1c 24             	mov    (%esp),%ebx
  8002d5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002d9:	89 ec                	mov    %ebp,%esp
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 28             	sub    $0x28,%esp
  8002e3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002e6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ee:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	89 df                	mov    %ebx,%edi
  8002fb:	51                   	push   %ecx
  8002fc:	52                   	push   %edx
  8002fd:	53                   	push   %ebx
  8002fe:	54                   	push   %esp
  8002ff:	55                   	push   %ebp
  800300:	56                   	push   %esi
  800301:	57                   	push   %edi
  800302:	54                   	push   %esp
  800303:	5d                   	pop    %ebp
  800304:	8d 35 0c 03 80 00    	lea    0x80030c,%esi
  80030a:	0f 34                	sysenter 
  80030c:	5f                   	pop    %edi
  80030d:	5e                   	pop    %esi
  80030e:	5d                   	pop    %ebp
  80030f:	5c                   	pop    %esp
  800310:	5b                   	pop    %ebx
  800311:	5a                   	pop    %edx
  800312:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800313:	85 c0                	test   %eax,%eax
  800315:	7e 28                	jle    80033f <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800317:	89 44 24 10          	mov    %eax,0x10(%esp)
  80031b:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  800322:	00 
  800323:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  80032a:	00 
  80032b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800332:	00 
  800333:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  80033a:	e8 25 0c 00 00       	call   800f64 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80033f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800342:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800345:	89 ec                	mov    %ebp,%esp
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 28             	sub    $0x28,%esp
  80034f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800352:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800355:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80035f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800362:	8b 55 08             	mov    0x8(%ebp),%edx
  800365:	89 df                	mov    %ebx,%edi
  800367:	51                   	push   %ecx
  800368:	52                   	push   %edx
  800369:	53                   	push   %ebx
  80036a:	54                   	push   %esp
  80036b:	55                   	push   %ebp
  80036c:	56                   	push   %esi
  80036d:	57                   	push   %edi
  80036e:	54                   	push   %esp
  80036f:	5d                   	pop    %ebp
  800370:	8d 35 78 03 80 00    	lea    0x800378,%esi
  800376:	0f 34                	sysenter 
  800378:	5f                   	pop    %edi
  800379:	5e                   	pop    %esi
  80037a:	5d                   	pop    %ebp
  80037b:	5c                   	pop    %esp
  80037c:	5b                   	pop    %ebx
  80037d:	5a                   	pop    %edx
  80037e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80037f:	85 c0                	test   %eax,%eax
  800381:	7e 28                	jle    8003ab <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800383:	89 44 24 10          	mov    %eax,0x10(%esp)
  800387:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80038e:	00 
  80038f:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  800396:	00 
  800397:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80039e:	00 
  80039f:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  8003a6:	e8 b9 0b 00 00       	call   800f64 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003ab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003b1:	89 ec                	mov    %ebp,%esp
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	83 ec 28             	sub    $0x28,%esp
  8003bb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003be:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c6:	b8 09 00 00 00       	mov    $0x9,%eax
  8003cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d1:	89 df                	mov    %ebx,%edi
  8003d3:	51                   	push   %ecx
  8003d4:	52                   	push   %edx
  8003d5:	53                   	push   %ebx
  8003d6:	54                   	push   %esp
  8003d7:	55                   	push   %ebp
  8003d8:	56                   	push   %esi
  8003d9:	57                   	push   %edi
  8003da:	54                   	push   %esp
  8003db:	5d                   	pop    %ebp
  8003dc:	8d 35 e4 03 80 00    	lea    0x8003e4,%esi
  8003e2:	0f 34                	sysenter 
  8003e4:	5f                   	pop    %edi
  8003e5:	5e                   	pop    %esi
  8003e6:	5d                   	pop    %ebp
  8003e7:	5c                   	pop    %esp
  8003e8:	5b                   	pop    %ebx
  8003e9:	5a                   	pop    %edx
  8003ea:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	7e 28                	jle    800417 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003fa:	00 
  8003fb:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  800402:	00 
  800403:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80040a:	00 
  80040b:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  800412:	e8 4d 0b 00 00       	call   800f64 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800417:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80041a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80041d:	89 ec                	mov    %ebp,%esp
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 28             	sub    $0x28,%esp
  800427:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80042a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	b8 07 00 00 00       	mov    $0x7,%eax
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	8b 55 08             	mov    0x8(%ebp),%edx
  80043d:	89 df                	mov    %ebx,%edi
  80043f:	51                   	push   %ecx
  800440:	52                   	push   %edx
  800441:	53                   	push   %ebx
  800442:	54                   	push   %esp
  800443:	55                   	push   %ebp
  800444:	56                   	push   %esi
  800445:	57                   	push   %edi
  800446:	54                   	push   %esp
  800447:	5d                   	pop    %ebp
  800448:	8d 35 50 04 80 00    	lea    0x800450,%esi
  80044e:	0f 34                	sysenter 
  800450:	5f                   	pop    %edi
  800451:	5e                   	pop    %esi
  800452:	5d                   	pop    %ebp
  800453:	5c                   	pop    %esp
  800454:	5b                   	pop    %ebx
  800455:	5a                   	pop    %edx
  800456:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800457:	85 c0                	test   %eax,%eax
  800459:	7e 28                	jle    800483 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80045b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80045f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800466:	00 
  800467:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  80047e:	e8 e1 0a 00 00       	call   800f64 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800483:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800486:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800489:	89 ec                	mov    %ebp,%esp
  80048b:	5d                   	pop    %ebp
  80048c:	c3                   	ret    

0080048d <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	83 ec 28             	sub    $0x28,%esp
  800493:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800496:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800499:	8b 7d 18             	mov    0x18(%ebp),%edi
  80049c:	0b 7d 14             	or     0x14(%ebp),%edi
  80049f:	b8 06 00 00 00       	mov    $0x6,%eax
  8004a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ad:	51                   	push   %ecx
  8004ae:	52                   	push   %edx
  8004af:	53                   	push   %ebx
  8004b0:	54                   	push   %esp
  8004b1:	55                   	push   %ebp
  8004b2:	56                   	push   %esi
  8004b3:	57                   	push   %edi
  8004b4:	54                   	push   %esp
  8004b5:	5d                   	pop    %ebp
  8004b6:	8d 35 be 04 80 00    	lea    0x8004be,%esi
  8004bc:	0f 34                	sysenter 
  8004be:	5f                   	pop    %edi
  8004bf:	5e                   	pop    %esi
  8004c0:	5d                   	pop    %ebp
  8004c1:	5c                   	pop    %esp
  8004c2:	5b                   	pop    %ebx
  8004c3:	5a                   	pop    %edx
  8004c4:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	7e 28                	jle    8004f1 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004cd:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8004d4:	00 
  8004d5:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  8004dc:	00 
  8004dd:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004e4:	00 
  8004e5:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  8004ec:	e8 73 0a 00 00       	call   800f64 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8004f1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004f7:	89 ec                	mov    %ebp,%esp
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 28             	sub    $0x28,%esp
  800501:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800504:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800507:	bf 00 00 00 00       	mov    $0x0,%edi
  80050c:	b8 05 00 00 00       	mov    $0x5,%eax
  800511:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800514:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800517:	8b 55 08             	mov    0x8(%ebp),%edx
  80051a:	51                   	push   %ecx
  80051b:	52                   	push   %edx
  80051c:	53                   	push   %ebx
  80051d:	54                   	push   %esp
  80051e:	55                   	push   %ebp
  80051f:	56                   	push   %esi
  800520:	57                   	push   %edi
  800521:	54                   	push   %esp
  800522:	5d                   	pop    %ebp
  800523:	8d 35 2b 05 80 00    	lea    0x80052b,%esi
  800529:	0f 34                	sysenter 
  80052b:	5f                   	pop    %edi
  80052c:	5e                   	pop    %esi
  80052d:	5d                   	pop    %ebp
  80052e:	5c                   	pop    %esp
  80052f:	5b                   	pop    %ebx
  800530:	5a                   	pop    %edx
  800531:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800532:	85 c0                	test   %eax,%eax
  800534:	7e 28                	jle    80055e <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800536:	89 44 24 10          	mov    %eax,0x10(%esp)
  80053a:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800541:	00 
  800542:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  800549:	00 
  80054a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800551:	00 
  800552:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  800559:	e8 06 0a 00 00       	call   800f64 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80055e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800561:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800564:	89 ec                	mov    %ebp,%esp
  800566:	5d                   	pop    %ebp
  800567:	c3                   	ret    

00800568 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	89 1c 24             	mov    %ebx,(%esp)
  800571:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800575:	ba 00 00 00 00       	mov    $0x0,%edx
  80057a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80057f:	89 d1                	mov    %edx,%ecx
  800581:	89 d3                	mov    %edx,%ebx
  800583:	89 d7                	mov    %edx,%edi
  800585:	51                   	push   %ecx
  800586:	52                   	push   %edx
  800587:	53                   	push   %ebx
  800588:	54                   	push   %esp
  800589:	55                   	push   %ebp
  80058a:	56                   	push   %esi
  80058b:	57                   	push   %edi
  80058c:	54                   	push   %esp
  80058d:	5d                   	pop    %ebp
  80058e:	8d 35 96 05 80 00    	lea    0x800596,%esi
  800594:	0f 34                	sysenter 
  800596:	5f                   	pop    %edi
  800597:	5e                   	pop    %esi
  800598:	5d                   	pop    %ebp
  800599:	5c                   	pop    %esp
  80059a:	5b                   	pop    %ebx
  80059b:	5a                   	pop    %edx
  80059c:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80059d:	8b 1c 24             	mov    (%esp),%ebx
  8005a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005a4:	89 ec                	mov    %ebp,%esp
  8005a6:	5d                   	pop    %ebp
  8005a7:	c3                   	ret    

008005a8 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	89 1c 24             	mov    %ebx,(%esp)
  8005b1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ba:	b8 04 00 00 00       	mov    $0x4,%eax
  8005bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c5:	89 df                	mov    %ebx,%edi
  8005c7:	51                   	push   %ecx
  8005c8:	52                   	push   %edx
  8005c9:	53                   	push   %ebx
  8005ca:	54                   	push   %esp
  8005cb:	55                   	push   %ebp
  8005cc:	56                   	push   %esi
  8005cd:	57                   	push   %edi
  8005ce:	54                   	push   %esp
  8005cf:	5d                   	pop    %ebp
  8005d0:	8d 35 d8 05 80 00    	lea    0x8005d8,%esi
  8005d6:	0f 34                	sysenter 
  8005d8:	5f                   	pop    %edi
  8005d9:	5e                   	pop    %esi
  8005da:	5d                   	pop    %ebp
  8005db:	5c                   	pop    %esp
  8005dc:	5b                   	pop    %ebx
  8005dd:	5a                   	pop    %edx
  8005de:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8005df:	8b 1c 24             	mov    (%esp),%ebx
  8005e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005e6:	89 ec                	mov    %ebp,%esp
  8005e8:	5d                   	pop    %ebp
  8005e9:	c3                   	ret    

008005ea <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8005ea:	55                   	push   %ebp
  8005eb:	89 e5                	mov    %esp,%ebp
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	89 1c 24             	mov    %ebx,(%esp)
  8005f3:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fc:	b8 02 00 00 00       	mov    $0x2,%eax
  800601:	89 d1                	mov    %edx,%ecx
  800603:	89 d3                	mov    %edx,%ebx
  800605:	89 d7                	mov    %edx,%edi
  800607:	51                   	push   %ecx
  800608:	52                   	push   %edx
  800609:	53                   	push   %ebx
  80060a:	54                   	push   %esp
  80060b:	55                   	push   %ebp
  80060c:	56                   	push   %esi
  80060d:	57                   	push   %edi
  80060e:	54                   	push   %esp
  80060f:	5d                   	pop    %ebp
  800610:	8d 35 18 06 80 00    	lea    0x800618,%esi
  800616:	0f 34                	sysenter 
  800618:	5f                   	pop    %edi
  800619:	5e                   	pop    %esi
  80061a:	5d                   	pop    %ebp
  80061b:	5c                   	pop    %esp
  80061c:	5b                   	pop    %ebx
  80061d:	5a                   	pop    %edx
  80061e:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80061f:	8b 1c 24             	mov    (%esp),%ebx
  800622:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800626:	89 ec                	mov    %ebp,%esp
  800628:	5d                   	pop    %ebp
  800629:	c3                   	ret    

0080062a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
  80062d:	83 ec 28             	sub    $0x28,%esp
  800630:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800633:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063b:	b8 03 00 00 00       	mov    $0x3,%eax
  800640:	8b 55 08             	mov    0x8(%ebp),%edx
  800643:	89 cb                	mov    %ecx,%ebx
  800645:	89 cf                	mov    %ecx,%edi
  800647:	51                   	push   %ecx
  800648:	52                   	push   %edx
  800649:	53                   	push   %ebx
  80064a:	54                   	push   %esp
  80064b:	55                   	push   %ebp
  80064c:	56                   	push   %esi
  80064d:	57                   	push   %edi
  80064e:	54                   	push   %esp
  80064f:	5d                   	pop    %ebp
  800650:	8d 35 58 06 80 00    	lea    0x800658,%esi
  800656:	0f 34                	sysenter 
  800658:	5f                   	pop    %edi
  800659:	5e                   	pop    %esi
  80065a:	5d                   	pop    %ebp
  80065b:	5c                   	pop    %esp
  80065c:	5b                   	pop    %ebx
  80065d:	5a                   	pop    %edx
  80065e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80065f:	85 c0                	test   %eax,%eax
  800661:	7e 28                	jle    80068b <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800663:	89 44 24 10          	mov    %eax,0x10(%esp)
  800667:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80066e:	00 
  80066f:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  800676:	00 
  800677:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80067e:	00 
  80067f:	c7 04 24 35 21 80 00 	movl   $0x802135,(%esp)
  800686:	e8 d9 08 00 00       	call   800f64 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80068b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80068e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800691:	89 ec                	mov    %ebp,%esp
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    
	...

008006a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8006ab:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8006ae:	5d                   	pop    %ebp
  8006af:	c3                   	ret    

008006b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b9:	89 04 24             	mov    %eax,(%esp)
  8006bc:	e8 df ff ff ff       	call   8006a0 <fd2num>
  8006c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8006c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8006c9:	c9                   	leave  
  8006ca:	c3                   	ret    

008006cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	57                   	push   %edi
  8006cf:	56                   	push   %esi
  8006d0:	53                   	push   %ebx
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8006d4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8006d9:	a8 01                	test   $0x1,%al
  8006db:	74 36                	je     800713 <fd_alloc+0x48>
  8006dd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8006e2:	a8 01                	test   $0x1,%al
  8006e4:	74 2d                	je     800713 <fd_alloc+0x48>
  8006e6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8006eb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8006f0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8006f5:	89 c3                	mov    %eax,%ebx
  8006f7:	89 c2                	mov    %eax,%edx
  8006f9:	c1 ea 16             	shr    $0x16,%edx
  8006fc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8006ff:	f6 c2 01             	test   $0x1,%dl
  800702:	74 14                	je     800718 <fd_alloc+0x4d>
  800704:	89 c2                	mov    %eax,%edx
  800706:	c1 ea 0c             	shr    $0xc,%edx
  800709:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80070c:	f6 c2 01             	test   $0x1,%dl
  80070f:	75 10                	jne    800721 <fd_alloc+0x56>
  800711:	eb 05                	jmp    800718 <fd_alloc+0x4d>
  800713:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800718:	89 1f                	mov    %ebx,(%edi)
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80071f:	eb 17                	jmp    800738 <fd_alloc+0x6d>
  800721:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800726:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80072b:	75 c8                	jne    8006f5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80072d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800733:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	83 f8 1f             	cmp    $0x1f,%eax
  800746:	77 36                	ja     80077e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800748:	05 00 00 0d 00       	add    $0xd0000,%eax
  80074d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800750:	89 c2                	mov    %eax,%edx
  800752:	c1 ea 16             	shr    $0x16,%edx
  800755:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80075c:	f6 c2 01             	test   $0x1,%dl
  80075f:	74 1d                	je     80077e <fd_lookup+0x41>
  800761:	89 c2                	mov    %eax,%edx
  800763:	c1 ea 0c             	shr    $0xc,%edx
  800766:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80076d:	f6 c2 01             	test   $0x1,%dl
  800770:	74 0c                	je     80077e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
  800775:	89 02                	mov    %eax,(%edx)
  800777:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80077c:	eb 05                	jmp    800783 <fd_lookup+0x46>
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80078e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800792:	8b 45 08             	mov    0x8(%ebp),%eax
  800795:	89 04 24             	mov    %eax,(%esp)
  800798:	e8 a0 ff ff ff       	call   80073d <fd_lookup>
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	56                   	push   %esi
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 10             	sub    $0x10,%esp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8007bf:	b8 08 30 80 00       	mov    $0x803008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8007c4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007c9:	be c0 21 80 00       	mov    $0x8021c0,%esi
		if (devtab[i]->dev_id == dev_id) {
  8007ce:	39 08                	cmp    %ecx,(%eax)
  8007d0:	75 10                	jne    8007e2 <dev_lookup+0x31>
  8007d2:	eb 04                	jmp    8007d8 <dev_lookup+0x27>
  8007d4:	39 08                	cmp    %ecx,(%eax)
  8007d6:	75 0a                	jne    8007e2 <dev_lookup+0x31>
			*dev = devtab[i];
  8007d8:	89 03                	mov    %eax,(%ebx)
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8007df:	90                   	nop
  8007e0:	eb 31                	jmp    800813 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	75 e8                	jne    8007d4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8007f1:	8b 40 48             	mov    0x48(%eax),%eax
  8007f4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fc:	c7 04 24 44 21 80 00 	movl   $0x802144,(%esp)
  800803:	e8 15 08 00 00       	call   80101d <cprintf>
	*dev = 0;
  800808:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80080e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	83 ec 24             	sub    $0x24,%esp
  800821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800824:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	e8 07 ff ff ff       	call   80073d <fd_lookup>
  800836:	85 c0                	test   %eax,%eax
  800838:	78 53                	js     80088d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800841:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800844:	8b 00                	mov    (%eax),%eax
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	e8 63 ff ff ff       	call   8007b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084e:	85 c0                	test   %eax,%eax
  800850:	78 3b                	js     80088d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800852:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800857:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80085e:	74 2d                	je     80088d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800860:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800863:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086a:	00 00 00 
	stat->st_isdir = 0;
  80086d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800874:	00 00 00 
	stat->st_dev = dev;
  800877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800887:	89 14 24             	mov    %edx,(%esp)
  80088a:	ff 50 14             	call   *0x14(%eax)
}
  80088d:	83 c4 24             	add    $0x24,%esp
  800890:	5b                   	pop    %ebx
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	83 ec 24             	sub    $0x24,%esp
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a4:	89 1c 24             	mov    %ebx,(%esp)
  8008a7:	e8 91 fe ff ff       	call   80073d <fd_lookup>
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 5f                	js     80090f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ba:	8b 00                	mov    (%eax),%eax
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	e8 ed fe ff ff       	call   8007b1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	78 47                	js     80090f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008cb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8008cf:	75 23                	jne    8008f4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008d1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008d6:	8b 40 48             	mov    0x48(%eax),%eax
  8008d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e1:	c7 04 24 64 21 80 00 	movl   $0x802164,(%esp)
  8008e8:	e8 30 07 00 00       	call   80101d <cprintf>
  8008ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008f2:	eb 1b                	jmp    80090f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8008f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f7:	8b 48 18             	mov    0x18(%eax),%ecx
  8008fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ff:	85 c9                	test   %ecx,%ecx
  800901:	74 0c                	je     80090f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090a:	89 14 24             	mov    %edx,(%esp)
  80090d:	ff d1                	call   *%ecx
}
  80090f:	83 c4 24             	add    $0x24,%esp
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	53                   	push   %ebx
  800919:	83 ec 24             	sub    $0x24,%esp
  80091c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80091f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800922:	89 44 24 04          	mov    %eax,0x4(%esp)
  800926:	89 1c 24             	mov    %ebx,(%esp)
  800929:	e8 0f fe ff ff       	call   80073d <fd_lookup>
  80092e:	85 c0                	test   %eax,%eax
  800930:	78 66                	js     800998 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800932:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800935:	89 44 24 04          	mov    %eax,0x4(%esp)
  800939:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093c:	8b 00                	mov    (%eax),%eax
  80093e:	89 04 24             	mov    %eax,(%esp)
  800941:	e8 6b fe ff ff       	call   8007b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800946:	85 c0                	test   %eax,%eax
  800948:	78 4e                	js     800998 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80094a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80094d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800951:	75 23                	jne    800976 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800953:	a1 04 40 80 00       	mov    0x804004,%eax
  800958:	8b 40 48             	mov    0x48(%eax),%eax
  80095b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80095f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800963:	c7 04 24 85 21 80 00 	movl   $0x802185,(%esp)
  80096a:	e8 ae 06 00 00       	call   80101d <cprintf>
  80096f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800974:	eb 22                	jmp    800998 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800976:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800979:	8b 48 0c             	mov    0xc(%eax),%ecx
  80097c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800981:	85 c9                	test   %ecx,%ecx
  800983:	74 13                	je     800998 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800985:	8b 45 10             	mov    0x10(%ebp),%eax
  800988:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800993:	89 14 24             	mov    %edx,(%esp)
  800996:	ff d1                	call   *%ecx
}
  800998:	83 c4 24             	add    $0x24,%esp
  80099b:	5b                   	pop    %ebx
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 24             	sub    $0x24,%esp
  8009a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009af:	89 1c 24             	mov    %ebx,(%esp)
  8009b2:	e8 86 fd ff ff       	call   80073d <fd_lookup>
  8009b7:	85 c0                	test   %eax,%eax
  8009b9:	78 6b                	js     800a26 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009c5:	8b 00                	mov    (%eax),%eax
  8009c7:	89 04 24             	mov    %eax,(%esp)
  8009ca:	e8 e2 fd ff ff       	call   8007b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009cf:	85 c0                	test   %eax,%eax
  8009d1:	78 53                	js     800a26 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009d6:	8b 42 08             	mov    0x8(%edx),%eax
  8009d9:	83 e0 03             	and    $0x3,%eax
  8009dc:	83 f8 01             	cmp    $0x1,%eax
  8009df:	75 23                	jne    800a04 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8009e6:	8b 40 48             	mov    0x48(%eax),%eax
  8009e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f1:	c7 04 24 a2 21 80 00 	movl   $0x8021a2,(%esp)
  8009f8:	e8 20 06 00 00       	call   80101d <cprintf>
  8009fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800a02:	eb 22                	jmp    800a26 <read+0x88>
	}
	if (!dev->dev_read)
  800a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a07:	8b 48 08             	mov    0x8(%eax),%ecx
  800a0a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a0f:	85 c9                	test   %ecx,%ecx
  800a11:	74 13                	je     800a26 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a13:	8b 45 10             	mov    0x10(%ebp),%eax
  800a16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	89 14 24             	mov    %edx,(%esp)
  800a24:	ff d1                	call   *%ecx
}
  800a26:	83 c4 24             	add    $0x24,%esp
  800a29:	5b                   	pop    %ebx
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	83 ec 1c             	sub    $0x1c,%esp
  800a35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a38:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	85 f6                	test   %esi,%esi
  800a4c:	74 29                	je     800a77 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a4e:	89 f0                	mov    %esi,%eax
  800a50:	29 d0                	sub    %edx,%eax
  800a52:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a56:	03 55 0c             	add    0xc(%ebp),%edx
  800a59:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a5d:	89 3c 24             	mov    %edi,(%esp)
  800a60:	e8 39 ff ff ff       	call   80099e <read>
		if (m < 0)
  800a65:	85 c0                	test   %eax,%eax
  800a67:	78 0e                	js     800a77 <readn+0x4b>
			return m;
		if (m == 0)
  800a69:	85 c0                	test   %eax,%eax
  800a6b:	74 08                	je     800a75 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a6d:	01 c3                	add    %eax,%ebx
  800a6f:	89 da                	mov    %ebx,%edx
  800a71:	39 f3                	cmp    %esi,%ebx
  800a73:	72 d9                	jb     800a4e <readn+0x22>
  800a75:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a77:	83 c4 1c             	add    $0x1c,%esp
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	83 ec 20             	sub    $0x20,%esp
  800a87:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a8a:	89 34 24             	mov    %esi,(%esp)
  800a8d:	e8 0e fc ff ff       	call   8006a0 <fd2num>
  800a92:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800a95:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a99:	89 04 24             	mov    %eax,(%esp)
  800a9c:	e8 9c fc ff ff       	call   80073d <fd_lookup>
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	78 05                	js     800aac <fd_close+0x2d>
  800aa7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800aaa:	74 0c                	je     800ab8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800aac:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800ab0:	19 c0                	sbb    %eax,%eax
  800ab2:	f7 d0                	not    %eax
  800ab4:	21 c3                	and    %eax,%ebx
  800ab6:	eb 3d                	jmp    800af5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ab8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800abb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abf:	8b 06                	mov    (%esi),%eax
  800ac1:	89 04 24             	mov    %eax,(%esp)
  800ac4:	e8 e8 fc ff ff       	call   8007b1 <dev_lookup>
  800ac9:	89 c3                	mov    %eax,%ebx
  800acb:	85 c0                	test   %eax,%eax
  800acd:	78 16                	js     800ae5 <fd_close+0x66>
		if (dev->dev_close)
  800acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad2:	8b 40 10             	mov    0x10(%eax),%eax
  800ad5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ada:	85 c0                	test   %eax,%eax
  800adc:	74 07                	je     800ae5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800ade:	89 34 24             	mov    %esi,(%esp)
  800ae1:	ff d0                	call   *%eax
  800ae3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ae5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ae9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800af0:	e8 2c f9 ff ff       	call   800421 <sys_page_unmap>
	return r;
}
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	83 c4 20             	add    $0x20,%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	89 04 24             	mov    %eax,(%esp)
  800b11:	e8 27 fc ff ff       	call   80073d <fd_lookup>
  800b16:	85 c0                	test   %eax,%eax
  800b18:	78 13                	js     800b2d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800b1a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800b21:	00 
  800b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b25:	89 04 24             	mov    %eax,(%esp)
  800b28:	e8 52 ff ff ff       	call   800a7f <fd_close>
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	83 ec 18             	sub    $0x18,%esp
  800b35:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b38:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b42:	00 
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	e8 79 03 00 00       	call   800ec7 <open>
  800b4e:	89 c3                	mov    %eax,%ebx
  800b50:	85 c0                	test   %eax,%eax
  800b52:	78 1b                	js     800b6f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5b:	89 1c 24             	mov    %ebx,(%esp)
  800b5e:	e8 b7 fc ff ff       	call   80081a <fstat>
  800b63:	89 c6                	mov    %eax,%esi
	close(fd);
  800b65:	89 1c 24             	mov    %ebx,(%esp)
  800b68:	e8 91 ff ff ff       	call   800afe <close>
  800b6d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800b6f:	89 d8                	mov    %ebx,%eax
  800b71:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b74:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b77:	89 ec                	mov    %ebp,%esp
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 14             	sub    $0x14,%esp
  800b82:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800b87:	89 1c 24             	mov    %ebx,(%esp)
  800b8a:	e8 6f ff ff ff       	call   800afe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b8f:	83 c3 01             	add    $0x1,%ebx
  800b92:	83 fb 20             	cmp    $0x20,%ebx
  800b95:	75 f0                	jne    800b87 <close_all+0xc>
		close(i);
}
  800b97:	83 c4 14             	add    $0x14,%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	83 ec 58             	sub    $0x58,%esp
  800ba3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ba6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ba9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bac:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800baf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	89 04 24             	mov    %eax,(%esp)
  800bbc:	e8 7c fb ff ff       	call   80073d <fd_lookup>
  800bc1:	89 c3                	mov    %eax,%ebx
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	0f 88 e0 00 00 00    	js     800cab <dup+0x10e>
		return r;
	close(newfdnum);
  800bcb:	89 3c 24             	mov    %edi,(%esp)
  800bce:	e8 2b ff ff ff       	call   800afe <close>

	newfd = INDEX2FD(newfdnum);
  800bd3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800bd9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800bdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bdf:	89 04 24             	mov    %eax,(%esp)
  800be2:	e8 c9 fa ff ff       	call   8006b0 <fd2data>
  800be7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800be9:	89 34 24             	mov    %esi,(%esp)
  800bec:	e8 bf fa ff ff       	call   8006b0 <fd2data>
  800bf1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800bf4:	89 da                	mov    %ebx,%edx
  800bf6:	89 d8                	mov    %ebx,%eax
  800bf8:	c1 e8 16             	shr    $0x16,%eax
  800bfb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800c02:	a8 01                	test   $0x1,%al
  800c04:	74 43                	je     800c49 <dup+0xac>
  800c06:	c1 ea 0c             	shr    $0xc,%edx
  800c09:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c10:	a8 01                	test   $0x1,%al
  800c12:	74 35                	je     800c49 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800c14:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c1b:	25 07 0e 00 00       	and    $0xe07,%eax
  800c20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c32:	00 
  800c33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c3e:	e8 4a f8 ff ff       	call   80048d <sys_page_map>
  800c43:	89 c3                	mov    %eax,%ebx
  800c45:	85 c0                	test   %eax,%eax
  800c47:	78 3f                	js     800c88 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c4c:	89 c2                	mov    %eax,%edx
  800c4e:	c1 ea 0c             	shr    $0xc,%edx
  800c51:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800c58:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800c5e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c62:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c6d:	00 
  800c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c79:	e8 0f f8 ff ff       	call   80048d <sys_page_map>
  800c7e:	89 c3                	mov    %eax,%ebx
  800c80:	85 c0                	test   %eax,%eax
  800c82:	78 04                	js     800c88 <dup+0xeb>
  800c84:	89 fb                	mov    %edi,%ebx
  800c86:	eb 23                	jmp    800cab <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c88:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c93:	e8 89 f7 ff ff       	call   800421 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ca6:	e8 76 f7 ff ff       	call   800421 <sys_page_unmap>
	return r;
}
  800cab:	89 d8                	mov    %ebx,%eax
  800cad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb6:	89 ec                	mov    %ebp,%esp
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    
	...

00800cbc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 18             	sub    $0x18,%esp
  800cc2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800cc5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800cc8:	89 c3                	mov    %eax,%ebx
  800cca:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800ccc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cd3:	75 11                	jne    800ce6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cd5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800cdc:	e8 5f 10 00 00       	call   801d40 <ipc_find_env>
  800ce1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ce6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ced:	00 
  800cee:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800cf5:	00 
  800cf6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cfa:	a1 00 40 80 00       	mov    0x804000,%eax
  800cff:	89 04 24             	mov    %eax,(%esp)
  800d02:	e8 84 10 00 00       	call   801d8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d0e:	00 
  800d0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d1a:	e8 ea 10 00 00       	call   801e09 <ipc_recv>
}
  800d1f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d22:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d25:	89 ec                	mov    %ebp,%esp
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	8b 40 0c             	mov    0xc(%eax),%eax
  800d35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4c:	e8 6b ff ff ff       	call   800cbc <fsipc>
}
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	8b 40 0c             	mov    0xc(%eax),%eax
  800d5f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d64:	ba 00 00 00 00       	mov    $0x0,%edx
  800d69:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6e:	e8 49 ff ff ff       	call   800cbc <fsipc>
}
  800d73:	c9                   	leave  
  800d74:	c3                   	ret    

00800d75 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 08 00 00 00       	mov    $0x8,%eax
  800d85:	e8 32 ff ff ff       	call   800cbc <fsipc>
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 14             	sub    $0x14,%esp
  800d93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	8b 40 0c             	mov    0xc(%eax),%eax
  800d9c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800da1:	ba 00 00 00 00       	mov    $0x0,%edx
  800da6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dab:	e8 0c ff ff ff       	call   800cbc <fsipc>
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 2b                	js     800ddf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800db4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800dbb:	00 
  800dbc:	89 1c 24             	mov    %ebx,(%esp)
  800dbf:	e8 86 0b 00 00       	call   80194a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800dc4:	a1 80 50 80 00       	mov    0x805080,%eax
  800dc9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dcf:	a1 84 50 80 00       	mov    0x805084,%eax
  800dd4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800ddf:	83 c4 14             	add    $0x14,%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 18             	sub    $0x18,%esp
  800deb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dee:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800df3:	76 05                	jbe    800dfa <devfile_write+0x15>
  800df5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	8b 52 0c             	mov    0xc(%edx),%edx
  800e00:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800e06:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800e0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e16:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800e1d:	e8 13 0d 00 00       	call   801b35 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800e22:	ba 00 00 00 00       	mov    $0x0,%edx
  800e27:	b8 04 00 00 00       	mov    $0x4,%eax
  800e2c:	e8 8b fe ff ff       	call   800cbc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800e31:	c9                   	leave  
  800e32:	c3                   	ret    

00800e33 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	53                   	push   %ebx
  800e37:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e40:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800e45:	8b 45 10             	mov    0x10(%ebp),%eax
  800e48:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  800e4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e52:	b8 03 00 00 00       	mov    $0x3,%eax
  800e57:	e8 60 fe ff ff       	call   800cbc <fsipc>
  800e5c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	78 17                	js     800e79 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800e62:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e66:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800e6d:	00 
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	89 04 24             	mov    %eax,(%esp)
  800e74:	e8 bc 0c 00 00       	call   801b35 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800e79:	89 d8                	mov    %ebx,%eax
  800e7b:	83 c4 14             	add    $0x14,%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	53                   	push   %ebx
  800e85:	83 ec 14             	sub    $0x14,%esp
  800e88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800e8b:	89 1c 24             	mov    %ebx,(%esp)
  800e8e:	e8 6d 0a 00 00       	call   801900 <strlen>
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800e9a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800ea0:	7f 1f                	jg     800ec1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800ea2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ea6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800ead:	e8 98 0a 00 00       	call   80194a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb7:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebc:	e8 fb fd ff ff       	call   800cbc <fsipc>
}
  800ec1:	83 c4 14             	add    $0x14,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 28             	sub    $0x28,%esp
  800ecd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ed0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800ed3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  800ed6:	89 34 24             	mov    %esi,(%esp)
  800ed9:	e8 22 0a 00 00       	call   801900 <strlen>
  800ede:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800ee3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ee8:	7f 6d                	jg     800f57 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  800eea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eed:	89 04 24             	mov    %eax,(%esp)
  800ef0:	e8 d6 f7 ff ff       	call   8006cb <fd_alloc>
  800ef5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	78 5c                	js     800f57 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  800efb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efe:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  800f03:	89 34 24             	mov    %esi,(%esp)
  800f06:	e8 f5 09 00 00       	call   801900 <strlen>
  800f0b:	83 c0 01             	add    $0x1,%eax
  800f0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f12:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f16:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800f1d:	e8 13 0c 00 00       	call   801b35 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  800f22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f25:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2a:	e8 8d fd ff ff       	call   800cbc <fsipc>
  800f2f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  800f31:	85 c0                	test   %eax,%eax
  800f33:	79 15                	jns    800f4a <open+0x83>
             fd_close(fd,0);
  800f35:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f3c:	00 
  800f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f40:	89 04 24             	mov    %eax,(%esp)
  800f43:	e8 37 fb ff ff       	call   800a7f <fd_close>
             return r;
  800f48:	eb 0d                	jmp    800f57 <open+0x90>
        }
        return fd2num(fd);
  800f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4d:	89 04 24             	mov    %eax,(%esp)
  800f50:	e8 4b f7 ff ff       	call   8006a0 <fd2num>
  800f55:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  800f57:	89 d8                	mov    %ebx,%eax
  800f59:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f5c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800f5f:	89 ec                	mov    %ebp,%esp
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
	...

00800f64 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f6c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f6f:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800f75:	e8 70 f6 ff ff       	call   8005ea <sys_getenvid>
  800f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f90:	c7 04 24 c8 21 80 00 	movl   $0x8021c8,(%esp)
  800f97:	e8 81 00 00 00       	call   80101d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f9c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa3:	89 04 24             	mov    %eax,(%esp)
  800fa6:	e8 11 00 00 00       	call   800fbc <vcprintf>
	cprintf("\n");
  800fab:	c7 04 24 0c 21 80 00 	movl   $0x80210c,(%esp)
  800fb2:	e8 66 00 00 00       	call   80101d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fb7:	cc                   	int3   
  800fb8:	eb fd                	jmp    800fb7 <_panic+0x53>
	...

00800fbc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800fc5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800fcc:	00 00 00 
	b.cnt = 0;
  800fcf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800fd6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fe0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800fed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff1:	c7 04 24 37 10 80 00 	movl   $0x801037,(%esp)
  800ff8:	e8 cf 01 00 00       	call   8011cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ffd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801003:	89 44 24 04          	mov    %eax,0x4(%esp)
  801007:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	e8 ef f0 ff ff       	call   800104 <sys_cputs>

	return b.cnt;
}
  801015:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801023:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801026:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	89 04 24             	mov    %eax,(%esp)
  801030:	e8 87 ff ff ff       	call   800fbc <vcprintf>
	va_end(ap);

	return cnt;
}
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	53                   	push   %ebx
  80103b:	83 ec 14             	sub    $0x14,%esp
  80103e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801041:	8b 03                	mov    (%ebx),%eax
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80104a:	83 c0 01             	add    $0x1,%eax
  80104d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80104f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801054:	75 19                	jne    80106f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801056:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80105d:	00 
  80105e:	8d 43 08             	lea    0x8(%ebx),%eax
  801061:	89 04 24             	mov    %eax,(%esp)
  801064:	e8 9b f0 ff ff       	call   800104 <sys_cputs>
		b->idx = 0;
  801069:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80106f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801073:	83 c4 14             	add    $0x14,%esp
  801076:	5b                   	pop    %ebx
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    
  801079:	00 00                	add    %al,(%eax)
  80107b:	00 00                	add    %al,(%eax)
  80107d:	00 00                	add    %al,(%eax)
	...

00801080 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 4c             	sub    $0x4c,%esp
  801089:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80108c:	89 d6                	mov    %edx,%esi
  80108e:	8b 45 08             	mov    0x8(%ebp),%eax
  801091:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801094:	8b 55 0c             	mov    0xc(%ebp),%edx
  801097:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80109a:	8b 45 10             	mov    0x10(%ebp),%eax
  80109d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010a0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8010a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ab:	39 d1                	cmp    %edx,%ecx
  8010ad:	72 07                	jb     8010b6 <printnum_v2+0x36>
  8010af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8010b2:	39 d0                	cmp    %edx,%eax
  8010b4:	77 5f                	ja     801115 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8010b6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8010ba:	83 eb 01             	sub    $0x1,%ebx
  8010bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010c9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8010cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8010d0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8010d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8010d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e1:	00 
  8010e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010e5:	89 04 24             	mov    %eax,(%esp)
  8010e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010ef:	e8 8c 0d 00 00       	call   801e80 <__udivdi3>
  8010f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8010f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8010fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801102:	89 04 24             	mov    %eax,(%esp)
  801105:	89 54 24 04          	mov    %edx,0x4(%esp)
  801109:	89 f2                	mov    %esi,%edx
  80110b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110e:	e8 6d ff ff ff       	call   801080 <printnum_v2>
  801113:	eb 1e                	jmp    801133 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801115:	83 ff 2d             	cmp    $0x2d,%edi
  801118:	74 19                	je     801133 <printnum_v2+0xb3>
		while (--width > 0)
  80111a:	83 eb 01             	sub    $0x1,%ebx
  80111d:	85 db                	test   %ebx,%ebx
  80111f:	90                   	nop
  801120:	7e 11                	jle    801133 <printnum_v2+0xb3>
			putch(padc, putdat);
  801122:	89 74 24 04          	mov    %esi,0x4(%esp)
  801126:	89 3c 24             	mov    %edi,(%esp)
  801129:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80112c:	83 eb 01             	sub    $0x1,%ebx
  80112f:	85 db                	test   %ebx,%ebx
  801131:	7f ef                	jg     801122 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801133:	89 74 24 04          	mov    %esi,0x4(%esp)
  801137:	8b 74 24 04          	mov    0x4(%esp),%esi
  80113b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80113e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801142:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801149:	00 
  80114a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80114d:	89 14 24             	mov    %edx,(%esp)
  801150:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801153:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801157:	e8 54 0e 00 00       	call   801fb0 <__umoddi3>
  80115c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801160:	0f be 80 eb 21 80 00 	movsbl 0x8021eb(%eax),%eax
  801167:	89 04 24             	mov    %eax,(%esp)
  80116a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80116d:	83 c4 4c             	add    $0x4c,%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801178:	83 fa 01             	cmp    $0x1,%edx
  80117b:	7e 0e                	jle    80118b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80117d:	8b 10                	mov    (%eax),%edx
  80117f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801182:	89 08                	mov    %ecx,(%eax)
  801184:	8b 02                	mov    (%edx),%eax
  801186:	8b 52 04             	mov    0x4(%edx),%edx
  801189:	eb 22                	jmp    8011ad <getuint+0x38>
	else if (lflag)
  80118b:	85 d2                	test   %edx,%edx
  80118d:	74 10                	je     80119f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80118f:	8b 10                	mov    (%eax),%edx
  801191:	8d 4a 04             	lea    0x4(%edx),%ecx
  801194:	89 08                	mov    %ecx,(%eax)
  801196:	8b 02                	mov    (%edx),%eax
  801198:	ba 00 00 00 00       	mov    $0x0,%edx
  80119d:	eb 0e                	jmp    8011ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80119f:	8b 10                	mov    (%eax),%edx
  8011a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a4:	89 08                	mov    %ecx,(%eax)
  8011a6:	8b 02                	mov    (%edx),%eax
  8011a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011b9:	8b 10                	mov    (%eax),%edx
  8011bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8011be:	73 0a                	jae    8011ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8011c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c3:	88 0a                	mov    %cl,(%edx)
  8011c5:	83 c2 01             	add    $0x1,%edx
  8011c8:	89 10                	mov    %edx,(%eax)
}
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	57                   	push   %edi
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 6c             	sub    $0x6c,%esp
  8011d5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8011d8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8011df:	eb 1a                	jmp    8011fb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	0f 84 66 06 00 00    	je     80184f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8011e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011f0:	89 04 24             	mov    %eax,(%esp)
  8011f3:	ff 55 08             	call   *0x8(%ebp)
  8011f6:	eb 03                	jmp    8011fb <vprintfmt+0x2f>
  8011f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011fb:	0f b6 07             	movzbl (%edi),%eax
  8011fe:	83 c7 01             	add    $0x1,%edi
  801201:	83 f8 25             	cmp    $0x25,%eax
  801204:	75 db                	jne    8011e1 <vprintfmt+0x15>
  801206:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80120a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80120f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801216:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80121b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801222:	be 00 00 00 00       	mov    $0x0,%esi
  801227:	eb 06                	jmp    80122f <vprintfmt+0x63>
  801229:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80122d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80122f:	0f b6 17             	movzbl (%edi),%edx
  801232:	0f b6 c2             	movzbl %dl,%eax
  801235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801238:	8d 47 01             	lea    0x1(%edi),%eax
  80123b:	83 ea 23             	sub    $0x23,%edx
  80123e:	80 fa 55             	cmp    $0x55,%dl
  801241:	0f 87 60 05 00 00    	ja     8017a7 <vprintfmt+0x5db>
  801247:	0f b6 d2             	movzbl %dl,%edx
  80124a:	ff 24 95 c0 23 80 00 	jmp    *0x8023c0(,%edx,4)
  801251:	b9 01 00 00 00       	mov    $0x1,%ecx
  801256:	eb d5                	jmp    80122d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801258:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80125b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80125e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801261:	8d 7a d0             	lea    -0x30(%edx),%edi
  801264:	83 ff 09             	cmp    $0x9,%edi
  801267:	76 08                	jbe    801271 <vprintfmt+0xa5>
  801269:	eb 40                	jmp    8012ab <vprintfmt+0xdf>
  80126b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80126f:	eb bc                	jmp    80122d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801271:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801274:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  801277:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80127b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80127e:	8d 7a d0             	lea    -0x30(%edx),%edi
  801281:	83 ff 09             	cmp    $0x9,%edi
  801284:	76 eb                	jbe    801271 <vprintfmt+0xa5>
  801286:	eb 23                	jmp    8012ab <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801288:	8b 55 14             	mov    0x14(%ebp),%edx
  80128b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80128e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801291:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  801293:	eb 16                	jmp    8012ab <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  801295:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801298:	c1 fa 1f             	sar    $0x1f,%edx
  80129b:	f7 d2                	not    %edx
  80129d:	21 55 d8             	and    %edx,-0x28(%ebp)
  8012a0:	eb 8b                	jmp    80122d <vprintfmt+0x61>
  8012a2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8012a9:	eb 82                	jmp    80122d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8012ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8012af:	0f 89 78 ff ff ff    	jns    80122d <vprintfmt+0x61>
  8012b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8012b8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8012bb:	e9 6d ff ff ff       	jmp    80122d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012c0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8012c3:	e9 65 ff ff ff       	jmp    80122d <vprintfmt+0x61>
  8012c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ce:	8d 50 04             	lea    0x4(%eax),%edx
  8012d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8012d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012db:	8b 00                	mov    (%eax),%eax
  8012dd:	89 04 24             	mov    %eax,(%esp)
  8012e0:	ff 55 08             	call   *0x8(%ebp)
  8012e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8012e6:	e9 10 ff ff ff       	jmp    8011fb <vprintfmt+0x2f>
  8012eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8012ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f1:	8d 50 04             	lea    0x4(%eax),%edx
  8012f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8012f7:	8b 00                	mov    (%eax),%eax
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	c1 fa 1f             	sar    $0x1f,%edx
  8012fe:	31 d0                	xor    %edx,%eax
  801300:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801302:	83 f8 0f             	cmp    $0xf,%eax
  801305:	7f 0b                	jg     801312 <vprintfmt+0x146>
  801307:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80130e:	85 d2                	test   %edx,%edx
  801310:	75 26                	jne    801338 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801316:	c7 44 24 08 fc 21 80 	movl   $0x8021fc,0x8(%esp)
  80131d:	00 
  80131e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801321:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801325:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801328:	89 1c 24             	mov    %ebx,(%esp)
  80132b:	e8 a7 05 00 00       	call   8018d7 <printfmt>
  801330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801333:	e9 c3 fe ff ff       	jmp    8011fb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801338:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80133c:	c7 44 24 08 05 22 80 	movl   $0x802205,0x8(%esp)
  801343:	00 
  801344:	8b 45 0c             	mov    0xc(%ebp),%eax
  801347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134b:	8b 55 08             	mov    0x8(%ebp),%edx
  80134e:	89 14 24             	mov    %edx,(%esp)
  801351:	e8 81 05 00 00       	call   8018d7 <printfmt>
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801359:	e9 9d fe ff ff       	jmp    8011fb <vprintfmt+0x2f>
  80135e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801361:	89 c7                	mov    %eax,%edi
  801363:	89 d9                	mov    %ebx,%ecx
  801365:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801368:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80136b:	8b 45 14             	mov    0x14(%ebp),%eax
  80136e:	8d 50 04             	lea    0x4(%eax),%edx
  801371:	89 55 14             	mov    %edx,0x14(%ebp)
  801374:	8b 30                	mov    (%eax),%esi
  801376:	85 f6                	test   %esi,%esi
  801378:	75 05                	jne    80137f <vprintfmt+0x1b3>
  80137a:	be 08 22 80 00       	mov    $0x802208,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80137f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  801383:	7e 06                	jle    80138b <vprintfmt+0x1bf>
  801385:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  801389:	75 10                	jne    80139b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80138b:	0f be 06             	movsbl (%esi),%eax
  80138e:	85 c0                	test   %eax,%eax
  801390:	0f 85 a2 00 00 00    	jne    801438 <vprintfmt+0x26c>
  801396:	e9 92 00 00 00       	jmp    80142d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80139b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80139f:	89 34 24             	mov    %esi,(%esp)
  8013a2:	e8 74 05 00 00       	call   80191b <strnlen>
  8013a7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8013aa:	29 c2                	sub    %eax,%edx
  8013ac:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8013af:	85 d2                	test   %edx,%edx
  8013b1:	7e d8                	jle    80138b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8013b3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8013b7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8013ba:	89 d3                	mov    %edx,%ebx
  8013bc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8013bf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8013c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013c5:	89 ce                	mov    %ecx,%esi
  8013c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013cb:	89 34 24             	mov    %esi,(%esp)
  8013ce:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d1:	83 eb 01             	sub    $0x1,%ebx
  8013d4:	85 db                	test   %ebx,%ebx
  8013d6:	7f ef                	jg     8013c7 <vprintfmt+0x1fb>
  8013d8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8013db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013de:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8013e1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8013e8:	eb a1                	jmp    80138b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013ea:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8013ee:	74 1b                	je     80140b <vprintfmt+0x23f>
  8013f0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013f3:	83 fa 5e             	cmp    $0x5e,%edx
  8013f6:	76 13                	jbe    80140b <vprintfmt+0x23f>
					putch('?', putdat);
  8013f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ff:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801406:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801409:	eb 0d                	jmp    801418 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80140b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801418:	83 ef 01             	sub    $0x1,%edi
  80141b:	0f be 06             	movsbl (%esi),%eax
  80141e:	85 c0                	test   %eax,%eax
  801420:	74 05                	je     801427 <vprintfmt+0x25b>
  801422:	83 c6 01             	add    $0x1,%esi
  801425:	eb 1a                	jmp    801441 <vprintfmt+0x275>
  801427:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80142a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80142d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801431:	7f 1f                	jg     801452 <vprintfmt+0x286>
  801433:	e9 c0 fd ff ff       	jmp    8011f8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801438:	83 c6 01             	add    $0x1,%esi
  80143b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80143e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801441:	85 db                	test   %ebx,%ebx
  801443:	78 a5                	js     8013ea <vprintfmt+0x21e>
  801445:	83 eb 01             	sub    $0x1,%ebx
  801448:	79 a0                	jns    8013ea <vprintfmt+0x21e>
  80144a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80144d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801450:	eb db                	jmp    80142d <vprintfmt+0x261>
  801452:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801455:	8b 75 0c             	mov    0xc(%ebp),%esi
  801458:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80145b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80145e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801462:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801469:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80146b:	83 eb 01             	sub    $0x1,%ebx
  80146e:	85 db                	test   %ebx,%ebx
  801470:	7f ec                	jg     80145e <vprintfmt+0x292>
  801472:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801475:	e9 81 fd ff ff       	jmp    8011fb <vprintfmt+0x2f>
  80147a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80147d:	83 fe 01             	cmp    $0x1,%esi
  801480:	7e 10                	jle    801492 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801482:	8b 45 14             	mov    0x14(%ebp),%eax
  801485:	8d 50 08             	lea    0x8(%eax),%edx
  801488:	89 55 14             	mov    %edx,0x14(%ebp)
  80148b:	8b 18                	mov    (%eax),%ebx
  80148d:	8b 70 04             	mov    0x4(%eax),%esi
  801490:	eb 26                	jmp    8014b8 <vprintfmt+0x2ec>
	else if (lflag)
  801492:	85 f6                	test   %esi,%esi
  801494:	74 12                	je     8014a8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801496:	8b 45 14             	mov    0x14(%ebp),%eax
  801499:	8d 50 04             	lea    0x4(%eax),%edx
  80149c:	89 55 14             	mov    %edx,0x14(%ebp)
  80149f:	8b 18                	mov    (%eax),%ebx
  8014a1:	89 de                	mov    %ebx,%esi
  8014a3:	c1 fe 1f             	sar    $0x1f,%esi
  8014a6:	eb 10                	jmp    8014b8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ab:	8d 50 04             	lea    0x4(%eax),%edx
  8014ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b1:	8b 18                	mov    (%eax),%ebx
  8014b3:	89 de                	mov    %ebx,%esi
  8014b5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8014b8:	83 f9 01             	cmp    $0x1,%ecx
  8014bb:	75 1e                	jne    8014db <vprintfmt+0x30f>
                               if((long long)num > 0){
  8014bd:	85 f6                	test   %esi,%esi
  8014bf:	78 1a                	js     8014db <vprintfmt+0x30f>
  8014c1:	85 f6                	test   %esi,%esi
  8014c3:	7f 05                	jg     8014ca <vprintfmt+0x2fe>
  8014c5:	83 fb 00             	cmp    $0x0,%ebx
  8014c8:	76 11                	jbe    8014db <vprintfmt+0x30f>
                                   putch('+',putdat);
  8014ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014d1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8014d8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8014db:	85 f6                	test   %esi,%esi
  8014dd:	78 13                	js     8014f2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014df:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8014e2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8014e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ed:	e9 da 00 00 00       	jmp    8015cc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8014f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801500:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801503:	89 da                	mov    %ebx,%edx
  801505:	89 f1                	mov    %esi,%ecx
  801507:	f7 da                	neg    %edx
  801509:	83 d1 00             	adc    $0x0,%ecx
  80150c:	f7 d9                	neg    %ecx
  80150e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801511:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801514:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801517:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151c:	e9 ab 00 00 00       	jmp    8015cc <vprintfmt+0x400>
  801521:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801524:	89 f2                	mov    %esi,%edx
  801526:	8d 45 14             	lea    0x14(%ebp),%eax
  801529:	e8 47 fc ff ff       	call   801175 <getuint>
  80152e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801531:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801534:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801537:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80153c:	e9 8b 00 00 00       	jmp    8015cc <vprintfmt+0x400>
  801541:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801544:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801547:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80154b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801552:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801555:	89 f2                	mov    %esi,%edx
  801557:	8d 45 14             	lea    0x14(%ebp),%eax
  80155a:	e8 16 fc ff ff       	call   801175 <getuint>
  80155f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801562:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801568:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80156d:	eb 5d                	jmp    8015cc <vprintfmt+0x400>
  80156f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801572:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801575:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801579:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801580:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801583:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801587:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80158e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801591:	8b 45 14             	mov    0x14(%ebp),%eax
  801594:	8d 50 04             	lea    0x4(%eax),%edx
  801597:	89 55 14             	mov    %edx,0x14(%ebp)
  80159a:	8b 10                	mov    (%eax),%edx
  80159c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8015a4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8015a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015aa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015af:	eb 1b                	jmp    8015cc <vprintfmt+0x400>
  8015b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b4:	89 f2                	mov    %esi,%edx
  8015b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b9:	e8 b7 fb ff ff       	call   801175 <getuint>
  8015be:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8015c1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8015c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015c7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015cc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8015d0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8015d6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8015da:	77 09                	ja     8015e5 <vprintfmt+0x419>
  8015dc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8015df:	0f 82 ac 00 00 00    	jb     801691 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8015e5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8015e8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8015ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8015ef:	83 ea 01             	sub    $0x1,%edx
  8015f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015fa:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015fe:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801602:	89 45 c0             	mov    %eax,-0x40(%ebp)
  801605:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801608:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80160b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80160f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801616:	00 
  801617:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80161a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80161d:	89 0c 24             	mov    %ecx,(%esp)
  801620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801624:	e8 57 08 00 00       	call   801e80 <__udivdi3>
  801629:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80162c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80162f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801633:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801637:	89 04 24             	mov    %eax,(%esp)
  80163a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80163e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	e8 37 fa ff ff       	call   801080 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801649:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80164c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801650:	8b 74 24 04          	mov    0x4(%esp),%esi
  801654:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801657:	89 44 24 08          	mov    %eax,0x8(%esp)
  80165b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801662:	00 
  801663:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801666:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801669:	89 14 24             	mov    %edx,(%esp)
  80166c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801670:	e8 3b 09 00 00       	call   801fb0 <__umoddi3>
  801675:	89 74 24 04          	mov    %esi,0x4(%esp)
  801679:	0f be 80 eb 21 80 00 	movsbl 0x8021eb(%eax),%eax
  801680:	89 04 24             	mov    %eax,(%esp)
  801683:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801686:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80168a:	74 54                	je     8016e0 <vprintfmt+0x514>
  80168c:	e9 67 fb ff ff       	jmp    8011f8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801691:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801695:	8d 76 00             	lea    0x0(%esi),%esi
  801698:	0f 84 2a 01 00 00    	je     8017c8 <vprintfmt+0x5fc>
		while (--width > 0)
  80169e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8016a1:	83 ef 01             	sub    $0x1,%edi
  8016a4:	85 ff                	test   %edi,%edi
  8016a6:	0f 8e 5e 01 00 00    	jle    80180a <vprintfmt+0x63e>
  8016ac:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8016af:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8016b2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8016b5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8016b8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016bb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8016be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c2:	89 1c 24             	mov    %ebx,(%esp)
  8016c5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8016c8:	83 ef 01             	sub    $0x1,%edi
  8016cb:	85 ff                	test   %edi,%edi
  8016cd:	7f ef                	jg     8016be <vprintfmt+0x4f2>
  8016cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8016d5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8016d8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8016db:	e9 2a 01 00 00       	jmp    80180a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8016e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8016e3:	83 eb 01             	sub    $0x1,%ebx
  8016e6:	85 db                	test   %ebx,%ebx
  8016e8:	0f 8e 0a fb ff ff    	jle    8011f8 <vprintfmt+0x2c>
  8016ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016f1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8016f4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8016f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016fb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801702:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801704:	83 eb 01             	sub    $0x1,%ebx
  801707:	85 db                	test   %ebx,%ebx
  801709:	7f ec                	jg     8016f7 <vprintfmt+0x52b>
  80170b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80170e:	e9 e8 fa ff ff       	jmp    8011fb <vprintfmt+0x2f>
  801713:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801716:	8b 45 14             	mov    0x14(%ebp),%eax
  801719:	8d 50 04             	lea    0x4(%eax),%edx
  80171c:	89 55 14             	mov    %edx,0x14(%ebp)
  80171f:	8b 00                	mov    (%eax),%eax
  801721:	85 c0                	test   %eax,%eax
  801723:	75 2a                	jne    80174f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801725:	c7 44 24 0c 24 23 80 	movl   $0x802324,0xc(%esp)
  80172c:	00 
  80172d:	c7 44 24 08 05 22 80 	movl   $0x802205,0x8(%esp)
  801734:	00 
  801735:	8b 55 0c             	mov    0xc(%ebp),%edx
  801738:	89 54 24 04          	mov    %edx,0x4(%esp)
  80173c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80173f:	89 0c 24             	mov    %ecx,(%esp)
  801742:	e8 90 01 00 00       	call   8018d7 <printfmt>
  801747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80174a:	e9 ac fa ff ff       	jmp    8011fb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80174f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801752:	8b 13                	mov    (%ebx),%edx
  801754:	83 fa 7f             	cmp    $0x7f,%edx
  801757:	7e 29                	jle    801782 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801759:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80175b:	c7 44 24 0c 5c 23 80 	movl   $0x80235c,0xc(%esp)
  801762:	00 
  801763:	c7 44 24 08 05 22 80 	movl   $0x802205,0x8(%esp)
  80176a:	00 
  80176b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	89 04 24             	mov    %eax,(%esp)
  801775:	e8 5d 01 00 00       	call   8018d7 <printfmt>
  80177a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177d:	e9 79 fa ff ff       	jmp    8011fb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801782:	88 10                	mov    %dl,(%eax)
  801784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801787:	e9 6f fa ff ff       	jmp    8011fb <vprintfmt+0x2f>
  80178c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80178f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801795:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801799:	89 14 24             	mov    %edx,(%esp)
  80179c:	ff 55 08             	call   *0x8(%ebp)
  80179f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8017a2:	e9 54 fa ff ff       	jmp    8011fb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8017bb:	80 38 25             	cmpb   $0x25,(%eax)
  8017be:	0f 84 37 fa ff ff    	je     8011fb <vprintfmt+0x2f>
  8017c4:	89 c7                	mov    %eax,%edi
  8017c6:	eb f0                	jmp    8017b8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017d3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8017d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017e1:	00 
  8017e2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8017e5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8017e8:	89 04 24             	mov    %eax,(%esp)
  8017eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017ef:	e8 bc 07 00 00       	call   801fb0 <__umoddi3>
  8017f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017f8:	0f be 80 eb 21 80 00 	movsbl 0x8021eb(%eax),%eax
  8017ff:	89 04 24             	mov    %eax,(%esp)
  801802:	ff 55 08             	call   *0x8(%ebp)
  801805:	e9 d6 fe ff ff       	jmp    8016e0 <vprintfmt+0x514>
  80180a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801811:	8b 74 24 04          	mov    0x4(%esp),%esi
  801815:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801818:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80181c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801823:	00 
  801824:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801827:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80182a:	89 04 24             	mov    %eax,(%esp)
  80182d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801831:	e8 7a 07 00 00       	call   801fb0 <__umoddi3>
  801836:	89 74 24 04          	mov    %esi,0x4(%esp)
  80183a:	0f be 80 eb 21 80 00 	movsbl 0x8021eb(%eax),%eax
  801841:	89 04 24             	mov    %eax,(%esp)
  801844:	ff 55 08             	call   *0x8(%ebp)
  801847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80184a:	e9 ac f9 ff ff       	jmp    8011fb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80184f:	83 c4 6c             	add    $0x6c,%esp
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5f                   	pop    %edi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 28             	sub    $0x28,%esp
  80185d:	8b 45 08             	mov    0x8(%ebp),%eax
  801860:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801863:	85 c0                	test   %eax,%eax
  801865:	74 04                	je     80186b <vsnprintf+0x14>
  801867:	85 d2                	test   %edx,%edx
  801869:	7f 07                	jg     801872 <vsnprintf+0x1b>
  80186b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801870:	eb 3b                	jmp    8018ad <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801872:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801875:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801879:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80187c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801883:	8b 45 14             	mov    0x14(%ebp),%eax
  801886:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80188a:	8b 45 10             	mov    0x10(%ebp),%eax
  80188d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801891:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801894:	89 44 24 04          	mov    %eax,0x4(%esp)
  801898:	c7 04 24 af 11 80 00 	movl   $0x8011af,(%esp)
  80189f:	e8 28 f9 ff ff       	call   8011cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8018a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8018a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8018b5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8018b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8018bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	89 04 24             	mov    %eax,(%esp)
  8018d0:	e8 82 ff ff ff       	call   801857 <vsnprintf>
	va_end(ap);

	return rc;
}
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8018dd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8018e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	89 04 24             	mov    %eax,(%esp)
  8018f8:	e8 cf f8 ff ff       	call   8011cc <vprintfmt>
	va_end(ap);
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    
	...

00801900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801906:	b8 00 00 00 00       	mov    $0x0,%eax
  80190b:	80 3a 00             	cmpb   $0x0,(%edx)
  80190e:	74 09                	je     801919 <strlen+0x19>
		n++;
  801910:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801913:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801917:	75 f7                	jne    801910 <strlen+0x10>
		n++;
	return n;
}
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	53                   	push   %ebx
  80191f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801925:	85 c9                	test   %ecx,%ecx
  801927:	74 19                	je     801942 <strnlen+0x27>
  801929:	80 3b 00             	cmpb   $0x0,(%ebx)
  80192c:	74 14                	je     801942 <strnlen+0x27>
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801933:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801936:	39 c8                	cmp    %ecx,%eax
  801938:	74 0d                	je     801947 <strnlen+0x2c>
  80193a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80193e:	75 f3                	jne    801933 <strnlen+0x18>
  801940:	eb 05                	jmp    801947 <strnlen+0x2c>
  801942:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801947:	5b                   	pop    %ebx
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801954:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801959:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80195d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801960:	83 c2 01             	add    $0x1,%edx
  801963:	84 c9                	test   %cl,%cl
  801965:	75 f2                	jne    801959 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801967:	5b                   	pop    %ebx
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	53                   	push   %ebx
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801974:	89 1c 24             	mov    %ebx,(%esp)
  801977:	e8 84 ff ff ff       	call   801900 <strlen>
	strcpy(dst + len, src);
  80197c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80197f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801983:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801986:	89 04 24             	mov    %eax,(%esp)
  801989:	e8 bc ff ff ff       	call   80194a <strcpy>
	return dst;
}
  80198e:	89 d8                	mov    %ebx,%eax
  801990:	83 c4 08             	add    $0x8,%esp
  801993:	5b                   	pop    %ebx
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	56                   	push   %esi
  80199a:	53                   	push   %ebx
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019a4:	85 f6                	test   %esi,%esi
  8019a6:	74 18                	je     8019c0 <strncpy+0x2a>
  8019a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8019ad:	0f b6 1a             	movzbl (%edx),%ebx
  8019b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8019b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8019b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019b9:	83 c1 01             	add    $0x1,%ecx
  8019bc:	39 ce                	cmp    %ecx,%esi
  8019be:	77 ed                	ja     8019ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8019c0:	5b                   	pop    %ebx
  8019c1:	5e                   	pop    %esi
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8019d2:	89 f0                	mov    %esi,%eax
  8019d4:	85 c9                	test   %ecx,%ecx
  8019d6:	74 27                	je     8019ff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8019d8:	83 e9 01             	sub    $0x1,%ecx
  8019db:	74 1d                	je     8019fa <strlcpy+0x36>
  8019dd:	0f b6 1a             	movzbl (%edx),%ebx
  8019e0:	84 db                	test   %bl,%bl
  8019e2:	74 16                	je     8019fa <strlcpy+0x36>
			*dst++ = *src++;
  8019e4:	88 18                	mov    %bl,(%eax)
  8019e6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8019e9:	83 e9 01             	sub    $0x1,%ecx
  8019ec:	74 0e                	je     8019fc <strlcpy+0x38>
			*dst++ = *src++;
  8019ee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8019f1:	0f b6 1a             	movzbl (%edx),%ebx
  8019f4:	84 db                	test   %bl,%bl
  8019f6:	75 ec                	jne    8019e4 <strlcpy+0x20>
  8019f8:	eb 02                	jmp    8019fc <strlcpy+0x38>
  8019fa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8019fc:	c6 00 00             	movb   $0x0,(%eax)
  8019ff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801a0e:	0f b6 01             	movzbl (%ecx),%eax
  801a11:	84 c0                	test   %al,%al
  801a13:	74 15                	je     801a2a <strcmp+0x25>
  801a15:	3a 02                	cmp    (%edx),%al
  801a17:	75 11                	jne    801a2a <strcmp+0x25>
		p++, q++;
  801a19:	83 c1 01             	add    $0x1,%ecx
  801a1c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801a1f:	0f b6 01             	movzbl (%ecx),%eax
  801a22:	84 c0                	test   %al,%al
  801a24:	74 04                	je     801a2a <strcmp+0x25>
  801a26:	3a 02                	cmp    (%edx),%al
  801a28:	74 ef                	je     801a19 <strcmp+0x14>
  801a2a:	0f b6 c0             	movzbl %al,%eax
  801a2d:	0f b6 12             	movzbl (%edx),%edx
  801a30:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	53                   	push   %ebx
  801a38:	8b 55 08             	mov    0x8(%ebp),%edx
  801a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801a41:	85 c0                	test   %eax,%eax
  801a43:	74 23                	je     801a68 <strncmp+0x34>
  801a45:	0f b6 1a             	movzbl (%edx),%ebx
  801a48:	84 db                	test   %bl,%bl
  801a4a:	74 25                	je     801a71 <strncmp+0x3d>
  801a4c:	3a 19                	cmp    (%ecx),%bl
  801a4e:	75 21                	jne    801a71 <strncmp+0x3d>
  801a50:	83 e8 01             	sub    $0x1,%eax
  801a53:	74 13                	je     801a68 <strncmp+0x34>
		n--, p++, q++;
  801a55:	83 c2 01             	add    $0x1,%edx
  801a58:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801a5b:	0f b6 1a             	movzbl (%edx),%ebx
  801a5e:	84 db                	test   %bl,%bl
  801a60:	74 0f                	je     801a71 <strncmp+0x3d>
  801a62:	3a 19                	cmp    (%ecx),%bl
  801a64:	74 ea                	je     801a50 <strncmp+0x1c>
  801a66:	eb 09                	jmp    801a71 <strncmp+0x3d>
  801a68:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a6d:	5b                   	pop    %ebx
  801a6e:	5d                   	pop    %ebp
  801a6f:	90                   	nop
  801a70:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a71:	0f b6 02             	movzbl (%edx),%eax
  801a74:	0f b6 11             	movzbl (%ecx),%edx
  801a77:	29 d0                	sub    %edx,%eax
  801a79:	eb f2                	jmp    801a6d <strncmp+0x39>

00801a7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801a85:	0f b6 10             	movzbl (%eax),%edx
  801a88:	84 d2                	test   %dl,%dl
  801a8a:	74 18                	je     801aa4 <strchr+0x29>
		if (*s == c)
  801a8c:	38 ca                	cmp    %cl,%dl
  801a8e:	75 0a                	jne    801a9a <strchr+0x1f>
  801a90:	eb 17                	jmp    801aa9 <strchr+0x2e>
  801a92:	38 ca                	cmp    %cl,%dl
  801a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a98:	74 0f                	je     801aa9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801a9a:	83 c0 01             	add    $0x1,%eax
  801a9d:	0f b6 10             	movzbl (%eax),%edx
  801aa0:	84 d2                	test   %dl,%dl
  801aa2:	75 ee                	jne    801a92 <strchr+0x17>
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ab5:	0f b6 10             	movzbl (%eax),%edx
  801ab8:	84 d2                	test   %dl,%dl
  801aba:	74 18                	je     801ad4 <strfind+0x29>
		if (*s == c)
  801abc:	38 ca                	cmp    %cl,%dl
  801abe:	75 0a                	jne    801aca <strfind+0x1f>
  801ac0:	eb 12                	jmp    801ad4 <strfind+0x29>
  801ac2:	38 ca                	cmp    %cl,%dl
  801ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ac8:	74 0a                	je     801ad4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801aca:	83 c0 01             	add    $0x1,%eax
  801acd:	0f b6 10             	movzbl (%eax),%edx
  801ad0:	84 d2                	test   %dl,%dl
  801ad2:	75 ee                	jne    801ac2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	89 1c 24             	mov    %ebx,(%esp)
  801adf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801af0:	85 c9                	test   %ecx,%ecx
  801af2:	74 30                	je     801b24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801af4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801afa:	75 25                	jne    801b21 <memset+0x4b>
  801afc:	f6 c1 03             	test   $0x3,%cl
  801aff:	75 20                	jne    801b21 <memset+0x4b>
		c &= 0xFF;
  801b01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b04:	89 d3                	mov    %edx,%ebx
  801b06:	c1 e3 08             	shl    $0x8,%ebx
  801b09:	89 d6                	mov    %edx,%esi
  801b0b:	c1 e6 18             	shl    $0x18,%esi
  801b0e:	89 d0                	mov    %edx,%eax
  801b10:	c1 e0 10             	shl    $0x10,%eax
  801b13:	09 f0                	or     %esi,%eax
  801b15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801b17:	09 d8                	or     %ebx,%eax
  801b19:	c1 e9 02             	shr    $0x2,%ecx
  801b1c:	fc                   	cld    
  801b1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b1f:	eb 03                	jmp    801b24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b21:	fc                   	cld    
  801b22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b24:	89 f8                	mov    %edi,%eax
  801b26:	8b 1c 24             	mov    (%esp),%ebx
  801b29:	8b 74 24 04          	mov    0x4(%esp),%esi
  801b2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b31:	89 ec                	mov    %ebp,%esp
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	89 34 24             	mov    %esi,(%esp)
  801b3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801b48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801b4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801b4d:	39 c6                	cmp    %eax,%esi
  801b4f:	73 35                	jae    801b86 <memmove+0x51>
  801b51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b54:	39 d0                	cmp    %edx,%eax
  801b56:	73 2e                	jae    801b86 <memmove+0x51>
		s += n;
		d += n;
  801b58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b5a:	f6 c2 03             	test   $0x3,%dl
  801b5d:	75 1b                	jne    801b7a <memmove+0x45>
  801b5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b65:	75 13                	jne    801b7a <memmove+0x45>
  801b67:	f6 c1 03             	test   $0x3,%cl
  801b6a:	75 0e                	jne    801b7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801b6c:	83 ef 04             	sub    $0x4,%edi
  801b6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801b72:	c1 e9 02             	shr    $0x2,%ecx
  801b75:	fd                   	std    
  801b76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b78:	eb 09                	jmp    801b83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801b7a:	83 ef 01             	sub    $0x1,%edi
  801b7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801b80:	fd                   	std    
  801b81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801b83:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b84:	eb 20                	jmp    801ba6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801b8c:	75 15                	jne    801ba3 <memmove+0x6e>
  801b8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b94:	75 0d                	jne    801ba3 <memmove+0x6e>
  801b96:	f6 c1 03             	test   $0x3,%cl
  801b99:	75 08                	jne    801ba3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801b9b:	c1 e9 02             	shr    $0x2,%ecx
  801b9e:	fc                   	cld    
  801b9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ba1:	eb 03                	jmp    801ba6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801ba3:	fc                   	cld    
  801ba4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ba6:	8b 34 24             	mov    (%esp),%esi
  801ba9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801bad:	89 ec                	mov    %ebp,%esp
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801bb7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bba:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc8:	89 04 24             	mov    %eax,(%esp)
  801bcb:	e8 65 ff ff ff       	call   801b35 <memmove>
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	57                   	push   %edi
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bdb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801be1:	85 c9                	test   %ecx,%ecx
  801be3:	74 36                	je     801c1b <memcmp+0x49>
		if (*s1 != *s2)
  801be5:	0f b6 06             	movzbl (%esi),%eax
  801be8:	0f b6 1f             	movzbl (%edi),%ebx
  801beb:	38 d8                	cmp    %bl,%al
  801bed:	74 20                	je     801c0f <memcmp+0x3d>
  801bef:	eb 14                	jmp    801c05 <memcmp+0x33>
  801bf1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801bf6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801bfb:	83 c2 01             	add    $0x1,%edx
  801bfe:	83 e9 01             	sub    $0x1,%ecx
  801c01:	38 d8                	cmp    %bl,%al
  801c03:	74 12                	je     801c17 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801c05:	0f b6 c0             	movzbl %al,%eax
  801c08:	0f b6 db             	movzbl %bl,%ebx
  801c0b:	29 d8                	sub    %ebx,%eax
  801c0d:	eb 11                	jmp    801c20 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c0f:	83 e9 01             	sub    $0x1,%ecx
  801c12:	ba 00 00 00 00       	mov    $0x0,%edx
  801c17:	85 c9                	test   %ecx,%ecx
  801c19:	75 d6                	jne    801bf1 <memcmp+0x1f>
  801c1b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801c30:	39 d0                	cmp    %edx,%eax
  801c32:	73 15                	jae    801c49 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801c38:	38 08                	cmp    %cl,(%eax)
  801c3a:	75 06                	jne    801c42 <memfind+0x1d>
  801c3c:	eb 0b                	jmp    801c49 <memfind+0x24>
  801c3e:	38 08                	cmp    %cl,(%eax)
  801c40:	74 07                	je     801c49 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c42:	83 c0 01             	add    $0x1,%eax
  801c45:	39 c2                	cmp    %eax,%edx
  801c47:	77 f5                	ja     801c3e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	57                   	push   %edi
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	83 ec 04             	sub    $0x4,%esp
  801c54:	8b 55 08             	mov    0x8(%ebp),%edx
  801c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c5a:	0f b6 02             	movzbl (%edx),%eax
  801c5d:	3c 20                	cmp    $0x20,%al
  801c5f:	74 04                	je     801c65 <strtol+0x1a>
  801c61:	3c 09                	cmp    $0x9,%al
  801c63:	75 0e                	jne    801c73 <strtol+0x28>
		s++;
  801c65:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c68:	0f b6 02             	movzbl (%edx),%eax
  801c6b:	3c 20                	cmp    $0x20,%al
  801c6d:	74 f6                	je     801c65 <strtol+0x1a>
  801c6f:	3c 09                	cmp    $0x9,%al
  801c71:	74 f2                	je     801c65 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c73:	3c 2b                	cmp    $0x2b,%al
  801c75:	75 0c                	jne    801c83 <strtol+0x38>
		s++;
  801c77:	83 c2 01             	add    $0x1,%edx
  801c7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801c81:	eb 15                	jmp    801c98 <strtol+0x4d>
	else if (*s == '-')
  801c83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801c8a:	3c 2d                	cmp    $0x2d,%al
  801c8c:	75 0a                	jne    801c98 <strtol+0x4d>
		s++, neg = 1;
  801c8e:	83 c2 01             	add    $0x1,%edx
  801c91:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c98:	85 db                	test   %ebx,%ebx
  801c9a:	0f 94 c0             	sete   %al
  801c9d:	74 05                	je     801ca4 <strtol+0x59>
  801c9f:	83 fb 10             	cmp    $0x10,%ebx
  801ca2:	75 18                	jne    801cbc <strtol+0x71>
  801ca4:	80 3a 30             	cmpb   $0x30,(%edx)
  801ca7:	75 13                	jne    801cbc <strtol+0x71>
  801ca9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801cad:	8d 76 00             	lea    0x0(%esi),%esi
  801cb0:	75 0a                	jne    801cbc <strtol+0x71>
		s += 2, base = 16;
  801cb2:	83 c2 02             	add    $0x2,%edx
  801cb5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cba:	eb 15                	jmp    801cd1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cbc:	84 c0                	test   %al,%al
  801cbe:	66 90                	xchg   %ax,%ax
  801cc0:	74 0f                	je     801cd1 <strtol+0x86>
  801cc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801cc7:	80 3a 30             	cmpb   $0x30,(%edx)
  801cca:	75 05                	jne    801cd1 <strtol+0x86>
		s++, base = 8;
  801ccc:	83 c2 01             	add    $0x1,%edx
  801ccf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cd8:	0f b6 0a             	movzbl (%edx),%ecx
  801cdb:	89 cf                	mov    %ecx,%edi
  801cdd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801ce0:	80 fb 09             	cmp    $0x9,%bl
  801ce3:	77 08                	ja     801ced <strtol+0xa2>
			dig = *s - '0';
  801ce5:	0f be c9             	movsbl %cl,%ecx
  801ce8:	83 e9 30             	sub    $0x30,%ecx
  801ceb:	eb 1e                	jmp    801d0b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801ced:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801cf0:	80 fb 19             	cmp    $0x19,%bl
  801cf3:	77 08                	ja     801cfd <strtol+0xb2>
			dig = *s - 'a' + 10;
  801cf5:	0f be c9             	movsbl %cl,%ecx
  801cf8:	83 e9 57             	sub    $0x57,%ecx
  801cfb:	eb 0e                	jmp    801d0b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801cfd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801d00:	80 fb 19             	cmp    $0x19,%bl
  801d03:	77 15                	ja     801d1a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801d05:	0f be c9             	movsbl %cl,%ecx
  801d08:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801d0b:	39 f1                	cmp    %esi,%ecx
  801d0d:	7d 0b                	jge    801d1a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801d0f:	83 c2 01             	add    $0x1,%edx
  801d12:	0f af c6             	imul   %esi,%eax
  801d15:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801d18:	eb be                	jmp    801cd8 <strtol+0x8d>
  801d1a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801d1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d20:	74 05                	je     801d27 <strtol+0xdc>
		*endptr = (char *) s;
  801d22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d25:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801d27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801d2b:	74 04                	je     801d31 <strtol+0xe6>
  801d2d:	89 c8                	mov    %ecx,%eax
  801d2f:	f7 d8                	neg    %eax
}
  801d31:	83 c4 04             	add    $0x4,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	00 00                	add    %al,(%eax)
  801d3b:	00 00                	add    %al,(%eax)
  801d3d:	00 00                	add    %al,(%eax)
	...

00801d40 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d46:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801d4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d51:	39 ca                	cmp    %ecx,%edx
  801d53:	75 04                	jne    801d59 <ipc_find_env+0x19>
  801d55:	b0 00                	mov    $0x0,%al
  801d57:	eb 12                	jmp    801d6b <ipc_find_env+0x2b>
  801d59:	89 c2                	mov    %eax,%edx
  801d5b:	c1 e2 07             	shl    $0x7,%edx
  801d5e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801d65:	8b 12                	mov    (%edx),%edx
  801d67:	39 ca                	cmp    %ecx,%edx
  801d69:	75 10                	jne    801d7b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d6b:	89 c2                	mov    %eax,%edx
  801d6d:	c1 e2 07             	shl    $0x7,%edx
  801d70:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801d77:	8b 00                	mov    (%eax),%eax
  801d79:	eb 0e                	jmp    801d89 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d7b:	83 c0 01             	add    $0x1,%eax
  801d7e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d83:	75 d4                	jne    801d59 <ipc_find_env+0x19>
  801d85:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	57                   	push   %edi
  801d8f:	56                   	push   %esi
  801d90:	53                   	push   %ebx
  801d91:	83 ec 1c             	sub    $0x1c,%esp
  801d94:	8b 75 08             	mov    0x8(%ebp),%esi
  801d97:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801d9d:	85 db                	test   %ebx,%ebx
  801d9f:	74 19                	je     801dba <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801da1:	8b 45 14             	mov    0x14(%ebp),%eax
  801da4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801db0:	89 34 24             	mov    %esi,(%esp)
  801db3:	e8 e4 e4 ff ff       	call   80029c <sys_ipc_try_send>
  801db8:	eb 1b                	jmp    801dd5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801dba:	8b 45 14             	mov    0x14(%ebp),%eax
  801dbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dc1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801dc8:	ee 
  801dc9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dcd:	89 34 24             	mov    %esi,(%esp)
  801dd0:	e8 c7 e4 ff ff       	call   80029c <sys_ipc_try_send>
           if(ret == 0)
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	74 28                	je     801e01 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801dd9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ddc:	74 1c                	je     801dfa <ipc_send+0x6f>
              panic("ipc send error");
  801dde:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  801de5:	00 
  801de6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801ded:	00 
  801dee:	c7 04 24 6f 25 80 00 	movl   $0x80256f,(%esp)
  801df5:	e8 6a f1 ff ff       	call   800f64 <_panic>
           sys_yield();
  801dfa:	e8 69 e7 ff ff       	call   800568 <sys_yield>
        }
  801dff:	eb 9c                	jmp    801d9d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	56                   	push   %esi
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 10             	sub    $0x10,%esp
  801e11:	8b 75 08             	mov    0x8(%ebp),%esi
  801e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	75 0e                	jne    801e2c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e1e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e25:	e8 07 e4 ff ff       	call   800231 <sys_ipc_recv>
  801e2a:	eb 08                	jmp    801e34 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e2c:	89 04 24             	mov    %eax,(%esp)
  801e2f:	e8 fd e3 ff ff       	call   800231 <sys_ipc_recv>
        if(ret == 0){
  801e34:	85 c0                	test   %eax,%eax
  801e36:	75 26                	jne    801e5e <ipc_recv+0x55>
           if(from_env_store)
  801e38:	85 f6                	test   %esi,%esi
  801e3a:	74 0a                	je     801e46 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e3c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e41:	8b 40 78             	mov    0x78(%eax),%eax
  801e44:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801e46:	85 db                	test   %ebx,%ebx
  801e48:	74 0a                	je     801e54 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801e4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e52:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801e54:	a1 04 40 80 00       	mov    0x804004,%eax
  801e59:	8b 40 74             	mov    0x74(%eax),%eax
  801e5c:	eb 14                	jmp    801e72 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801e5e:	85 f6                	test   %esi,%esi
  801e60:	74 06                	je     801e68 <ipc_recv+0x5f>
              *from_env_store = 0;
  801e62:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801e68:	85 db                	test   %ebx,%ebx
  801e6a:	74 06                	je     801e72 <ipc_recv+0x69>
              *perm_store = 0;
  801e6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	5b                   	pop    %ebx
  801e76:	5e                   	pop    %esi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    
  801e79:	00 00                	add    %al,(%eax)
  801e7b:	00 00                	add    %al,(%eax)
  801e7d:	00 00                	add    %al,(%eax)
	...

00801e80 <__udivdi3>:
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	83 ec 10             	sub    $0x10,%esp
  801e88:	8b 45 14             	mov    0x14(%ebp),%eax
  801e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  801e8e:	8b 75 10             	mov    0x10(%ebp),%esi
  801e91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e94:	85 c0                	test   %eax,%eax
  801e96:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801e99:	75 35                	jne    801ed0 <__udivdi3+0x50>
  801e9b:	39 fe                	cmp    %edi,%esi
  801e9d:	77 61                	ja     801f00 <__udivdi3+0x80>
  801e9f:	85 f6                	test   %esi,%esi
  801ea1:	75 0b                	jne    801eae <__udivdi3+0x2e>
  801ea3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea8:	31 d2                	xor    %edx,%edx
  801eaa:	f7 f6                	div    %esi
  801eac:	89 c6                	mov    %eax,%esi
  801eae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801eb1:	31 d2                	xor    %edx,%edx
  801eb3:	89 f8                	mov    %edi,%eax
  801eb5:	f7 f6                	div    %esi
  801eb7:	89 c7                	mov    %eax,%edi
  801eb9:	89 c8                	mov    %ecx,%eax
  801ebb:	f7 f6                	div    %esi
  801ebd:	89 c1                	mov    %eax,%ecx
  801ebf:	89 fa                	mov    %edi,%edx
  801ec1:	89 c8                	mov    %ecx,%eax
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	5e                   	pop    %esi
  801ec7:	5f                   	pop    %edi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    
  801eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ed0:	39 f8                	cmp    %edi,%eax
  801ed2:	77 1c                	ja     801ef0 <__udivdi3+0x70>
  801ed4:	0f bd d0             	bsr    %eax,%edx
  801ed7:	83 f2 1f             	xor    $0x1f,%edx
  801eda:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801edd:	75 39                	jne    801f18 <__udivdi3+0x98>
  801edf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ee2:	0f 86 a0 00 00 00    	jbe    801f88 <__udivdi3+0x108>
  801ee8:	39 f8                	cmp    %edi,%eax
  801eea:	0f 82 98 00 00 00    	jb     801f88 <__udivdi3+0x108>
  801ef0:	31 ff                	xor    %edi,%edi
  801ef2:	31 c9                	xor    %ecx,%ecx
  801ef4:	89 c8                	mov    %ecx,%eax
  801ef6:	89 fa                	mov    %edi,%edx
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	5e                   	pop    %esi
  801efc:	5f                   	pop    %edi
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    
  801eff:	90                   	nop
  801f00:	89 d1                	mov    %edx,%ecx
  801f02:	89 fa                	mov    %edi,%edx
  801f04:	89 c8                	mov    %ecx,%eax
  801f06:	31 ff                	xor    %edi,%edi
  801f08:	f7 f6                	div    %esi
  801f0a:	89 c1                	mov    %eax,%ecx
  801f0c:	89 fa                	mov    %edi,%edx
  801f0e:	89 c8                	mov    %ecx,%eax
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	5e                   	pop    %esi
  801f14:	5f                   	pop    %edi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    
  801f17:	90                   	nop
  801f18:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f1c:	89 f2                	mov    %esi,%edx
  801f1e:	d3 e0                	shl    %cl,%eax
  801f20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f23:	b8 20 00 00 00       	mov    $0x20,%eax
  801f28:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f2b:	89 c1                	mov    %eax,%ecx
  801f2d:	d3 ea                	shr    %cl,%edx
  801f2f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f33:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f36:	d3 e6                	shl    %cl,%esi
  801f38:	89 c1                	mov    %eax,%ecx
  801f3a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f3d:	89 fe                	mov    %edi,%esi
  801f3f:	d3 ee                	shr    %cl,%esi
  801f41:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f45:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f4b:	d3 e7                	shl    %cl,%edi
  801f4d:	89 c1                	mov    %eax,%ecx
  801f4f:	d3 ea                	shr    %cl,%edx
  801f51:	09 d7                	or     %edx,%edi
  801f53:	89 f2                	mov    %esi,%edx
  801f55:	89 f8                	mov    %edi,%eax
  801f57:	f7 75 ec             	divl   -0x14(%ebp)
  801f5a:	89 d6                	mov    %edx,%esi
  801f5c:	89 c7                	mov    %eax,%edi
  801f5e:	f7 65 e8             	mull   -0x18(%ebp)
  801f61:	39 d6                	cmp    %edx,%esi
  801f63:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f66:	72 30                	jb     801f98 <__udivdi3+0x118>
  801f68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f6b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f6f:	d3 e2                	shl    %cl,%edx
  801f71:	39 c2                	cmp    %eax,%edx
  801f73:	73 05                	jae    801f7a <__udivdi3+0xfa>
  801f75:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801f78:	74 1e                	je     801f98 <__udivdi3+0x118>
  801f7a:	89 f9                	mov    %edi,%ecx
  801f7c:	31 ff                	xor    %edi,%edi
  801f7e:	e9 71 ff ff ff       	jmp    801ef4 <__udivdi3+0x74>
  801f83:	90                   	nop
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	31 ff                	xor    %edi,%edi
  801f8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801f8f:	e9 60 ff ff ff       	jmp    801ef4 <__udivdi3+0x74>
  801f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f98:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801f9b:	31 ff                	xor    %edi,%edi
  801f9d:	89 c8                	mov    %ecx,%eax
  801f9f:	89 fa                	mov    %edi,%edx
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
	...

00801fb0 <__umoddi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	57                   	push   %edi
  801fb4:	56                   	push   %esi
  801fb5:	83 ec 20             	sub    $0x20,%esp
  801fb8:	8b 55 14             	mov    0x14(%ebp),%edx
  801fbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fbe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801fc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc4:	85 d2                	test   %edx,%edx
  801fc6:	89 c8                	mov    %ecx,%eax
  801fc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fcb:	75 13                	jne    801fe0 <__umoddi3+0x30>
  801fcd:	39 f7                	cmp    %esi,%edi
  801fcf:	76 3f                	jbe    802010 <__umoddi3+0x60>
  801fd1:	89 f2                	mov    %esi,%edx
  801fd3:	f7 f7                	div    %edi
  801fd5:	89 d0                	mov    %edx,%eax
  801fd7:	31 d2                	xor    %edx,%edx
  801fd9:	83 c4 20             	add    $0x20,%esp
  801fdc:	5e                   	pop    %esi
  801fdd:	5f                   	pop    %edi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    
  801fe0:	39 f2                	cmp    %esi,%edx
  801fe2:	77 4c                	ja     802030 <__umoddi3+0x80>
  801fe4:	0f bd ca             	bsr    %edx,%ecx
  801fe7:	83 f1 1f             	xor    $0x1f,%ecx
  801fea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801fed:	75 51                	jne    802040 <__umoddi3+0x90>
  801fef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801ff2:	0f 87 e0 00 00 00    	ja     8020d8 <__umoddi3+0x128>
  801ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffb:	29 f8                	sub    %edi,%eax
  801ffd:	19 d6                	sbb    %edx,%esi
  801fff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802002:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802005:	89 f2                	mov    %esi,%edx
  802007:	83 c4 20             	add    $0x20,%esp
  80200a:	5e                   	pop    %esi
  80200b:	5f                   	pop    %edi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    
  80200e:	66 90                	xchg   %ax,%ax
  802010:	85 ff                	test   %edi,%edi
  802012:	75 0b                	jne    80201f <__umoddi3+0x6f>
  802014:	b8 01 00 00 00       	mov    $0x1,%eax
  802019:	31 d2                	xor    %edx,%edx
  80201b:	f7 f7                	div    %edi
  80201d:	89 c7                	mov    %eax,%edi
  80201f:	89 f0                	mov    %esi,%eax
  802021:	31 d2                	xor    %edx,%edx
  802023:	f7 f7                	div    %edi
  802025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802028:	f7 f7                	div    %edi
  80202a:	eb a9                	jmp    801fd5 <__umoddi3+0x25>
  80202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	83 c4 20             	add    $0x20,%esp
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
  80203b:	90                   	nop
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802044:	d3 e2                	shl    %cl,%edx
  802046:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802049:	ba 20 00 00 00       	mov    $0x20,%edx
  80204e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802051:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802054:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802058:	89 fa                	mov    %edi,%edx
  80205a:	d3 ea                	shr    %cl,%edx
  80205c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802060:	0b 55 f4             	or     -0xc(%ebp),%edx
  802063:	d3 e7                	shl    %cl,%edi
  802065:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802069:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80206c:	89 f2                	mov    %esi,%edx
  80206e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802071:	89 c7                	mov    %eax,%edi
  802073:	d3 ea                	shr    %cl,%edx
  802075:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802079:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80207c:	89 c2                	mov    %eax,%edx
  80207e:	d3 e6                	shl    %cl,%esi
  802080:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802084:	d3 ea                	shr    %cl,%edx
  802086:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80208a:	09 d6                	or     %edx,%esi
  80208c:	89 f0                	mov    %esi,%eax
  80208e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802091:	d3 e7                	shl    %cl,%edi
  802093:	89 f2                	mov    %esi,%edx
  802095:	f7 75 f4             	divl   -0xc(%ebp)
  802098:	89 d6                	mov    %edx,%esi
  80209a:	f7 65 e8             	mull   -0x18(%ebp)
  80209d:	39 d6                	cmp    %edx,%esi
  80209f:	72 2b                	jb     8020cc <__umoddi3+0x11c>
  8020a1:	39 c7                	cmp    %eax,%edi
  8020a3:	72 23                	jb     8020c8 <__umoddi3+0x118>
  8020a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020a9:	29 c7                	sub    %eax,%edi
  8020ab:	19 d6                	sbb    %edx,%esi
  8020ad:	89 f0                	mov    %esi,%eax
  8020af:	89 f2                	mov    %esi,%edx
  8020b1:	d3 ef                	shr    %cl,%edi
  8020b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020b7:	d3 e0                	shl    %cl,%eax
  8020b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020bd:	09 f8                	or     %edi,%eax
  8020bf:	d3 ea                	shr    %cl,%edx
  8020c1:	83 c4 20             	add    $0x20,%esp
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	39 d6                	cmp    %edx,%esi
  8020ca:	75 d9                	jne    8020a5 <__umoddi3+0xf5>
  8020cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8020d2:	eb d1                	jmp    8020a5 <__umoddi3+0xf5>
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	0f 82 18 ff ff ff    	jb     801ff8 <__umoddi3+0x48>
  8020e0:	e9 1d ff ff ff       	jmp    802002 <__umoddi3+0x52>
