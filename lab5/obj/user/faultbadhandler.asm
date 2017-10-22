
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
  800051:	e8 c9 04 00 00       	call   80051f <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 97 02 00 00       	call   800301 <sys_env_set_pgfault_upcall>
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
  80008a:	e8 7f 05 00 00       	call   80060e <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	89 c2                	mov    %eax,%edx
  800096:	c1 e2 07             	shl    $0x7,%edx
  800099:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000a0:	a3 04 40 80 00       	mov    %eax,0x804004
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
  8000d2:	e8 c4 0a 00 00       	call   800b9b <close_all>
	sys_env_destroy(0);
  8000d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000de:	e8 6b 05 00 00       	call   80064e <sys_env_destroy>
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

00800167 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
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
  800174:	b8 10 00 00 00       	mov    $0x10,%eax
  800179:	8b 7d 14             	mov    0x14(%ebp),%edi
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800182:	8b 55 08             	mov    0x8(%ebp),%edx
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
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  80019d:	8b 1c 24             	mov    (%esp),%ebx
  8001a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001a4:	89 ec                	mov    %ebp,%esp
  8001a6:	5d                   	pop    %ebp
  8001a7:	c3                   	ret    

008001a8 <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 28             	sub    $0x28,%esp
  8001ae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001b1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8001be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	89 df                	mov    %ebx,%edi
  8001c6:	51                   	push   %ecx
  8001c7:	52                   	push   %edx
  8001c8:	53                   	push   %ebx
  8001c9:	54                   	push   %esp
  8001ca:	55                   	push   %ebp
  8001cb:	56                   	push   %esi
  8001cc:	57                   	push   %edi
  8001cd:	54                   	push   %esp
  8001ce:	5d                   	pop    %ebp
  8001cf:	8d 35 d7 01 80 00    	lea    0x8001d7,%esi
  8001d5:	0f 34                	sysenter 
  8001d7:	5f                   	pop    %edi
  8001d8:	5e                   	pop    %esi
  8001d9:	5d                   	pop    %ebp
  8001da:	5c                   	pop    %esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5a                   	pop    %edx
  8001dd:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8001de:	85 c0                	test   %eax,%eax
  8001e0:	7e 28                	jle    80020a <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e6:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8001fd:	00 
  8001fe:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  800205:	e8 7a 0d 00 00       	call   800f84 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80020a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80020d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800210:	89 ec                	mov    %ebp,%esp
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 08             	sub    $0x8,%esp
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800221:	b9 00 00 00 00       	mov    $0x0,%ecx
  800226:	b8 11 00 00 00       	mov    $0x11,%eax
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	89 cb                	mov    %ecx,%ebx
  800230:	89 cf                	mov    %ecx,%edi
  800232:	51                   	push   %ecx
  800233:	52                   	push   %edx
  800234:	53                   	push   %ebx
  800235:	54                   	push   %esp
  800236:	55                   	push   %ebp
  800237:	56                   	push   %esi
  800238:	57                   	push   %edi
  800239:	54                   	push   %esp
  80023a:	5d                   	pop    %ebp
  80023b:	8d 35 43 02 80 00    	lea    0x800243,%esi
  800241:	0f 34                	sysenter 
  800243:	5f                   	pop    %edi
  800244:	5e                   	pop    %esi
  800245:	5d                   	pop    %ebp
  800246:	5c                   	pop    %esp
  800247:	5b                   	pop    %ebx
  800248:	5a                   	pop    %edx
  800249:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80024a:	8b 1c 24             	mov    (%esp),%ebx
  80024d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800251:	89 ec                	mov    %ebp,%esp
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 28             	sub    $0x28,%esp
  80025b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80025e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800261:	b9 00 00 00 00       	mov    $0x0,%ecx
  800266:	b8 0e 00 00 00       	mov    $0xe,%eax
  80026b:	8b 55 08             	mov    0x8(%ebp),%edx
  80026e:	89 cb                	mov    %ecx,%ebx
  800270:	89 cf                	mov    %ecx,%edi
  800272:	51                   	push   %ecx
  800273:	52                   	push   %edx
  800274:	53                   	push   %ebx
  800275:	54                   	push   %esp
  800276:	55                   	push   %ebp
  800277:	56                   	push   %esi
  800278:	57                   	push   %edi
  800279:	54                   	push   %esp
  80027a:	5d                   	pop    %ebp
  80027b:	8d 35 83 02 80 00    	lea    0x800283,%esi
  800281:	0f 34                	sysenter 
  800283:	5f                   	pop    %edi
  800284:	5e                   	pop    %esi
  800285:	5d                   	pop    %ebp
  800286:	5c                   	pop    %esp
  800287:	5b                   	pop    %ebx
  800288:	5a                   	pop    %edx
  800289:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 28                	jle    8002b6 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800292:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800299:	00 
  80029a:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8002a9:	00 
  8002aa:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  8002b1:	e8 ce 0c 00 00       	call   800f84 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002b6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002b9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002bc:	89 ec                	mov    %ebp,%esp
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	89 1c 24             	mov    %ebx,(%esp)
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002cd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	51                   	push   %ecx
  8002df:	52                   	push   %edx
  8002e0:	53                   	push   %ebx
  8002e1:	54                   	push   %esp
  8002e2:	55                   	push   %ebp
  8002e3:	56                   	push   %esi
  8002e4:	57                   	push   %edi
  8002e5:	54                   	push   %esp
  8002e6:	5d                   	pop    %ebp
  8002e7:	8d 35 ef 02 80 00    	lea    0x8002ef,%esi
  8002ed:	0f 34                	sysenter 
  8002ef:	5f                   	pop    %edi
  8002f0:	5e                   	pop    %esi
  8002f1:	5d                   	pop    %ebp
  8002f2:	5c                   	pop    %esp
  8002f3:	5b                   	pop    %ebx
  8002f4:	5a                   	pop    %edx
  8002f5:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002f6:	8b 1c 24             	mov    (%esp),%ebx
  8002f9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002fd:	89 ec                	mov    %ebp,%esp
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	83 ec 28             	sub    $0x28,%esp
  800307:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80030a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80030d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800312:	b8 0b 00 00 00       	mov    $0xb,%eax
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031a:	8b 55 08             	mov    0x8(%ebp),%edx
  80031d:	89 df                	mov    %ebx,%edi
  80031f:	51                   	push   %ecx
  800320:	52                   	push   %edx
  800321:	53                   	push   %ebx
  800322:	54                   	push   %esp
  800323:	55                   	push   %ebp
  800324:	56                   	push   %esi
  800325:	57                   	push   %edi
  800326:	54                   	push   %esp
  800327:	5d                   	pop    %ebp
  800328:	8d 35 30 03 80 00    	lea    0x800330,%esi
  80032e:	0f 34                	sysenter 
  800330:	5f                   	pop    %edi
  800331:	5e                   	pop    %esi
  800332:	5d                   	pop    %ebp
  800333:	5c                   	pop    %esp
  800334:	5b                   	pop    %ebx
  800335:	5a                   	pop    %edx
  800336:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800337:	85 c0                	test   %eax,%eax
  800339:	7e 28                	jle    800363 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80033f:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  800346:	00 
  800347:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  80034e:	00 
  80034f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800356:	00 
  800357:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  80035e:	e8 21 0c 00 00       	call   800f84 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800363:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800366:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800369:	89 ec                	mov    %ebp,%esp
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	83 ec 28             	sub    $0x28,%esp
  800373:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800376:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800379:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800383:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800386:	8b 55 08             	mov    0x8(%ebp),%edx
  800389:	89 df                	mov    %ebx,%edi
  80038b:	51                   	push   %ecx
  80038c:	52                   	push   %edx
  80038d:	53                   	push   %ebx
  80038e:	54                   	push   %esp
  80038f:	55                   	push   %ebp
  800390:	56                   	push   %esi
  800391:	57                   	push   %edi
  800392:	54                   	push   %esp
  800393:	5d                   	pop    %ebp
  800394:	8d 35 9c 03 80 00    	lea    0x80039c,%esi
  80039a:	0f 34                	sysenter 
  80039c:	5f                   	pop    %edi
  80039d:	5e                   	pop    %esi
  80039e:	5d                   	pop    %ebp
  80039f:	5c                   	pop    %esp
  8003a0:	5b                   	pop    %ebx
  8003a1:	5a                   	pop    %edx
  8003a2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	7e 28                	jle    8003cf <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ab:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8003b2:	00 
  8003b3:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  8003ba:	00 
  8003bb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8003c2:	00 
  8003c3:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  8003ca:	e8 b5 0b 00 00       	call   800f84 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d5:	89 ec                	mov    %ebp,%esp
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    

008003d9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	83 ec 28             	sub    $0x28,%esp
  8003df:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003e2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ea:	b8 09 00 00 00       	mov    $0x9,%eax
  8003ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f5:	89 df                	mov    %ebx,%edi
  8003f7:	51                   	push   %ecx
  8003f8:	52                   	push   %edx
  8003f9:	53                   	push   %ebx
  8003fa:	54                   	push   %esp
  8003fb:	55                   	push   %ebp
  8003fc:	56                   	push   %esi
  8003fd:	57                   	push   %edi
  8003fe:	54                   	push   %esp
  8003ff:	5d                   	pop    %ebp
  800400:	8d 35 08 04 80 00    	lea    0x800408,%esi
  800406:	0f 34                	sysenter 
  800408:	5f                   	pop    %edi
  800409:	5e                   	pop    %esi
  80040a:	5d                   	pop    %ebp
  80040b:	5c                   	pop    %esp
  80040c:	5b                   	pop    %ebx
  80040d:	5a                   	pop    %edx
  80040e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80040f:	85 c0                	test   %eax,%eax
  800411:	7e 28                	jle    80043b <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800413:	89 44 24 10          	mov    %eax,0x10(%esp)
  800417:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80041e:	00 
  80041f:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  800426:	00 
  800427:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80042e:	00 
  80042f:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  800436:	e8 49 0b 00 00       	call   800f84 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80043b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80043e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800441:	89 ec                	mov    %ebp,%esp
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	83 ec 28             	sub    $0x28,%esp
  80044b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80044e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800451:	bb 00 00 00 00       	mov    $0x0,%ebx
  800456:	b8 07 00 00 00       	mov    $0x7,%eax
  80045b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045e:	8b 55 08             	mov    0x8(%ebp),%edx
  800461:	89 df                	mov    %ebx,%edi
  800463:	51                   	push   %ecx
  800464:	52                   	push   %edx
  800465:	53                   	push   %ebx
  800466:	54                   	push   %esp
  800467:	55                   	push   %ebp
  800468:	56                   	push   %esi
  800469:	57                   	push   %edi
  80046a:	54                   	push   %esp
  80046b:	5d                   	pop    %ebp
  80046c:	8d 35 74 04 80 00    	lea    0x800474,%esi
  800472:	0f 34                	sysenter 
  800474:	5f                   	pop    %edi
  800475:	5e                   	pop    %esi
  800476:	5d                   	pop    %ebp
  800477:	5c                   	pop    %esp
  800478:	5b                   	pop    %ebx
  800479:	5a                   	pop    %edx
  80047a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80047b:	85 c0                	test   %eax,%eax
  80047d:	7e 28                	jle    8004a7 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80047f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800483:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80048a:	00 
  80048b:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  800492:	00 
  800493:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80049a:	00 
  80049b:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  8004a2:	e8 dd 0a 00 00       	call   800f84 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8004a7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004ad:	89 ec                	mov    %ebp,%esp
  8004af:	5d                   	pop    %ebp
  8004b0:	c3                   	ret    

008004b1 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	83 ec 28             	sub    $0x28,%esp
  8004b7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004ba:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004bd:	8b 7d 18             	mov    0x18(%ebp),%edi
  8004c0:	0b 7d 14             	or     0x14(%ebp),%edi
  8004c3:	b8 06 00 00 00       	mov    $0x6,%eax
  8004c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d1:	51                   	push   %ecx
  8004d2:	52                   	push   %edx
  8004d3:	53                   	push   %ebx
  8004d4:	54                   	push   %esp
  8004d5:	55                   	push   %ebp
  8004d6:	56                   	push   %esi
  8004d7:	57                   	push   %edi
  8004d8:	54                   	push   %esp
  8004d9:	5d                   	pop    %ebp
  8004da:	8d 35 e2 04 80 00    	lea    0x8004e2,%esi
  8004e0:	0f 34                	sysenter 
  8004e2:	5f                   	pop    %edi
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	5c                   	pop    %esp
  8004e6:	5b                   	pop    %ebx
  8004e7:	5a                   	pop    %edx
  8004e8:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	7e 28                	jle    800515 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004f1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8004f8:	00 
  8004f9:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  800500:	00 
  800501:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800508:	00 
  800509:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  800510:	e8 6f 0a 00 00       	call   800f84 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  800515:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800518:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80051b:	89 ec                	mov    %ebp,%esp
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    

0080051f <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	83 ec 28             	sub    $0x28,%esp
  800525:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800528:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80052b:	bf 00 00 00 00       	mov    $0x0,%edi
  800530:	b8 05 00 00 00       	mov    $0x5,%eax
  800535:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800538:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80053b:	8b 55 08             	mov    0x8(%ebp),%edx
  80053e:	51                   	push   %ecx
  80053f:	52                   	push   %edx
  800540:	53                   	push   %ebx
  800541:	54                   	push   %esp
  800542:	55                   	push   %ebp
  800543:	56                   	push   %esi
  800544:	57                   	push   %edi
  800545:	54                   	push   %esp
  800546:	5d                   	pop    %ebp
  800547:	8d 35 4f 05 80 00    	lea    0x80054f,%esi
  80054d:	0f 34                	sysenter 
  80054f:	5f                   	pop    %edi
  800550:	5e                   	pop    %esi
  800551:	5d                   	pop    %ebp
  800552:	5c                   	pop    %esp
  800553:	5b                   	pop    %ebx
  800554:	5a                   	pop    %edx
  800555:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800556:	85 c0                	test   %eax,%eax
  800558:	7e 28                	jle    800582 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80055a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80055e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800565:	00 
  800566:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  80056d:	00 
  80056e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800575:	00 
  800576:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  80057d:	e8 02 0a 00 00       	call   800f84 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800582:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800585:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800588:	89 ec                	mov    %ebp,%esp
  80058a:	5d                   	pop    %ebp
  80058b:	c3                   	ret    

0080058c <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	89 1c 24             	mov    %ebx,(%esp)
  800595:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
  80059e:	b8 0c 00 00 00       	mov    $0xc,%eax
  8005a3:	89 d1                	mov    %edx,%ecx
  8005a5:	89 d3                	mov    %edx,%ebx
  8005a7:	89 d7                	mov    %edx,%edi
  8005a9:	51                   	push   %ecx
  8005aa:	52                   	push   %edx
  8005ab:	53                   	push   %ebx
  8005ac:	54                   	push   %esp
  8005ad:	55                   	push   %ebp
  8005ae:	56                   	push   %esi
  8005af:	57                   	push   %edi
  8005b0:	54                   	push   %esp
  8005b1:	5d                   	pop    %ebp
  8005b2:	8d 35 ba 05 80 00    	lea    0x8005ba,%esi
  8005b8:	0f 34                	sysenter 
  8005ba:	5f                   	pop    %edi
  8005bb:	5e                   	pop    %esi
  8005bc:	5d                   	pop    %ebp
  8005bd:	5c                   	pop    %esp
  8005be:	5b                   	pop    %ebx
  8005bf:	5a                   	pop    %edx
  8005c0:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8005c1:	8b 1c 24             	mov    (%esp),%ebx
  8005c4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005c8:	89 ec                	mov    %ebp,%esp
  8005ca:	5d                   	pop    %ebp
  8005cb:	c3                   	ret    

008005cc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8005cc:	55                   	push   %ebp
  8005cd:	89 e5                	mov    %esp,%ebp
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	89 1c 24             	mov    %ebx,(%esp)
  8005d5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005de:	b8 04 00 00 00       	mov    $0x4,%eax
  8005e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e9:	89 df                	mov    %ebx,%edi
  8005eb:	51                   	push   %ecx
  8005ec:	52                   	push   %edx
  8005ed:	53                   	push   %ebx
  8005ee:	54                   	push   %esp
  8005ef:	55                   	push   %ebp
  8005f0:	56                   	push   %esi
  8005f1:	57                   	push   %edi
  8005f2:	54                   	push   %esp
  8005f3:	5d                   	pop    %ebp
  8005f4:	8d 35 fc 05 80 00    	lea    0x8005fc,%esi
  8005fa:	0f 34                	sysenter 
  8005fc:	5f                   	pop    %edi
  8005fd:	5e                   	pop    %esi
  8005fe:	5d                   	pop    %ebp
  8005ff:	5c                   	pop    %esp
  800600:	5b                   	pop    %ebx
  800601:	5a                   	pop    %edx
  800602:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800603:	8b 1c 24             	mov    (%esp),%ebx
  800606:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80060a:	89 ec                	mov    %ebp,%esp
  80060c:	5d                   	pop    %ebp
  80060d:	c3                   	ret    

0080060e <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80060e:	55                   	push   %ebp
  80060f:	89 e5                	mov    %esp,%ebp
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	89 1c 24             	mov    %ebx,(%esp)
  800617:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80061b:	ba 00 00 00 00       	mov    $0x0,%edx
  800620:	b8 02 00 00 00       	mov    $0x2,%eax
  800625:	89 d1                	mov    %edx,%ecx
  800627:	89 d3                	mov    %edx,%ebx
  800629:	89 d7                	mov    %edx,%edi
  80062b:	51                   	push   %ecx
  80062c:	52                   	push   %edx
  80062d:	53                   	push   %ebx
  80062e:	54                   	push   %esp
  80062f:	55                   	push   %ebp
  800630:	56                   	push   %esi
  800631:	57                   	push   %edi
  800632:	54                   	push   %esp
  800633:	5d                   	pop    %ebp
  800634:	8d 35 3c 06 80 00    	lea    0x80063c,%esi
  80063a:	0f 34                	sysenter 
  80063c:	5f                   	pop    %edi
  80063d:	5e                   	pop    %esi
  80063e:	5d                   	pop    %ebp
  80063f:	5c                   	pop    %esp
  800640:	5b                   	pop    %ebx
  800641:	5a                   	pop    %edx
  800642:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800643:	8b 1c 24             	mov    (%esp),%ebx
  800646:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80064a:	89 ec                	mov    %ebp,%esp
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	83 ec 28             	sub    $0x28,%esp
  800654:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800657:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	b8 03 00 00 00       	mov    $0x3,%eax
  800664:	8b 55 08             	mov    0x8(%ebp),%edx
  800667:	89 cb                	mov    %ecx,%ebx
  800669:	89 cf                	mov    %ecx,%edi
  80066b:	51                   	push   %ecx
  80066c:	52                   	push   %edx
  80066d:	53                   	push   %ebx
  80066e:	54                   	push   %esp
  80066f:	55                   	push   %ebp
  800670:	56                   	push   %esi
  800671:	57                   	push   %edi
  800672:	54                   	push   %esp
  800673:	5d                   	pop    %ebp
  800674:	8d 35 7c 06 80 00    	lea    0x80067c,%esi
  80067a:	0f 34                	sysenter 
  80067c:	5f                   	pop    %edi
  80067d:	5e                   	pop    %esi
  80067e:	5d                   	pop    %ebp
  80067f:	5c                   	pop    %esp
  800680:	5b                   	pop    %ebx
  800681:	5a                   	pop    %edx
  800682:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800683:	85 c0                	test   %eax,%eax
  800685:	7e 28                	jle    8006af <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800687:	89 44 24 10          	mov    %eax,0x10(%esp)
  80068b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800692:	00 
  800693:	c7 44 24 08 2a 21 80 	movl   $0x80212a,0x8(%esp)
  80069a:	00 
  80069b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8006a2:	00 
  8006a3:	c7 04 24 47 21 80 00 	movl   $0x802147,(%esp)
  8006aa:	e8 d5 08 00 00       	call   800f84 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8006af:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8006b2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006b5:	89 ec                	mov    %ebp,%esp
  8006b7:	5d                   	pop    %ebp
  8006b8:	c3                   	ret    
  8006b9:	00 00                	add    %al,(%eax)
  8006bb:	00 00                	add    %al,(%eax)
  8006bd:	00 00                	add    %al,(%eax)
	...

008006c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8006cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8006d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d9:	89 04 24             	mov    %eax,(%esp)
  8006dc:	e8 df ff ff ff       	call   8006c0 <fd2num>
  8006e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8006e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    

008006eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	57                   	push   %edi
  8006ef:	56                   	push   %esi
  8006f0:	53                   	push   %ebx
  8006f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8006f4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8006f9:	a8 01                	test   $0x1,%al
  8006fb:	74 36                	je     800733 <fd_alloc+0x48>
  8006fd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800702:	a8 01                	test   $0x1,%al
  800704:	74 2d                	je     800733 <fd_alloc+0x48>
  800706:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80070b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800710:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800715:	89 c3                	mov    %eax,%ebx
  800717:	89 c2                	mov    %eax,%edx
  800719:	c1 ea 16             	shr    $0x16,%edx
  80071c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80071f:	f6 c2 01             	test   $0x1,%dl
  800722:	74 14                	je     800738 <fd_alloc+0x4d>
  800724:	89 c2                	mov    %eax,%edx
  800726:	c1 ea 0c             	shr    $0xc,%edx
  800729:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80072c:	f6 c2 01             	test   $0x1,%dl
  80072f:	75 10                	jne    800741 <fd_alloc+0x56>
  800731:	eb 05                	jmp    800738 <fd_alloc+0x4d>
  800733:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800738:	89 1f                	mov    %ebx,(%edi)
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80073f:	eb 17                	jmp    800758 <fd_alloc+0x6d>
  800741:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800746:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80074b:	75 c8                	jne    800715 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80074d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800753:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5f                   	pop    %edi
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	83 f8 1f             	cmp    $0x1f,%eax
  800766:	77 36                	ja     80079e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800768:	05 00 00 0d 00       	add    $0xd0000,%eax
  80076d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800770:	89 c2                	mov    %eax,%edx
  800772:	c1 ea 16             	shr    $0x16,%edx
  800775:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80077c:	f6 c2 01             	test   $0x1,%dl
  80077f:	74 1d                	je     80079e <fd_lookup+0x41>
  800781:	89 c2                	mov    %eax,%edx
  800783:	c1 ea 0c             	shr    $0xc,%edx
  800786:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80078d:	f6 c2 01             	test   $0x1,%dl
  800790:	74 0c                	je     80079e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 02                	mov    %eax,(%edx)
  800797:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80079c:	eb 05                	jmp    8007a3 <fd_lookup+0x46>
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	89 04 24             	mov    %eax,(%esp)
  8007b8:	e8 a0 ff ff ff       	call   80075d <fd_lookup>
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 0e                	js     8007cf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8007c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c7:	89 50 04             	mov    %edx,0x4(%eax)
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	56                   	push   %esi
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 10             	sub    $0x10,%esp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8007df:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8007e4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007e9:	be d4 21 80 00       	mov    $0x8021d4,%esi
		if (devtab[i]->dev_id == dev_id) {
  8007ee:	39 08                	cmp    %ecx,(%eax)
  8007f0:	75 10                	jne    800802 <dev_lookup+0x31>
  8007f2:	eb 04                	jmp    8007f8 <dev_lookup+0x27>
  8007f4:	39 08                	cmp    %ecx,(%eax)
  8007f6:	75 0a                	jne    800802 <dev_lookup+0x31>
			*dev = devtab[i];
  8007f8:	89 03                	mov    %eax,(%ebx)
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8007ff:	90                   	nop
  800800:	eb 31                	jmp    800833 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	8b 04 96             	mov    (%esi,%edx,4),%eax
  800808:	85 c0                	test   %eax,%eax
  80080a:	75 e8                	jne    8007f4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80080c:	a1 04 40 80 00       	mov    0x804004,%eax
  800811:	8b 40 48             	mov    0x48(%eax),%eax
  800814:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	c7 04 24 58 21 80 00 	movl   $0x802158,(%esp)
  800823:	e8 15 08 00 00       	call   80103d <cprintf>
	*dev = 0;
  800828:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 24             	sub    $0x24,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	e8 07 ff ff ff       	call   80075d <fd_lookup>
  800856:	85 c0                	test   %eax,%eax
  800858:	78 53                	js     8008ad <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	8b 00                	mov    (%eax),%eax
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	e8 63 ff ff ff       	call   8007d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 3b                	js     8008ad <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800872:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800877:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80087a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80087e:	74 2d                	je     8008ad <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800880:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800883:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088a:	00 00 00 
	stat->st_isdir = 0;
  80088d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800894:	00 00 00 
	stat->st_dev = dev;
  800897:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008a7:	89 14 24             	mov    %edx,(%esp)
  8008aa:	ff 50 14             	call   *0x14(%eax)
}
  8008ad:	83 c4 24             	add    $0x24,%esp
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	83 ec 24             	sub    $0x24,%esp
  8008ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c4:	89 1c 24             	mov    %ebx,(%esp)
  8008c7:	e8 91 fe ff ff       	call   80075d <fd_lookup>
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 5f                	js     80092f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008da:	8b 00                	mov    (%eax),%eax
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	e8 ed fe ff ff       	call   8007d1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 47                	js     80092f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008eb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8008ef:	75 23                	jne    800914 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008f1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008f6:	8b 40 48             	mov    0x48(%eax),%eax
  8008f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800901:	c7 04 24 78 21 80 00 	movl   $0x802178,(%esp)
  800908:	e8 30 07 00 00       	call   80103d <cprintf>
  80090d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800912:	eb 1b                	jmp    80092f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800914:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800917:	8b 48 18             	mov    0x18(%eax),%ecx
  80091a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80091f:	85 c9                	test   %ecx,%ecx
  800921:	74 0c                	je     80092f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	89 14 24             	mov    %edx,(%esp)
  80092d:	ff d1                	call   *%ecx
}
  80092f:	83 c4 24             	add    $0x24,%esp
  800932:	5b                   	pop    %ebx
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	83 ec 24             	sub    $0x24,%esp
  80093c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80093f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800942:	89 44 24 04          	mov    %eax,0x4(%esp)
  800946:	89 1c 24             	mov    %ebx,(%esp)
  800949:	e8 0f fe ff ff       	call   80075d <fd_lookup>
  80094e:	85 c0                	test   %eax,%eax
  800950:	78 66                	js     8009b8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800952:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800955:	89 44 24 04          	mov    %eax,0x4(%esp)
  800959:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095c:	8b 00                	mov    (%eax),%eax
  80095e:	89 04 24             	mov    %eax,(%esp)
  800961:	e8 6b fe ff ff       	call   8007d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800966:	85 c0                	test   %eax,%eax
  800968:	78 4e                	js     8009b8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80096a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80096d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800971:	75 23                	jne    800996 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800973:	a1 04 40 80 00       	mov    0x804004,%eax
  800978:	8b 40 48             	mov    0x48(%eax),%eax
  80097b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80097f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800983:	c7 04 24 99 21 80 00 	movl   $0x802199,(%esp)
  80098a:	e8 ae 06 00 00       	call   80103d <cprintf>
  80098f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800994:	eb 22                	jmp    8009b8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800996:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800999:	8b 48 0c             	mov    0xc(%eax),%ecx
  80099c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8009a1:	85 c9                	test   %ecx,%ecx
  8009a3:	74 13                	je     8009b8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8009a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b3:	89 14 24             	mov    %edx,(%esp)
  8009b6:	ff d1                	call   *%ecx
}
  8009b8:	83 c4 24             	add    $0x24,%esp
  8009bb:	5b                   	pop    %ebx
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	53                   	push   %ebx
  8009c2:	83 ec 24             	sub    $0x24,%esp
  8009c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	89 1c 24             	mov    %ebx,(%esp)
  8009d2:	e8 86 fd ff ff       	call   80075d <fd_lookup>
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	78 6b                	js     800a46 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009e5:	8b 00                	mov    (%eax),%eax
  8009e7:	89 04 24             	mov    %eax,(%esp)
  8009ea:	e8 e2 fd ff ff       	call   8007d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	78 53                	js     800a46 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009f6:	8b 42 08             	mov    0x8(%edx),%eax
  8009f9:	83 e0 03             	and    $0x3,%eax
  8009fc:	83 f8 01             	cmp    $0x1,%eax
  8009ff:	75 23                	jne    800a24 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a01:	a1 04 40 80 00       	mov    0x804004,%eax
  800a06:	8b 40 48             	mov    0x48(%eax),%eax
  800a09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a11:	c7 04 24 b6 21 80 00 	movl   $0x8021b6,(%esp)
  800a18:	e8 20 06 00 00       	call   80103d <cprintf>
  800a1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800a22:	eb 22                	jmp    800a46 <read+0x88>
	}
	if (!dev->dev_read)
  800a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a27:	8b 48 08             	mov    0x8(%eax),%ecx
  800a2a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a2f:	85 c9                	test   %ecx,%ecx
  800a31:	74 13                	je     800a46 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a33:	8b 45 10             	mov    0x10(%ebp),%eax
  800a36:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a41:	89 14 24             	mov    %edx,(%esp)
  800a44:	ff d1                	call   *%ecx
}
  800a46:	83 c4 24             	add    $0x24,%esp
  800a49:	5b                   	pop    %ebx
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	83 ec 1c             	sub    $0x1c,%esp
  800a55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a58:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6a:	85 f6                	test   %esi,%esi
  800a6c:	74 29                	je     800a97 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a6e:	89 f0                	mov    %esi,%eax
  800a70:	29 d0                	sub    %edx,%eax
  800a72:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a76:	03 55 0c             	add    0xc(%ebp),%edx
  800a79:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a7d:	89 3c 24             	mov    %edi,(%esp)
  800a80:	e8 39 ff ff ff       	call   8009be <read>
		if (m < 0)
  800a85:	85 c0                	test   %eax,%eax
  800a87:	78 0e                	js     800a97 <readn+0x4b>
			return m;
		if (m == 0)
  800a89:	85 c0                	test   %eax,%eax
  800a8b:	74 08                	je     800a95 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a8d:	01 c3                	add    %eax,%ebx
  800a8f:	89 da                	mov    %ebx,%edx
  800a91:	39 f3                	cmp    %esi,%ebx
  800a93:	72 d9                	jb     800a6e <readn+0x22>
  800a95:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a97:	83 c4 1c             	add    $0x1c,%esp
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 20             	sub    $0x20,%esp
  800aa7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800aaa:	89 34 24             	mov    %esi,(%esp)
  800aad:	e8 0e fc ff ff       	call   8006c0 <fd2num>
  800ab2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ab5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab9:	89 04 24             	mov    %eax,(%esp)
  800abc:	e8 9c fc ff ff       	call   80075d <fd_lookup>
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	78 05                	js     800acc <fd_close+0x2d>
  800ac7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800aca:	74 0c                	je     800ad8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800acc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800ad0:	19 c0                	sbb    %eax,%eax
  800ad2:	f7 d0                	not    %eax
  800ad4:	21 c3                	and    %eax,%ebx
  800ad6:	eb 3d                	jmp    800b15 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ad8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adf:	8b 06                	mov    (%esi),%eax
  800ae1:	89 04 24             	mov    %eax,(%esp)
  800ae4:	e8 e8 fc ff ff       	call   8007d1 <dev_lookup>
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	78 16                	js     800b05 <fd_close+0x66>
		if (dev->dev_close)
  800aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af2:	8b 40 10             	mov    0x10(%eax),%eax
  800af5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800afa:	85 c0                	test   %eax,%eax
  800afc:	74 07                	je     800b05 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800afe:	89 34 24             	mov    %esi,(%esp)
  800b01:	ff d0                	call   *%eax
  800b03:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800b05:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b10:	e8 30 f9 ff ff       	call   800445 <sys_page_unmap>
	return r;
}
  800b15:	89 d8                	mov    %ebx,%eax
  800b17:	83 c4 20             	add    $0x20,%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	89 04 24             	mov    %eax,(%esp)
  800b31:	e8 27 fc ff ff       	call   80075d <fd_lookup>
  800b36:	85 c0                	test   %eax,%eax
  800b38:	78 13                	js     800b4d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800b3a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800b41:	00 
  800b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b45:	89 04 24             	mov    %eax,(%esp)
  800b48:	e8 52 ff ff ff       	call   800a9f <fd_close>
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 18             	sub    $0x18,%esp
  800b55:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b58:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b62:	00 
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	89 04 24             	mov    %eax,(%esp)
  800b69:	e8 79 03 00 00       	call   800ee7 <open>
  800b6e:	89 c3                	mov    %eax,%ebx
  800b70:	85 c0                	test   %eax,%eax
  800b72:	78 1b                	js     800b8f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7b:	89 1c 24             	mov    %ebx,(%esp)
  800b7e:	e8 b7 fc ff ff       	call   80083a <fstat>
  800b83:	89 c6                	mov    %eax,%esi
	close(fd);
  800b85:	89 1c 24             	mov    %ebx,(%esp)
  800b88:	e8 91 ff ff ff       	call   800b1e <close>
  800b8d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800b8f:	89 d8                	mov    %ebx,%eax
  800b91:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b94:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b97:	89 ec                	mov    %ebp,%esp
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 14             	sub    $0x14,%esp
  800ba2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800ba7:	89 1c 24             	mov    %ebx,(%esp)
  800baa:	e8 6f ff ff ff       	call   800b1e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800baf:	83 c3 01             	add    $0x1,%ebx
  800bb2:	83 fb 20             	cmp    $0x20,%ebx
  800bb5:	75 f0                	jne    800ba7 <close_all+0xc>
		close(i);
}
  800bb7:	83 c4 14             	add    $0x14,%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	83 ec 58             	sub    $0x58,%esp
  800bc3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bc6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bc9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bcc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800bcf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	89 04 24             	mov    %eax,(%esp)
  800bdc:	e8 7c fb ff ff       	call   80075d <fd_lookup>
  800be1:	89 c3                	mov    %eax,%ebx
  800be3:	85 c0                	test   %eax,%eax
  800be5:	0f 88 e0 00 00 00    	js     800ccb <dup+0x10e>
		return r;
	close(newfdnum);
  800beb:	89 3c 24             	mov    %edi,(%esp)
  800bee:	e8 2b ff ff ff       	call   800b1e <close>

	newfd = INDEX2FD(newfdnum);
  800bf3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800bf9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800bfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bff:	89 04 24             	mov    %eax,(%esp)
  800c02:	e8 c9 fa ff ff       	call   8006d0 <fd2data>
  800c07:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800c09:	89 34 24             	mov    %esi,(%esp)
  800c0c:	e8 bf fa ff ff       	call   8006d0 <fd2data>
  800c11:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800c14:	89 da                	mov    %ebx,%edx
  800c16:	89 d8                	mov    %ebx,%eax
  800c18:	c1 e8 16             	shr    $0x16,%eax
  800c1b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800c22:	a8 01                	test   $0x1,%al
  800c24:	74 43                	je     800c69 <dup+0xac>
  800c26:	c1 ea 0c             	shr    $0xc,%edx
  800c29:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c30:	a8 01                	test   $0x1,%al
  800c32:	74 35                	je     800c69 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800c34:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c3b:	25 07 0e 00 00       	and    $0xe07,%eax
  800c40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c44:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c52:	00 
  800c53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c5e:	e8 4e f8 ff ff       	call   8004b1 <sys_page_map>
  800c63:	89 c3                	mov    %eax,%ebx
  800c65:	85 c0                	test   %eax,%eax
  800c67:	78 3f                	js     800ca8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c6c:	89 c2                	mov    %eax,%edx
  800c6e:	c1 ea 0c             	shr    $0xc,%edx
  800c71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800c78:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800c7e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c82:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c8d:	00 
  800c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c99:	e8 13 f8 ff ff       	call   8004b1 <sys_page_map>
  800c9e:	89 c3                	mov    %eax,%ebx
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	78 04                	js     800ca8 <dup+0xeb>
  800ca4:	89 fb                	mov    %edi,%ebx
  800ca6:	eb 23                	jmp    800ccb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ca8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cb3:	e8 8d f7 ff ff       	call   800445 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800cb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cc6:	e8 7a f7 ff ff       	call   800445 <sys_page_unmap>
	return r;
}
  800ccb:	89 d8                	mov    %ebx,%eax
  800ccd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd6:	89 ec                	mov    %ebp,%esp
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    
	...

00800cdc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 18             	sub    $0x18,%esp
  800ce2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ce5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800ce8:	89 c3                	mov    %eax,%ebx
  800cea:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800cec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cf3:	75 11                	jne    800d06 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cf5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800cfc:	e8 5f 10 00 00       	call   801d60 <ipc_find_env>
  800d01:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d06:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800d15:	00 
  800d16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d1a:	a1 00 40 80 00       	mov    0x804000,%eax
  800d1f:	89 04 24             	mov    %eax,(%esp)
  800d22:	e8 84 10 00 00       	call   801dab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d2e:	00 
  800d2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d3a:	e8 ea 10 00 00       	call   801e29 <ipc_recv>
}
  800d3f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d42:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d45:	89 ec                	mov    %ebp,%esp
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	8b 40 0c             	mov    0xc(%eax),%eax
  800d55:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d62:	ba 00 00 00 00       	mov    $0x0,%edx
  800d67:	b8 02 00 00 00       	mov    $0x2,%eax
  800d6c:	e8 6b ff ff ff       	call   800cdc <fsipc>
}
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    

00800d73 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	8b 40 0c             	mov    0xc(%eax),%eax
  800d7f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d84:	ba 00 00 00 00       	mov    $0x0,%edx
  800d89:	b8 06 00 00 00       	mov    $0x6,%eax
  800d8e:	e8 49 ff ff ff       	call   800cdc <fsipc>
}
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 08 00 00 00       	mov    $0x8,%eax
  800da5:	e8 32 ff ff ff       	call   800cdc <fsipc>
}
  800daa:	c9                   	leave  
  800dab:	c3                   	ret    

00800dac <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	53                   	push   %ebx
  800db0:	83 ec 14             	sub    $0x14,%esp
  800db3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	8b 40 0c             	mov    0xc(%eax),%eax
  800dbc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800dc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dcb:	e8 0c ff ff ff       	call   800cdc <fsipc>
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	78 2b                	js     800dff <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800dd4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ddb:	00 
  800ddc:	89 1c 24             	mov    %ebx,(%esp)
  800ddf:	e8 86 0b 00 00       	call   80196a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800de4:	a1 80 50 80 00       	mov    0x805080,%eax
  800de9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800def:	a1 84 50 80 00       	mov    0x805084,%eax
  800df4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800dff:	83 c4 14             	add    $0x14,%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 18             	sub    $0x18,%esp
  800e0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e13:	76 05                	jbe    800e1a <devfile_write+0x15>
  800e15:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 52 0c             	mov    0xc(%edx),%edx
  800e20:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800e26:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800e2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e36:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800e3d:	e8 13 0d 00 00       	call   801b55 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800e42:	ba 00 00 00 00       	mov    $0x0,%edx
  800e47:	b8 04 00 00 00       	mov    $0x4,%eax
  800e4c:	e8 8b fe ff ff       	call   800cdc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e60:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800e65:	8b 45 10             	mov    0x10(%ebp),%eax
  800e68:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  800e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e72:	b8 03 00 00 00       	mov    $0x3,%eax
  800e77:	e8 60 fe ff ff       	call   800cdc <fsipc>
  800e7c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	78 17                	js     800e99 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800e82:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e86:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800e8d:	00 
  800e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e91:	89 04 24             	mov    %eax,(%esp)
  800e94:	e8 bc 0c 00 00       	call   801b55 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800e99:	89 d8                	mov    %ebx,%eax
  800e9b:	83 c4 14             	add    $0x14,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 14             	sub    $0x14,%esp
  800ea8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800eab:	89 1c 24             	mov    %ebx,(%esp)
  800eae:	e8 6d 0a 00 00       	call   801920 <strlen>
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800eba:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800ec0:	7f 1f                	jg     800ee1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800ec2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ec6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800ecd:	e8 98 0a 00 00       	call   80196a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed7:	b8 07 00 00 00       	mov    $0x7,%eax
  800edc:	e8 fb fd ff ff       	call   800cdc <fsipc>
}
  800ee1:	83 c4 14             	add    $0x14,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 28             	sub    $0x28,%esp
  800eed:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ef0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800ef3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  800ef6:	89 34 24             	mov    %esi,(%esp)
  800ef9:	e8 22 0a 00 00       	call   801920 <strlen>
  800efe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f03:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f08:	7f 6d                	jg     800f77 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  800f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0d:	89 04 24             	mov    %eax,(%esp)
  800f10:	e8 d6 f7 ff ff       	call   8006eb <fd_alloc>
  800f15:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 5c                	js     800f77 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  800f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  800f23:	89 34 24             	mov    %esi,(%esp)
  800f26:	e8 f5 09 00 00       	call   801920 <strlen>
  800f2b:	83 c0 01             	add    $0x1,%eax
  800f2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f32:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f36:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800f3d:	e8 13 0c 00 00       	call   801b55 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  800f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f45:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4a:	e8 8d fd ff ff       	call   800cdc <fsipc>
  800f4f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  800f51:	85 c0                	test   %eax,%eax
  800f53:	79 15                	jns    800f6a <open+0x83>
             fd_close(fd,0);
  800f55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5c:	00 
  800f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f60:	89 04 24             	mov    %eax,(%esp)
  800f63:	e8 37 fb ff ff       	call   800a9f <fd_close>
             return r;
  800f68:	eb 0d                	jmp    800f77 <open+0x90>
        }
        return fd2num(fd);
  800f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6d:	89 04 24             	mov    %eax,(%esp)
  800f70:	e8 4b f7 ff ff       	call   8006c0 <fd2num>
  800f75:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  800f77:	89 d8                	mov    %ebx,%eax
  800f79:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f7c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800f7f:	89 ec                	mov    %ebp,%esp
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
	...

00800f84 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f8c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f8f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800f95:	e8 74 f6 ff ff       	call   80060e <sys_getenvid>
  800f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb0:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  800fb7:	e8 81 00 00 00       	call   80103d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fbc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc3:	89 04 24             	mov    %eax,(%esp)
  800fc6:	e8 11 00 00 00       	call   800fdc <vcprintf>
	cprintf("\n");
  800fcb:	c7 04 24 d0 21 80 00 	movl   $0x8021d0,(%esp)
  800fd2:	e8 66 00 00 00       	call   80103d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fd7:	cc                   	int3   
  800fd8:	eb fd                	jmp    800fd7 <_panic+0x53>
	...

00800fdc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800fe5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800fec:	00 00 00 
	b.cnt = 0;
  800fef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ff6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801000:	8b 45 08             	mov    0x8(%ebp),%eax
  801003:	89 44 24 08          	mov    %eax,0x8(%esp)
  801007:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80100d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801011:	c7 04 24 57 10 80 00 	movl   $0x801057,(%esp)
  801018:	e8 cf 01 00 00       	call   8011ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80101d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801023:	89 44 24 04          	mov    %eax,0x4(%esp)
  801027:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80102d:	89 04 24             	mov    %eax,(%esp)
  801030:	e8 f3 f0 ff ff       	call   800128 <sys_cputs>

	return b.cnt;
}
  801035:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80103b:	c9                   	leave  
  80103c:	c3                   	ret    

0080103d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801043:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104a:	8b 45 08             	mov    0x8(%ebp),%eax
  80104d:	89 04 24             	mov    %eax,(%esp)
  801050:	e8 87 ff ff ff       	call   800fdc <vcprintf>
	va_end(ap);

	return cnt;
}
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	53                   	push   %ebx
  80105b:	83 ec 14             	sub    $0x14,%esp
  80105e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801061:	8b 03                	mov    (%ebx),%eax
  801063:	8b 55 08             	mov    0x8(%ebp),%edx
  801066:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80106a:	83 c0 01             	add    $0x1,%eax
  80106d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80106f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801074:	75 19                	jne    80108f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801076:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80107d:	00 
  80107e:	8d 43 08             	lea    0x8(%ebx),%eax
  801081:	89 04 24             	mov    %eax,(%esp)
  801084:	e8 9f f0 ff ff       	call   800128 <sys_cputs>
		b->idx = 0;
  801089:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80108f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801093:	83 c4 14             	add    $0x14,%esp
  801096:	5b                   	pop    %ebx
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    
  801099:	00 00                	add    %al,(%eax)
  80109b:	00 00                	add    %al,(%eax)
  80109d:	00 00                	add    %al,(%eax)
	...

008010a0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 4c             	sub    $0x4c,%esp
  8010a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010ac:	89 d6                	mov    %edx,%esi
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8010ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010c0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8010c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010cb:	39 d1                	cmp    %edx,%ecx
  8010cd:	72 07                	jb     8010d6 <printnum_v2+0x36>
  8010cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8010d2:	39 d0                	cmp    %edx,%eax
  8010d4:	77 5f                	ja     801135 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8010d6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8010da:	83 eb 01             	sub    $0x1,%ebx
  8010dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010e9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8010ed:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8010f0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8010f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8010f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801101:	00 
  801102:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801105:	89 04 24             	mov    %eax,(%esp)
  801108:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80110b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80110f:	e8 8c 0d 00 00       	call   801ea0 <__udivdi3>
  801114:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801117:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80111a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80111e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801122:	89 04 24             	mov    %eax,(%esp)
  801125:	89 54 24 04          	mov    %edx,0x4(%esp)
  801129:	89 f2                	mov    %esi,%edx
  80112b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112e:	e8 6d ff ff ff       	call   8010a0 <printnum_v2>
  801133:	eb 1e                	jmp    801153 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801135:	83 ff 2d             	cmp    $0x2d,%edi
  801138:	74 19                	je     801153 <printnum_v2+0xb3>
		while (--width > 0)
  80113a:	83 eb 01             	sub    $0x1,%ebx
  80113d:	85 db                	test   %ebx,%ebx
  80113f:	90                   	nop
  801140:	7e 11                	jle    801153 <printnum_v2+0xb3>
			putch(padc, putdat);
  801142:	89 74 24 04          	mov    %esi,0x4(%esp)
  801146:	89 3c 24             	mov    %edi,(%esp)
  801149:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80114c:	83 eb 01             	sub    $0x1,%ebx
  80114f:	85 db                	test   %ebx,%ebx
  801151:	7f ef                	jg     801142 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801153:	89 74 24 04          	mov    %esi,0x4(%esp)
  801157:	8b 74 24 04          	mov    0x4(%esp),%esi
  80115b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80115e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801162:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801169:	00 
  80116a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80116d:	89 14 24             	mov    %edx,(%esp)
  801170:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801173:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801177:	e8 54 0e 00 00       	call   801fd0 <__umoddi3>
  80117c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801180:	0f be 80 ff 21 80 00 	movsbl 0x8021ff(%eax),%eax
  801187:	89 04 24             	mov    %eax,(%esp)
  80118a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80118d:	83 c4 4c             	add    $0x4c,%esp
  801190:	5b                   	pop    %ebx
  801191:	5e                   	pop    %esi
  801192:	5f                   	pop    %edi
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    

00801195 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801198:	83 fa 01             	cmp    $0x1,%edx
  80119b:	7e 0e                	jle    8011ab <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80119d:	8b 10                	mov    (%eax),%edx
  80119f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011a2:	89 08                	mov    %ecx,(%eax)
  8011a4:	8b 02                	mov    (%edx),%eax
  8011a6:	8b 52 04             	mov    0x4(%edx),%edx
  8011a9:	eb 22                	jmp    8011cd <getuint+0x38>
	else if (lflag)
  8011ab:	85 d2                	test   %edx,%edx
  8011ad:	74 10                	je     8011bf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011af:	8b 10                	mov    (%eax),%edx
  8011b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b4:	89 08                	mov    %ecx,(%eax)
  8011b6:	8b 02                	mov    (%edx),%eax
  8011b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011bd:	eb 0e                	jmp    8011cd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011bf:	8b 10                	mov    (%eax),%edx
  8011c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c4:	89 08                	mov    %ecx,(%eax)
  8011c6:	8b 02                	mov    (%edx),%eax
  8011c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011d9:	8b 10                	mov    (%eax),%edx
  8011db:	3b 50 04             	cmp    0x4(%eax),%edx
  8011de:	73 0a                	jae    8011ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8011e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e3:	88 0a                	mov    %cl,(%edx)
  8011e5:	83 c2 01             	add    $0x1,%edx
  8011e8:	89 10                	mov    %edx,(%eax)
}
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	57                   	push   %edi
  8011f0:	56                   	push   %esi
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 6c             	sub    $0x6c,%esp
  8011f5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8011f8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8011ff:	eb 1a                	jmp    80121b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 84 66 06 00 00    	je     80186f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  801209:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801210:	89 04 24             	mov    %eax,(%esp)
  801213:	ff 55 08             	call   *0x8(%ebp)
  801216:	eb 03                	jmp    80121b <vprintfmt+0x2f>
  801218:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80121b:	0f b6 07             	movzbl (%edi),%eax
  80121e:	83 c7 01             	add    $0x1,%edi
  801221:	83 f8 25             	cmp    $0x25,%eax
  801224:	75 db                	jne    801201 <vprintfmt+0x15>
  801226:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80122a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801236:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80123b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801242:	be 00 00 00 00       	mov    $0x0,%esi
  801247:	eb 06                	jmp    80124f <vprintfmt+0x63>
  801249:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80124d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80124f:	0f b6 17             	movzbl (%edi),%edx
  801252:	0f b6 c2             	movzbl %dl,%eax
  801255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801258:	8d 47 01             	lea    0x1(%edi),%eax
  80125b:	83 ea 23             	sub    $0x23,%edx
  80125e:	80 fa 55             	cmp    $0x55,%dl
  801261:	0f 87 60 05 00 00    	ja     8017c7 <vprintfmt+0x5db>
  801267:	0f b6 d2             	movzbl %dl,%edx
  80126a:	ff 24 95 e0 23 80 00 	jmp    *0x8023e0(,%edx,4)
  801271:	b9 01 00 00 00       	mov    $0x1,%ecx
  801276:	eb d5                	jmp    80124d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801278:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80127b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80127e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801281:	8d 7a d0             	lea    -0x30(%edx),%edi
  801284:	83 ff 09             	cmp    $0x9,%edi
  801287:	76 08                	jbe    801291 <vprintfmt+0xa5>
  801289:	eb 40                	jmp    8012cb <vprintfmt+0xdf>
  80128b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80128f:	eb bc                	jmp    80124d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801291:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801294:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  801297:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80129b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80129e:	8d 7a d0             	lea    -0x30(%edx),%edi
  8012a1:	83 ff 09             	cmp    $0x9,%edi
  8012a4:	76 eb                	jbe    801291 <vprintfmt+0xa5>
  8012a6:	eb 23                	jmp    8012cb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012ab:	8d 5a 04             	lea    0x4(%edx),%ebx
  8012ae:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8012b1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8012b3:	eb 16                	jmp    8012cb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8012b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012b8:	c1 fa 1f             	sar    $0x1f,%edx
  8012bb:	f7 d2                	not    %edx
  8012bd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8012c0:	eb 8b                	jmp    80124d <vprintfmt+0x61>
  8012c2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8012c9:	eb 82                	jmp    80124d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8012cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8012cf:	0f 89 78 ff ff ff    	jns    80124d <vprintfmt+0x61>
  8012d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8012d8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8012db:	e9 6d ff ff ff       	jmp    80124d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012e0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8012e3:	e9 65 ff ff ff       	jmp    80124d <vprintfmt+0x61>
  8012e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ee:	8d 50 04             	lea    0x4(%eax),%edx
  8012f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012fb:	8b 00                	mov    (%eax),%eax
  8012fd:	89 04 24             	mov    %eax,(%esp)
  801300:	ff 55 08             	call   *0x8(%ebp)
  801303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801306:	e9 10 ff ff ff       	jmp    80121b <vprintfmt+0x2f>
  80130b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80130e:	8b 45 14             	mov    0x14(%ebp),%eax
  801311:	8d 50 04             	lea    0x4(%eax),%edx
  801314:	89 55 14             	mov    %edx,0x14(%ebp)
  801317:	8b 00                	mov    (%eax),%eax
  801319:	89 c2                	mov    %eax,%edx
  80131b:	c1 fa 1f             	sar    $0x1f,%edx
  80131e:	31 d0                	xor    %edx,%eax
  801320:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801322:	83 f8 0f             	cmp    $0xf,%eax
  801325:	7f 0b                	jg     801332 <vprintfmt+0x146>
  801327:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  80132e:	85 d2                	test   %edx,%edx
  801330:	75 26                	jne    801358 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801336:	c7 44 24 08 10 22 80 	movl   $0x802210,0x8(%esp)
  80133d:	00 
  80133e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801341:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801345:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801348:	89 1c 24             	mov    %ebx,(%esp)
  80134b:	e8 a7 05 00 00       	call   8018f7 <printfmt>
  801350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801353:	e9 c3 fe ff ff       	jmp    80121b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801358:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80135c:	c7 44 24 08 19 22 80 	movl   $0x802219,0x8(%esp)
  801363:	00 
  801364:	8b 45 0c             	mov    0xc(%ebp),%eax
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	8b 55 08             	mov    0x8(%ebp),%edx
  80136e:	89 14 24             	mov    %edx,(%esp)
  801371:	e8 81 05 00 00       	call   8018f7 <printfmt>
  801376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801379:	e9 9d fe ff ff       	jmp    80121b <vprintfmt+0x2f>
  80137e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801381:	89 c7                	mov    %eax,%edi
  801383:	89 d9                	mov    %ebx,%ecx
  801385:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801388:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138b:	8b 45 14             	mov    0x14(%ebp),%eax
  80138e:	8d 50 04             	lea    0x4(%eax),%edx
  801391:	89 55 14             	mov    %edx,0x14(%ebp)
  801394:	8b 30                	mov    (%eax),%esi
  801396:	85 f6                	test   %esi,%esi
  801398:	75 05                	jne    80139f <vprintfmt+0x1b3>
  80139a:	be 1c 22 80 00       	mov    $0x80221c,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80139f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8013a3:	7e 06                	jle    8013ab <vprintfmt+0x1bf>
  8013a5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8013a9:	75 10                	jne    8013bb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013ab:	0f be 06             	movsbl (%esi),%eax
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	0f 85 a2 00 00 00    	jne    801458 <vprintfmt+0x26c>
  8013b6:	e9 92 00 00 00       	jmp    80144d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013bf:	89 34 24             	mov    %esi,(%esp)
  8013c2:	e8 74 05 00 00       	call   80193b <strnlen>
  8013c7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8013ca:	29 c2                	sub    %eax,%edx
  8013cc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8013cf:	85 d2                	test   %edx,%edx
  8013d1:	7e d8                	jle    8013ab <vprintfmt+0x1bf>
					putch(padc, putdat);
  8013d3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8013d7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8013da:	89 d3                	mov    %edx,%ebx
  8013dc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8013df:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8013e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013e5:	89 ce                	mov    %ecx,%esi
  8013e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013eb:	89 34 24             	mov    %esi,(%esp)
  8013ee:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f1:	83 eb 01             	sub    $0x1,%ebx
  8013f4:	85 db                	test   %ebx,%ebx
  8013f6:	7f ef                	jg     8013e7 <vprintfmt+0x1fb>
  8013f8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8013fb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013fe:	8b 7d bc             	mov    -0x44(%ebp),%edi
  801401:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801408:	eb a1                	jmp    8013ab <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80140a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80140e:	74 1b                	je     80142b <vprintfmt+0x23f>
  801410:	8d 50 e0             	lea    -0x20(%eax),%edx
  801413:	83 fa 5e             	cmp    $0x5e,%edx
  801416:	76 13                	jbe    80142b <vprintfmt+0x23f>
					putch('?', putdat);
  801418:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801426:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801429:	eb 0d                	jmp    801438 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80142b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801432:	89 04 24             	mov    %eax,(%esp)
  801435:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801438:	83 ef 01             	sub    $0x1,%edi
  80143b:	0f be 06             	movsbl (%esi),%eax
  80143e:	85 c0                	test   %eax,%eax
  801440:	74 05                	je     801447 <vprintfmt+0x25b>
  801442:	83 c6 01             	add    $0x1,%esi
  801445:	eb 1a                	jmp    801461 <vprintfmt+0x275>
  801447:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80144a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80144d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801451:	7f 1f                	jg     801472 <vprintfmt+0x286>
  801453:	e9 c0 fd ff ff       	jmp    801218 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801458:	83 c6 01             	add    $0x1,%esi
  80145b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80145e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801461:	85 db                	test   %ebx,%ebx
  801463:	78 a5                	js     80140a <vprintfmt+0x21e>
  801465:	83 eb 01             	sub    $0x1,%ebx
  801468:	79 a0                	jns    80140a <vprintfmt+0x21e>
  80146a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80146d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801470:	eb db                	jmp    80144d <vprintfmt+0x261>
  801472:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801475:	8b 75 0c             	mov    0xc(%ebp),%esi
  801478:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80147b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80147e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801482:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801489:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80148b:	83 eb 01             	sub    $0x1,%ebx
  80148e:	85 db                	test   %ebx,%ebx
  801490:	7f ec                	jg     80147e <vprintfmt+0x292>
  801492:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801495:	e9 81 fd ff ff       	jmp    80121b <vprintfmt+0x2f>
  80149a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80149d:	83 fe 01             	cmp    $0x1,%esi
  8014a0:	7e 10                	jle    8014b2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8014a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a5:	8d 50 08             	lea    0x8(%eax),%edx
  8014a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ab:	8b 18                	mov    (%eax),%ebx
  8014ad:	8b 70 04             	mov    0x4(%eax),%esi
  8014b0:	eb 26                	jmp    8014d8 <vprintfmt+0x2ec>
	else if (lflag)
  8014b2:	85 f6                	test   %esi,%esi
  8014b4:	74 12                	je     8014c8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8014b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b9:	8d 50 04             	lea    0x4(%eax),%edx
  8014bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8014bf:	8b 18                	mov    (%eax),%ebx
  8014c1:	89 de                	mov    %ebx,%esi
  8014c3:	c1 fe 1f             	sar    $0x1f,%esi
  8014c6:	eb 10                	jmp    8014d8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cb:	8d 50 04             	lea    0x4(%eax),%edx
  8014ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d1:	8b 18                	mov    (%eax),%ebx
  8014d3:	89 de                	mov    %ebx,%esi
  8014d5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8014d8:	83 f9 01             	cmp    $0x1,%ecx
  8014db:	75 1e                	jne    8014fb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8014dd:	85 f6                	test   %esi,%esi
  8014df:	78 1a                	js     8014fb <vprintfmt+0x30f>
  8014e1:	85 f6                	test   %esi,%esi
  8014e3:	7f 05                	jg     8014ea <vprintfmt+0x2fe>
  8014e5:	83 fb 00             	cmp    $0x0,%ebx
  8014e8:	76 11                	jbe    8014fb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8014ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014f1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8014f8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8014fb:	85 f6                	test   %esi,%esi
  8014fd:	78 13                	js     801512 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014ff:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  801502:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  801505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801508:	b8 0a 00 00 00       	mov    $0xa,%eax
  80150d:	e9 da 00 00 00       	jmp    8015ec <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  801512:	8b 45 0c             	mov    0xc(%ebp),%eax
  801515:	89 44 24 04          	mov    %eax,0x4(%esp)
  801519:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801520:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801523:	89 da                	mov    %ebx,%edx
  801525:	89 f1                	mov    %esi,%ecx
  801527:	f7 da                	neg    %edx
  801529:	83 d1 00             	adc    $0x0,%ecx
  80152c:	f7 d9                	neg    %ecx
  80152e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801531:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801534:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801537:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153c:	e9 ab 00 00 00       	jmp    8015ec <vprintfmt+0x400>
  801541:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801544:	89 f2                	mov    %esi,%edx
  801546:	8d 45 14             	lea    0x14(%ebp),%eax
  801549:	e8 47 fc ff ff       	call   801195 <getuint>
  80154e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801551:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801554:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801557:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80155c:	e9 8b 00 00 00       	jmp    8015ec <vprintfmt+0x400>
  801561:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801564:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801567:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80156b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801572:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801575:	89 f2                	mov    %esi,%edx
  801577:	8d 45 14             	lea    0x14(%ebp),%eax
  80157a:	e8 16 fc ff ff       	call   801195 <getuint>
  80157f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801582:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801585:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801588:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80158d:	eb 5d                	jmp    8015ec <vprintfmt+0x400>
  80158f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801595:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801599:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8015a0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8015a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8015ae:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8015b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b4:	8d 50 04             	lea    0x4(%eax),%edx
  8015b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8015ba:	8b 10                	mov    (%eax),%edx
  8015bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8015c4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8015c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015ca:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015cf:	eb 1b                	jmp    8015ec <vprintfmt+0x400>
  8015d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d4:	89 f2                	mov    %esi,%edx
  8015d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d9:	e8 b7 fb ff ff       	call   801195 <getuint>
  8015de:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8015e1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8015e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015ec:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8015f0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8015f6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8015fa:	77 09                	ja     801605 <vprintfmt+0x419>
  8015fc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8015ff:	0f 82 ac 00 00 00    	jb     8016b1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801605:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801608:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80160c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80160f:	83 ea 01             	sub    $0x1,%edx
  801612:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801616:	89 44 24 08          	mov    %eax,0x8(%esp)
  80161a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80161e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801622:	89 45 c0             	mov    %eax,-0x40(%ebp)
  801625:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801628:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80162b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80162f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801636:	00 
  801637:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80163a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80163d:	89 0c 24             	mov    %ecx,(%esp)
  801640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801644:	e8 57 08 00 00       	call   801ea0 <__udivdi3>
  801649:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80164c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80164f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801653:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80165e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801661:	8b 45 08             	mov    0x8(%ebp),%eax
  801664:	e8 37 fa ff ff       	call   8010a0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801669:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80166c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801670:	8b 74 24 04          	mov    0x4(%esp),%esi
  801674:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801677:	89 44 24 08          	mov    %eax,0x8(%esp)
  80167b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801682:	00 
  801683:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801686:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801689:	89 14 24             	mov    %edx,(%esp)
  80168c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801690:	e8 3b 09 00 00       	call   801fd0 <__umoddi3>
  801695:	89 74 24 04          	mov    %esi,0x4(%esp)
  801699:	0f be 80 ff 21 80 00 	movsbl 0x8021ff(%eax),%eax
  8016a0:	89 04 24             	mov    %eax,(%esp)
  8016a3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8016a6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8016aa:	74 54                	je     801700 <vprintfmt+0x514>
  8016ac:	e9 67 fb ff ff       	jmp    801218 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8016b1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8016b5:	8d 76 00             	lea    0x0(%esi),%esi
  8016b8:	0f 84 2a 01 00 00    	je     8017e8 <vprintfmt+0x5fc>
		while (--width > 0)
  8016be:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8016c1:	83 ef 01             	sub    $0x1,%edi
  8016c4:	85 ff                	test   %edi,%edi
  8016c6:	0f 8e 5e 01 00 00    	jle    80182a <vprintfmt+0x63e>
  8016cc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8016cf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8016d2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8016d5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8016d8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016db:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8016de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016e2:	89 1c 24             	mov    %ebx,(%esp)
  8016e5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8016e8:	83 ef 01             	sub    $0x1,%edi
  8016eb:	85 ff                	test   %edi,%edi
  8016ed:	7f ef                	jg     8016de <vprintfmt+0x4f2>
  8016ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8016f5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8016f8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8016fb:	e9 2a 01 00 00       	jmp    80182a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801700:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801703:	83 eb 01             	sub    $0x1,%ebx
  801706:	85 db                	test   %ebx,%ebx
  801708:	0f 8e 0a fb ff ff    	jle    801218 <vprintfmt+0x2c>
  80170e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801711:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801714:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  801717:	89 74 24 04          	mov    %esi,0x4(%esp)
  80171b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801722:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801724:	83 eb 01             	sub    $0x1,%ebx
  801727:	85 db                	test   %ebx,%ebx
  801729:	7f ec                	jg     801717 <vprintfmt+0x52b>
  80172b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80172e:	e9 e8 fa ff ff       	jmp    80121b <vprintfmt+0x2f>
  801733:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801736:	8b 45 14             	mov    0x14(%ebp),%eax
  801739:	8d 50 04             	lea    0x4(%eax),%edx
  80173c:	89 55 14             	mov    %edx,0x14(%ebp)
  80173f:	8b 00                	mov    (%eax),%eax
  801741:	85 c0                	test   %eax,%eax
  801743:	75 2a                	jne    80176f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801745:	c7 44 24 0c 38 23 80 	movl   $0x802338,0xc(%esp)
  80174c:	00 
  80174d:	c7 44 24 08 19 22 80 	movl   $0x802219,0x8(%esp)
  801754:	00 
  801755:	8b 55 0c             	mov    0xc(%ebp),%edx
  801758:	89 54 24 04          	mov    %edx,0x4(%esp)
  80175c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175f:	89 0c 24             	mov    %ecx,(%esp)
  801762:	e8 90 01 00 00       	call   8018f7 <printfmt>
  801767:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80176a:	e9 ac fa ff ff       	jmp    80121b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80176f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801772:	8b 13                	mov    (%ebx),%edx
  801774:	83 fa 7f             	cmp    $0x7f,%edx
  801777:	7e 29                	jle    8017a2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801779:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80177b:	c7 44 24 0c 70 23 80 	movl   $0x802370,0xc(%esp)
  801782:	00 
  801783:	c7 44 24 08 19 22 80 	movl   $0x802219,0x8(%esp)
  80178a:	00 
  80178b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80178f:	8b 45 08             	mov    0x8(%ebp),%eax
  801792:	89 04 24             	mov    %eax,(%esp)
  801795:	e8 5d 01 00 00       	call   8018f7 <printfmt>
  80179a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80179d:	e9 79 fa ff ff       	jmp    80121b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8017a2:	88 10                	mov    %dl,(%eax)
  8017a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017a7:	e9 6f fa ff ff       	jmp    80121b <vprintfmt+0x2f>
  8017ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017b9:	89 14 24             	mov    %edx,(%esp)
  8017bc:	ff 55 08             	call   *0x8(%ebp)
  8017bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8017c2:	e9 54 fa ff ff       	jmp    80121b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017d5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8017db:	80 38 25             	cmpb   $0x25,(%eax)
  8017de:	0f 84 37 fa ff ff    	je     80121b <vprintfmt+0x2f>
  8017e4:	89 c7                	mov    %eax,%edi
  8017e6:	eb f0                	jmp    8017d8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ef:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017f3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8017f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801801:	00 
  801802:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801805:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80180f:	e8 bc 07 00 00       	call   801fd0 <__umoddi3>
  801814:	89 74 24 04          	mov    %esi,0x4(%esp)
  801818:	0f be 80 ff 21 80 00 	movsbl 0x8021ff(%eax),%eax
  80181f:	89 04 24             	mov    %eax,(%esp)
  801822:	ff 55 08             	call   *0x8(%ebp)
  801825:	e9 d6 fe ff ff       	jmp    801700 <vprintfmt+0x514>
  80182a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801831:	8b 74 24 04          	mov    0x4(%esp),%esi
  801835:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801838:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80183c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801843:	00 
  801844:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801847:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80184a:	89 04 24             	mov    %eax,(%esp)
  80184d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801851:	e8 7a 07 00 00       	call   801fd0 <__umoddi3>
  801856:	89 74 24 04          	mov    %esi,0x4(%esp)
  80185a:	0f be 80 ff 21 80 00 	movsbl 0x8021ff(%eax),%eax
  801861:	89 04 24             	mov    %eax,(%esp)
  801864:	ff 55 08             	call   *0x8(%ebp)
  801867:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186a:	e9 ac f9 ff ff       	jmp    80121b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80186f:	83 c4 6c             	add    $0x6c,%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5f                   	pop    %edi
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	83 ec 28             	sub    $0x28,%esp
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801883:	85 c0                	test   %eax,%eax
  801885:	74 04                	je     80188b <vsnprintf+0x14>
  801887:	85 d2                	test   %edx,%edx
  801889:	7f 07                	jg     801892 <vsnprintf+0x1b>
  80188b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801890:	eb 3b                	jmp    8018cd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801892:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801895:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801899:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80189c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8018a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8018b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b8:	c7 04 24 cf 11 80 00 	movl   $0x8011cf,(%esp)
  8018bf:	e8 28 f9 ff ff       	call   8011ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8018c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8018c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8018ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8018d5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8018d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8018df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	89 04 24             	mov    %eax,(%esp)
  8018f0:	e8 82 ff ff ff       	call   801877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8018fd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801900:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801904:	8b 45 10             	mov    0x10(%ebp),%eax
  801907:	89 44 24 08          	mov    %eax,0x8(%esp)
  80190b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	89 04 24             	mov    %eax,(%esp)
  801918:	e8 cf f8 ff ff       	call   8011ec <vprintfmt>
	va_end(ap);
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    
	...

00801920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801926:	b8 00 00 00 00       	mov    $0x0,%eax
  80192b:	80 3a 00             	cmpb   $0x0,(%edx)
  80192e:	74 09                	je     801939 <strlen+0x19>
		n++;
  801930:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801933:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801937:	75 f7                	jne    801930 <strlen+0x10>
		n++;
	return n;
}
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	53                   	push   %ebx
  80193f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801945:	85 c9                	test   %ecx,%ecx
  801947:	74 19                	je     801962 <strnlen+0x27>
  801949:	80 3b 00             	cmpb   $0x0,(%ebx)
  80194c:	74 14                	je     801962 <strnlen+0x27>
  80194e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801953:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801956:	39 c8                	cmp    %ecx,%eax
  801958:	74 0d                	je     801967 <strnlen+0x2c>
  80195a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80195e:	75 f3                	jne    801953 <strnlen+0x18>
  801960:	eb 05                	jmp    801967 <strnlen+0x2c>
  801962:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801967:	5b                   	pop    %ebx
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	53                   	push   %ebx
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801979:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80197d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801980:	83 c2 01             	add    $0x1,%edx
  801983:	84 c9                	test   %cl,%cl
  801985:	75 f2                	jne    801979 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801987:	5b                   	pop    %ebx
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	53                   	push   %ebx
  80198e:	83 ec 08             	sub    $0x8,%esp
  801991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801994:	89 1c 24             	mov    %ebx,(%esp)
  801997:	e8 84 ff ff ff       	call   801920 <strlen>
	strcpy(dst + len, src);
  80199c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019a3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8019a6:	89 04 24             	mov    %eax,(%esp)
  8019a9:	e8 bc ff ff ff       	call   80196a <strcpy>
	return dst;
}
  8019ae:	89 d8                	mov    %ebx,%eax
  8019b0:	83 c4 08             	add    $0x8,%esp
  8019b3:	5b                   	pop    %ebx
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	56                   	push   %esi
  8019ba:	53                   	push   %ebx
  8019bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019c4:	85 f6                	test   %esi,%esi
  8019c6:	74 18                	je     8019e0 <strncpy+0x2a>
  8019c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8019cd:	0f b6 1a             	movzbl (%edx),%ebx
  8019d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8019d3:	80 3a 01             	cmpb   $0x1,(%edx)
  8019d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019d9:	83 c1 01             	add    $0x1,%ecx
  8019dc:	39 ce                	cmp    %ecx,%esi
  8019de:	77 ed                	ja     8019cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8019e0:	5b                   	pop    %ebx
  8019e1:	5e                   	pop    %esi
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8019f2:	89 f0                	mov    %esi,%eax
  8019f4:	85 c9                	test   %ecx,%ecx
  8019f6:	74 27                	je     801a1f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8019f8:	83 e9 01             	sub    $0x1,%ecx
  8019fb:	74 1d                	je     801a1a <strlcpy+0x36>
  8019fd:	0f b6 1a             	movzbl (%edx),%ebx
  801a00:	84 db                	test   %bl,%bl
  801a02:	74 16                	je     801a1a <strlcpy+0x36>
			*dst++ = *src++;
  801a04:	88 18                	mov    %bl,(%eax)
  801a06:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a09:	83 e9 01             	sub    $0x1,%ecx
  801a0c:	74 0e                	je     801a1c <strlcpy+0x38>
			*dst++ = *src++;
  801a0e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a11:	0f b6 1a             	movzbl (%edx),%ebx
  801a14:	84 db                	test   %bl,%bl
  801a16:	75 ec                	jne    801a04 <strlcpy+0x20>
  801a18:	eb 02                	jmp    801a1c <strlcpy+0x38>
  801a1a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a1c:	c6 00 00             	movb   $0x0,(%eax)
  801a1f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    

00801a25 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801a2e:	0f b6 01             	movzbl (%ecx),%eax
  801a31:	84 c0                	test   %al,%al
  801a33:	74 15                	je     801a4a <strcmp+0x25>
  801a35:	3a 02                	cmp    (%edx),%al
  801a37:	75 11                	jne    801a4a <strcmp+0x25>
		p++, q++;
  801a39:	83 c1 01             	add    $0x1,%ecx
  801a3c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801a3f:	0f b6 01             	movzbl (%ecx),%eax
  801a42:	84 c0                	test   %al,%al
  801a44:	74 04                	je     801a4a <strcmp+0x25>
  801a46:	3a 02                	cmp    (%edx),%al
  801a48:	74 ef                	je     801a39 <strcmp+0x14>
  801a4a:	0f b6 c0             	movzbl %al,%eax
  801a4d:	0f b6 12             	movzbl (%edx),%edx
  801a50:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	53                   	push   %ebx
  801a58:	8b 55 08             	mov    0x8(%ebp),%edx
  801a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801a61:	85 c0                	test   %eax,%eax
  801a63:	74 23                	je     801a88 <strncmp+0x34>
  801a65:	0f b6 1a             	movzbl (%edx),%ebx
  801a68:	84 db                	test   %bl,%bl
  801a6a:	74 25                	je     801a91 <strncmp+0x3d>
  801a6c:	3a 19                	cmp    (%ecx),%bl
  801a6e:	75 21                	jne    801a91 <strncmp+0x3d>
  801a70:	83 e8 01             	sub    $0x1,%eax
  801a73:	74 13                	je     801a88 <strncmp+0x34>
		n--, p++, q++;
  801a75:	83 c2 01             	add    $0x1,%edx
  801a78:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801a7b:	0f b6 1a             	movzbl (%edx),%ebx
  801a7e:	84 db                	test   %bl,%bl
  801a80:	74 0f                	je     801a91 <strncmp+0x3d>
  801a82:	3a 19                	cmp    (%ecx),%bl
  801a84:	74 ea                	je     801a70 <strncmp+0x1c>
  801a86:	eb 09                	jmp    801a91 <strncmp+0x3d>
  801a88:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a8d:	5b                   	pop    %ebx
  801a8e:	5d                   	pop    %ebp
  801a8f:	90                   	nop
  801a90:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a91:	0f b6 02             	movzbl (%edx),%eax
  801a94:	0f b6 11             	movzbl (%ecx),%edx
  801a97:	29 d0                	sub    %edx,%eax
  801a99:	eb f2                	jmp    801a8d <strncmp+0x39>

00801a9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801aa5:	0f b6 10             	movzbl (%eax),%edx
  801aa8:	84 d2                	test   %dl,%dl
  801aaa:	74 18                	je     801ac4 <strchr+0x29>
		if (*s == c)
  801aac:	38 ca                	cmp    %cl,%dl
  801aae:	75 0a                	jne    801aba <strchr+0x1f>
  801ab0:	eb 17                	jmp    801ac9 <strchr+0x2e>
  801ab2:	38 ca                	cmp    %cl,%dl
  801ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ab8:	74 0f                	je     801ac9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801aba:	83 c0 01             	add    $0x1,%eax
  801abd:	0f b6 10             	movzbl (%eax),%edx
  801ac0:	84 d2                	test   %dl,%dl
  801ac2:	75 ee                	jne    801ab2 <strchr+0x17>
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ad5:	0f b6 10             	movzbl (%eax),%edx
  801ad8:	84 d2                	test   %dl,%dl
  801ada:	74 18                	je     801af4 <strfind+0x29>
		if (*s == c)
  801adc:	38 ca                	cmp    %cl,%dl
  801ade:	75 0a                	jne    801aea <strfind+0x1f>
  801ae0:	eb 12                	jmp    801af4 <strfind+0x29>
  801ae2:	38 ca                	cmp    %cl,%dl
  801ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ae8:	74 0a                	je     801af4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801aea:	83 c0 01             	add    $0x1,%eax
  801aed:	0f b6 10             	movzbl (%eax),%edx
  801af0:	84 d2                	test   %dl,%dl
  801af2:	75 ee                	jne    801ae2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	89 1c 24             	mov    %ebx,(%esp)
  801aff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801b07:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b10:	85 c9                	test   %ecx,%ecx
  801b12:	74 30                	je     801b44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b1a:	75 25                	jne    801b41 <memset+0x4b>
  801b1c:	f6 c1 03             	test   $0x3,%cl
  801b1f:	75 20                	jne    801b41 <memset+0x4b>
		c &= 0xFF;
  801b21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b24:	89 d3                	mov    %edx,%ebx
  801b26:	c1 e3 08             	shl    $0x8,%ebx
  801b29:	89 d6                	mov    %edx,%esi
  801b2b:	c1 e6 18             	shl    $0x18,%esi
  801b2e:	89 d0                	mov    %edx,%eax
  801b30:	c1 e0 10             	shl    $0x10,%eax
  801b33:	09 f0                	or     %esi,%eax
  801b35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801b37:	09 d8                	or     %ebx,%eax
  801b39:	c1 e9 02             	shr    $0x2,%ecx
  801b3c:	fc                   	cld    
  801b3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b3f:	eb 03                	jmp    801b44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b41:	fc                   	cld    
  801b42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b44:	89 f8                	mov    %edi,%eax
  801b46:	8b 1c 24             	mov    (%esp),%ebx
  801b49:	8b 74 24 04          	mov    0x4(%esp),%esi
  801b4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b51:	89 ec                	mov    %ebp,%esp
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	89 34 24             	mov    %esi,(%esp)
  801b5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801b68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801b6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801b6d:	39 c6                	cmp    %eax,%esi
  801b6f:	73 35                	jae    801ba6 <memmove+0x51>
  801b71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b74:	39 d0                	cmp    %edx,%eax
  801b76:	73 2e                	jae    801ba6 <memmove+0x51>
		s += n;
		d += n;
  801b78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b7a:	f6 c2 03             	test   $0x3,%dl
  801b7d:	75 1b                	jne    801b9a <memmove+0x45>
  801b7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b85:	75 13                	jne    801b9a <memmove+0x45>
  801b87:	f6 c1 03             	test   $0x3,%cl
  801b8a:	75 0e                	jne    801b9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801b8c:	83 ef 04             	sub    $0x4,%edi
  801b8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801b92:	c1 e9 02             	shr    $0x2,%ecx
  801b95:	fd                   	std    
  801b96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b98:	eb 09                	jmp    801ba3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801b9a:	83 ef 01             	sub    $0x1,%edi
  801b9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801ba0:	fd                   	std    
  801ba1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ba3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ba4:	eb 20                	jmp    801bc6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ba6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bac:	75 15                	jne    801bc3 <memmove+0x6e>
  801bae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801bb4:	75 0d                	jne    801bc3 <memmove+0x6e>
  801bb6:	f6 c1 03             	test   $0x3,%cl
  801bb9:	75 08                	jne    801bc3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801bbb:	c1 e9 02             	shr    $0x2,%ecx
  801bbe:	fc                   	cld    
  801bbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bc1:	eb 03                	jmp    801bc6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bc3:	fc                   	cld    
  801bc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bc6:	8b 34 24             	mov    (%esp),%esi
  801bc9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801bcd:	89 ec                	mov    %ebp,%esp
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bda:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	89 04 24             	mov    %eax,(%esp)
  801beb:	e8 65 ff ff ff       	call   801b55 <memmove>
}
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	57                   	push   %edi
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c01:	85 c9                	test   %ecx,%ecx
  801c03:	74 36                	je     801c3b <memcmp+0x49>
		if (*s1 != *s2)
  801c05:	0f b6 06             	movzbl (%esi),%eax
  801c08:	0f b6 1f             	movzbl (%edi),%ebx
  801c0b:	38 d8                	cmp    %bl,%al
  801c0d:	74 20                	je     801c2f <memcmp+0x3d>
  801c0f:	eb 14                	jmp    801c25 <memcmp+0x33>
  801c11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801c16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801c1b:	83 c2 01             	add    $0x1,%edx
  801c1e:	83 e9 01             	sub    $0x1,%ecx
  801c21:	38 d8                	cmp    %bl,%al
  801c23:	74 12                	je     801c37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801c25:	0f b6 c0             	movzbl %al,%eax
  801c28:	0f b6 db             	movzbl %bl,%ebx
  801c2b:	29 d8                	sub    %ebx,%eax
  801c2d:	eb 11                	jmp    801c40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c2f:	83 e9 01             	sub    $0x1,%ecx
  801c32:	ba 00 00 00 00       	mov    $0x0,%edx
  801c37:	85 c9                	test   %ecx,%ecx
  801c39:	75 d6                	jne    801c11 <memcmp+0x1f>
  801c3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5f                   	pop    %edi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c4b:	89 c2                	mov    %eax,%edx
  801c4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801c50:	39 d0                	cmp    %edx,%eax
  801c52:	73 15                	jae    801c69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801c58:	38 08                	cmp    %cl,(%eax)
  801c5a:	75 06                	jne    801c62 <memfind+0x1d>
  801c5c:	eb 0b                	jmp    801c69 <memfind+0x24>
  801c5e:	38 08                	cmp    %cl,(%eax)
  801c60:	74 07                	je     801c69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c62:	83 c0 01             	add    $0x1,%eax
  801c65:	39 c2                	cmp    %eax,%edx
  801c67:	77 f5                	ja     801c5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    

00801c6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	57                   	push   %edi
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 04             	sub    $0x4,%esp
  801c74:	8b 55 08             	mov    0x8(%ebp),%edx
  801c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c7a:	0f b6 02             	movzbl (%edx),%eax
  801c7d:	3c 20                	cmp    $0x20,%al
  801c7f:	74 04                	je     801c85 <strtol+0x1a>
  801c81:	3c 09                	cmp    $0x9,%al
  801c83:	75 0e                	jne    801c93 <strtol+0x28>
		s++;
  801c85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c88:	0f b6 02             	movzbl (%edx),%eax
  801c8b:	3c 20                	cmp    $0x20,%al
  801c8d:	74 f6                	je     801c85 <strtol+0x1a>
  801c8f:	3c 09                	cmp    $0x9,%al
  801c91:	74 f2                	je     801c85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c93:	3c 2b                	cmp    $0x2b,%al
  801c95:	75 0c                	jne    801ca3 <strtol+0x38>
		s++;
  801c97:	83 c2 01             	add    $0x1,%edx
  801c9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801ca1:	eb 15                	jmp    801cb8 <strtol+0x4d>
	else if (*s == '-')
  801ca3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801caa:	3c 2d                	cmp    $0x2d,%al
  801cac:	75 0a                	jne    801cb8 <strtol+0x4d>
		s++, neg = 1;
  801cae:	83 c2 01             	add    $0x1,%edx
  801cb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cb8:	85 db                	test   %ebx,%ebx
  801cba:	0f 94 c0             	sete   %al
  801cbd:	74 05                	je     801cc4 <strtol+0x59>
  801cbf:	83 fb 10             	cmp    $0x10,%ebx
  801cc2:	75 18                	jne    801cdc <strtol+0x71>
  801cc4:	80 3a 30             	cmpb   $0x30,(%edx)
  801cc7:	75 13                	jne    801cdc <strtol+0x71>
  801cc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801ccd:	8d 76 00             	lea    0x0(%esi),%esi
  801cd0:	75 0a                	jne    801cdc <strtol+0x71>
		s += 2, base = 16;
  801cd2:	83 c2 02             	add    $0x2,%edx
  801cd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cda:	eb 15                	jmp    801cf1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cdc:	84 c0                	test   %al,%al
  801cde:	66 90                	xchg   %ax,%ax
  801ce0:	74 0f                	je     801cf1 <strtol+0x86>
  801ce2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801ce7:	80 3a 30             	cmpb   $0x30,(%edx)
  801cea:	75 05                	jne    801cf1 <strtol+0x86>
		s++, base = 8;
  801cec:	83 c2 01             	add    $0x1,%edx
  801cef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cf8:	0f b6 0a             	movzbl (%edx),%ecx
  801cfb:	89 cf                	mov    %ecx,%edi
  801cfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801d00:	80 fb 09             	cmp    $0x9,%bl
  801d03:	77 08                	ja     801d0d <strtol+0xa2>
			dig = *s - '0';
  801d05:	0f be c9             	movsbl %cl,%ecx
  801d08:	83 e9 30             	sub    $0x30,%ecx
  801d0b:	eb 1e                	jmp    801d2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801d0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801d10:	80 fb 19             	cmp    $0x19,%bl
  801d13:	77 08                	ja     801d1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801d15:	0f be c9             	movsbl %cl,%ecx
  801d18:	83 e9 57             	sub    $0x57,%ecx
  801d1b:	eb 0e                	jmp    801d2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801d1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801d20:	80 fb 19             	cmp    $0x19,%bl
  801d23:	77 15                	ja     801d3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801d25:	0f be c9             	movsbl %cl,%ecx
  801d28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801d2b:	39 f1                	cmp    %esi,%ecx
  801d2d:	7d 0b                	jge    801d3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801d2f:	83 c2 01             	add    $0x1,%edx
  801d32:	0f af c6             	imul   %esi,%eax
  801d35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801d38:	eb be                	jmp    801cf8 <strtol+0x8d>
  801d3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801d3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d40:	74 05                	je     801d47 <strtol+0xdc>
		*endptr = (char *) s;
  801d42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801d47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801d4b:	74 04                	je     801d51 <strtol+0xe6>
  801d4d:	89 c8                	mov    %ecx,%eax
  801d4f:	f7 d8                	neg    %eax
}
  801d51:	83 c4 04             	add    $0x4,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	00 00                	add    %al,(%eax)
  801d5b:	00 00                	add    %al,(%eax)
  801d5d:	00 00                	add    %al,(%eax)
	...

00801d60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d66:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801d6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d71:	39 ca                	cmp    %ecx,%edx
  801d73:	75 04                	jne    801d79 <ipc_find_env+0x19>
  801d75:	b0 00                	mov    $0x0,%al
  801d77:	eb 12                	jmp    801d8b <ipc_find_env+0x2b>
  801d79:	89 c2                	mov    %eax,%edx
  801d7b:	c1 e2 07             	shl    $0x7,%edx
  801d7e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801d85:	8b 12                	mov    (%edx),%edx
  801d87:	39 ca                	cmp    %ecx,%edx
  801d89:	75 10                	jne    801d9b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d8b:	89 c2                	mov    %eax,%edx
  801d8d:	c1 e2 07             	shl    $0x7,%edx
  801d90:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801d97:	8b 00                	mov    (%eax),%eax
  801d99:	eb 0e                	jmp    801da9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d9b:	83 c0 01             	add    $0x1,%eax
  801d9e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801da3:	75 d4                	jne    801d79 <ipc_find_env+0x19>
  801da5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	57                   	push   %edi
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	83 ec 1c             	sub    $0x1c,%esp
  801db4:	8b 75 08             	mov    0x8(%ebp),%esi
  801db7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801dba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801dbd:	85 db                	test   %ebx,%ebx
  801dbf:	74 19                	je     801dda <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801dc1:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dc8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dcc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dd0:	89 34 24             	mov    %esi,(%esp)
  801dd3:	e8 e8 e4 ff ff       	call   8002c0 <sys_ipc_try_send>
  801dd8:	eb 1b                	jmp    801df5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801dda:	8b 45 14             	mov    0x14(%ebp),%eax
  801ddd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801de1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801de8:	ee 
  801de9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ded:	89 34 24             	mov    %esi,(%esp)
  801df0:	e8 cb e4 ff ff       	call   8002c0 <sys_ipc_try_send>
           if(ret == 0)
  801df5:	85 c0                	test   %eax,%eax
  801df7:	74 28                	je     801e21 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801df9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dfc:	74 1c                	je     801e1a <ipc_send+0x6f>
              panic("ipc send error");
  801dfe:	c7 44 24 08 80 25 80 	movl   $0x802580,0x8(%esp)
  801e05:	00 
  801e06:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801e0d:	00 
  801e0e:	c7 04 24 8f 25 80 00 	movl   $0x80258f,(%esp)
  801e15:	e8 6a f1 ff ff       	call   800f84 <_panic>
           sys_yield();
  801e1a:	e8 6d e7 ff ff       	call   80058c <sys_yield>
        }
  801e1f:	eb 9c                	jmp    801dbd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801e21:	83 c4 1c             	add    $0x1c,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	83 ec 10             	sub    $0x10,%esp
  801e31:	8b 75 08             	mov    0x8(%ebp),%esi
  801e34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	75 0e                	jne    801e4c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e3e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e45:	e8 0b e4 ff ff       	call   800255 <sys_ipc_recv>
  801e4a:	eb 08                	jmp    801e54 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e4c:	89 04 24             	mov    %eax,(%esp)
  801e4f:	e8 01 e4 ff ff       	call   800255 <sys_ipc_recv>
        if(ret == 0){
  801e54:	85 c0                	test   %eax,%eax
  801e56:	75 26                	jne    801e7e <ipc_recv+0x55>
           if(from_env_store)
  801e58:	85 f6                	test   %esi,%esi
  801e5a:	74 0a                	je     801e66 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e61:	8b 40 78             	mov    0x78(%eax),%eax
  801e64:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801e66:	85 db                	test   %ebx,%ebx
  801e68:	74 0a                	je     801e74 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801e6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e72:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801e74:	a1 04 40 80 00       	mov    0x804004,%eax
  801e79:	8b 40 74             	mov    0x74(%eax),%eax
  801e7c:	eb 14                	jmp    801e92 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801e7e:	85 f6                	test   %esi,%esi
  801e80:	74 06                	je     801e88 <ipc_recv+0x5f>
              *from_env_store = 0;
  801e82:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801e88:	85 db                	test   %ebx,%ebx
  801e8a:	74 06                	je     801e92 <ipc_recv+0x69>
              *perm_store = 0;
  801e8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	5b                   	pop    %ebx
  801e96:	5e                   	pop    %esi
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    
  801e99:	00 00                	add    %al,(%eax)
  801e9b:	00 00                	add    %al,(%eax)
  801e9d:	00 00                	add    %al,(%eax)
	...

00801ea0 <__udivdi3>:
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	57                   	push   %edi
  801ea4:	56                   	push   %esi
  801ea5:	83 ec 10             	sub    $0x10,%esp
  801ea8:	8b 45 14             	mov    0x14(%ebp),%eax
  801eab:	8b 55 08             	mov    0x8(%ebp),%edx
  801eae:	8b 75 10             	mov    0x10(%ebp),%esi
  801eb1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801eb9:	75 35                	jne    801ef0 <__udivdi3+0x50>
  801ebb:	39 fe                	cmp    %edi,%esi
  801ebd:	77 61                	ja     801f20 <__udivdi3+0x80>
  801ebf:	85 f6                	test   %esi,%esi
  801ec1:	75 0b                	jne    801ece <__udivdi3+0x2e>
  801ec3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec8:	31 d2                	xor    %edx,%edx
  801eca:	f7 f6                	div    %esi
  801ecc:	89 c6                	mov    %eax,%esi
  801ece:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ed1:	31 d2                	xor    %edx,%edx
  801ed3:	89 f8                	mov    %edi,%eax
  801ed5:	f7 f6                	div    %esi
  801ed7:	89 c7                	mov    %eax,%edi
  801ed9:	89 c8                	mov    %ecx,%eax
  801edb:	f7 f6                	div    %esi
  801edd:	89 c1                	mov    %eax,%ecx
  801edf:	89 fa                	mov    %edi,%edx
  801ee1:	89 c8                	mov    %ecx,%eax
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	5e                   	pop    %esi
  801ee7:	5f                   	pop    %edi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    
  801eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ef0:	39 f8                	cmp    %edi,%eax
  801ef2:	77 1c                	ja     801f10 <__udivdi3+0x70>
  801ef4:	0f bd d0             	bsr    %eax,%edx
  801ef7:	83 f2 1f             	xor    $0x1f,%edx
  801efa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801efd:	75 39                	jne    801f38 <__udivdi3+0x98>
  801eff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f02:	0f 86 a0 00 00 00    	jbe    801fa8 <__udivdi3+0x108>
  801f08:	39 f8                	cmp    %edi,%eax
  801f0a:	0f 82 98 00 00 00    	jb     801fa8 <__udivdi3+0x108>
  801f10:	31 ff                	xor    %edi,%edi
  801f12:	31 c9                	xor    %ecx,%ecx
  801f14:	89 c8                	mov    %ecx,%eax
  801f16:	89 fa                	mov    %edi,%edx
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	5e                   	pop    %esi
  801f1c:	5f                   	pop    %edi
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    
  801f1f:	90                   	nop
  801f20:	89 d1                	mov    %edx,%ecx
  801f22:	89 fa                	mov    %edi,%edx
  801f24:	89 c8                	mov    %ecx,%eax
  801f26:	31 ff                	xor    %edi,%edi
  801f28:	f7 f6                	div    %esi
  801f2a:	89 c1                	mov    %eax,%ecx
  801f2c:	89 fa                	mov    %edi,%edx
  801f2e:	89 c8                	mov    %ecx,%eax
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    
  801f37:	90                   	nop
  801f38:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f3c:	89 f2                	mov    %esi,%edx
  801f3e:	d3 e0                	shl    %cl,%eax
  801f40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f43:	b8 20 00 00 00       	mov    $0x20,%eax
  801f48:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f4b:	89 c1                	mov    %eax,%ecx
  801f4d:	d3 ea                	shr    %cl,%edx
  801f4f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f53:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f56:	d3 e6                	shl    %cl,%esi
  801f58:	89 c1                	mov    %eax,%ecx
  801f5a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f5d:	89 fe                	mov    %edi,%esi
  801f5f:	d3 ee                	shr    %cl,%esi
  801f61:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f65:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f6b:	d3 e7                	shl    %cl,%edi
  801f6d:	89 c1                	mov    %eax,%ecx
  801f6f:	d3 ea                	shr    %cl,%edx
  801f71:	09 d7                	or     %edx,%edi
  801f73:	89 f2                	mov    %esi,%edx
  801f75:	89 f8                	mov    %edi,%eax
  801f77:	f7 75 ec             	divl   -0x14(%ebp)
  801f7a:	89 d6                	mov    %edx,%esi
  801f7c:	89 c7                	mov    %eax,%edi
  801f7e:	f7 65 e8             	mull   -0x18(%ebp)
  801f81:	39 d6                	cmp    %edx,%esi
  801f83:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f86:	72 30                	jb     801fb8 <__udivdi3+0x118>
  801f88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f8b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f8f:	d3 e2                	shl    %cl,%edx
  801f91:	39 c2                	cmp    %eax,%edx
  801f93:	73 05                	jae    801f9a <__udivdi3+0xfa>
  801f95:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801f98:	74 1e                	je     801fb8 <__udivdi3+0x118>
  801f9a:	89 f9                	mov    %edi,%ecx
  801f9c:	31 ff                	xor    %edi,%edi
  801f9e:	e9 71 ff ff ff       	jmp    801f14 <__udivdi3+0x74>
  801fa3:	90                   	nop
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	31 ff                	xor    %edi,%edi
  801faa:	b9 01 00 00 00       	mov    $0x1,%ecx
  801faf:	e9 60 ff ff ff       	jmp    801f14 <__udivdi3+0x74>
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801fbb:	31 ff                	xor    %edi,%edi
  801fbd:	89 c8                	mov    %ecx,%eax
  801fbf:	89 fa                	mov    %edi,%edx
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
	...

00801fd0 <__umoddi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	57                   	push   %edi
  801fd4:	56                   	push   %esi
  801fd5:	83 ec 20             	sub    $0x20,%esp
  801fd8:	8b 55 14             	mov    0x14(%ebp),%edx
  801fdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fde:	8b 7d 10             	mov    0x10(%ebp),%edi
  801fe1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe4:	85 d2                	test   %edx,%edx
  801fe6:	89 c8                	mov    %ecx,%eax
  801fe8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801feb:	75 13                	jne    802000 <__umoddi3+0x30>
  801fed:	39 f7                	cmp    %esi,%edi
  801fef:	76 3f                	jbe    802030 <__umoddi3+0x60>
  801ff1:	89 f2                	mov    %esi,%edx
  801ff3:	f7 f7                	div    %edi
  801ff5:	89 d0                	mov    %edx,%eax
  801ff7:	31 d2                	xor    %edx,%edx
  801ff9:	83 c4 20             	add    $0x20,%esp
  801ffc:	5e                   	pop    %esi
  801ffd:	5f                   	pop    %edi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    
  802000:	39 f2                	cmp    %esi,%edx
  802002:	77 4c                	ja     802050 <__umoddi3+0x80>
  802004:	0f bd ca             	bsr    %edx,%ecx
  802007:	83 f1 1f             	xor    $0x1f,%ecx
  80200a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80200d:	75 51                	jne    802060 <__umoddi3+0x90>
  80200f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802012:	0f 87 e0 00 00 00    	ja     8020f8 <__umoddi3+0x128>
  802018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201b:	29 f8                	sub    %edi,%eax
  80201d:	19 d6                	sbb    %edx,%esi
  80201f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802025:	89 f2                	mov    %esi,%edx
  802027:	83 c4 20             	add    $0x20,%esp
  80202a:	5e                   	pop    %esi
  80202b:	5f                   	pop    %edi
  80202c:	5d                   	pop    %ebp
  80202d:	c3                   	ret    
  80202e:	66 90                	xchg   %ax,%ax
  802030:	85 ff                	test   %edi,%edi
  802032:	75 0b                	jne    80203f <__umoddi3+0x6f>
  802034:	b8 01 00 00 00       	mov    $0x1,%eax
  802039:	31 d2                	xor    %edx,%edx
  80203b:	f7 f7                	div    %edi
  80203d:	89 c7                	mov    %eax,%edi
  80203f:	89 f0                	mov    %esi,%eax
  802041:	31 d2                	xor    %edx,%edx
  802043:	f7 f7                	div    %edi
  802045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802048:	f7 f7                	div    %edi
  80204a:	eb a9                	jmp    801ff5 <__umoddi3+0x25>
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 c8                	mov    %ecx,%eax
  802052:	89 f2                	mov    %esi,%edx
  802054:	83 c4 20             	add    $0x20,%esp
  802057:	5e                   	pop    %esi
  802058:	5f                   	pop    %edi
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    
  80205b:	90                   	nop
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802064:	d3 e2                	shl    %cl,%edx
  802066:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802069:	ba 20 00 00 00       	mov    $0x20,%edx
  80206e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802071:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802074:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802078:	89 fa                	mov    %edi,%edx
  80207a:	d3 ea                	shr    %cl,%edx
  80207c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802080:	0b 55 f4             	or     -0xc(%ebp),%edx
  802083:	d3 e7                	shl    %cl,%edi
  802085:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802089:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80208c:	89 f2                	mov    %esi,%edx
  80208e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802091:	89 c7                	mov    %eax,%edi
  802093:	d3 ea                	shr    %cl,%edx
  802095:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802099:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80209c:	89 c2                	mov    %eax,%edx
  80209e:	d3 e6                	shl    %cl,%esi
  8020a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020a4:	d3 ea                	shr    %cl,%edx
  8020a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020aa:	09 d6                	or     %edx,%esi
  8020ac:	89 f0                	mov    %esi,%eax
  8020ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8020b1:	d3 e7                	shl    %cl,%edi
  8020b3:	89 f2                	mov    %esi,%edx
  8020b5:	f7 75 f4             	divl   -0xc(%ebp)
  8020b8:	89 d6                	mov    %edx,%esi
  8020ba:	f7 65 e8             	mull   -0x18(%ebp)
  8020bd:	39 d6                	cmp    %edx,%esi
  8020bf:	72 2b                	jb     8020ec <__umoddi3+0x11c>
  8020c1:	39 c7                	cmp    %eax,%edi
  8020c3:	72 23                	jb     8020e8 <__umoddi3+0x118>
  8020c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020c9:	29 c7                	sub    %eax,%edi
  8020cb:	19 d6                	sbb    %edx,%esi
  8020cd:	89 f0                	mov    %esi,%eax
  8020cf:	89 f2                	mov    %esi,%edx
  8020d1:	d3 ef                	shr    %cl,%edi
  8020d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020d7:	d3 e0                	shl    %cl,%eax
  8020d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020dd:	09 f8                	or     %edi,%eax
  8020df:	d3 ea                	shr    %cl,%edx
  8020e1:	83 c4 20             	add    $0x20,%esp
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	39 d6                	cmp    %edx,%esi
  8020ea:	75 d9                	jne    8020c5 <__umoddi3+0xf5>
  8020ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8020f2:	eb d1                	jmp    8020c5 <__umoddi3+0xf5>
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	0f 82 18 ff ff ff    	jb     802018 <__umoddi3+0x48>
  802100:	e9 1d ff ff ff       	jmp    802022 <__umoddi3+0x52>
