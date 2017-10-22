
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
  800056:	e8 7f 05 00 00       	call   8005da <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	89 c2                	mov    %eax,%edx
  800062:	c1 e2 07             	shl    $0x7,%edx
  800065:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80006c:	a3 04 40 80 00       	mov    %eax,0x804004
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
  80009e:	e8 c8 0a 00 00       	call   800b6b <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 6b 05 00 00       	call   80061a <sys_env_destroy>
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

00800133 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
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
  800140:	b8 10 00 00 00       	mov    $0x10,%eax
  800145:	8b 7d 14             	mov    0x14(%ebp),%edi
  800148:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80014b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80014e:	8b 55 08             	mov    0x8(%ebp),%edx
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
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800169:	8b 1c 24             	mov    (%esp),%ebx
  80016c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 28             	sub    $0x28,%esp
  80017a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80017d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800180:	bb 00 00 00 00       	mov    $0x0,%ebx
  800185:	b8 0f 00 00 00       	mov    $0xf,%eax
  80018a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018d:	8b 55 08             	mov    0x8(%ebp),%edx
  800190:	89 df                	mov    %ebx,%edi
  800192:	51                   	push   %ecx
  800193:	52                   	push   %edx
  800194:	53                   	push   %ebx
  800195:	54                   	push   %esp
  800196:	55                   	push   %ebp
  800197:	56                   	push   %esi
  800198:	57                   	push   %edi
  800199:	54                   	push   %esp
  80019a:	5d                   	pop    %ebp
  80019b:	8d 35 a3 01 80 00    	lea    0x8001a3,%esi
  8001a1:	0f 34                	sysenter 
  8001a3:	5f                   	pop    %edi
  8001a4:	5e                   	pop    %esi
  8001a5:	5d                   	pop    %ebp
  8001a6:	5c                   	pop    %esp
  8001a7:	5b                   	pop    %ebx
  8001a8:	5a                   	pop    %edx
  8001a9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	7e 28                	jle    8001d6 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b2:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8001b9:	00 
  8001ba:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  8001c1:	00 
  8001c2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8001c9:	00 
  8001ca:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  8001d1:	e8 7e 0d 00 00       	call   800f54 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8001d6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001d9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001dc:	89 ec                	mov    %ebp,%esp
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	89 1c 24             	mov    %ebx,(%esp)
  8001e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001f2:	b8 11 00 00 00       	mov    $0x11,%eax
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	89 cb                	mov    %ecx,%ebx
  8001fc:	89 cf                	mov    %ecx,%edi
  8001fe:	51                   	push   %ecx
  8001ff:	52                   	push   %edx
  800200:	53                   	push   %ebx
  800201:	54                   	push   %esp
  800202:	55                   	push   %ebp
  800203:	56                   	push   %esi
  800204:	57                   	push   %edi
  800205:	54                   	push   %esp
  800206:	5d                   	pop    %ebp
  800207:	8d 35 0f 02 80 00    	lea    0x80020f,%esi
  80020d:	0f 34                	sysenter 
  80020f:	5f                   	pop    %edi
  800210:	5e                   	pop    %esi
  800211:	5d                   	pop    %ebp
  800212:	5c                   	pop    %esp
  800213:	5b                   	pop    %ebx
  800214:	5a                   	pop    %edx
  800215:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800216:	8b 1c 24             	mov    (%esp),%ebx
  800219:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021d:	89 ec                	mov    %ebp,%esp
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 28             	sub    $0x28,%esp
  800227:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80022a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80022d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800232:	b8 0e 00 00 00       	mov    $0xe,%eax
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 cb                	mov    %ecx,%ebx
  80023c:	89 cf                	mov    %ecx,%edi
  80023e:	51                   	push   %ecx
  80023f:	52                   	push   %edx
  800240:	53                   	push   %ebx
  800241:	54                   	push   %esp
  800242:	55                   	push   %ebp
  800243:	56                   	push   %esi
  800244:	57                   	push   %edi
  800245:	54                   	push   %esp
  800246:	5d                   	pop    %ebp
  800247:	8d 35 4f 02 80 00    	lea    0x80024f,%esi
  80024d:	0f 34                	sysenter 
  80024f:	5f                   	pop    %edi
  800250:	5e                   	pop    %esi
  800251:	5d                   	pop    %ebp
  800252:	5c                   	pop    %esp
  800253:	5b                   	pop    %ebx
  800254:	5a                   	pop    %edx
  800255:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 28                	jle    800282 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025e:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800265:	00 
  800266:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  80026d:	00 
  80026e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  80027d:	e8 d2 0c 00 00       	call   800f54 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800282:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800285:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800288:	89 ec                	mov    %ebp,%esp
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	89 1c 24             	mov    %ebx,(%esp)
  800295:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800299:	b8 0d 00 00 00       	mov    $0xd,%eax
  80029e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a7:	8b 55 08             	mov    0x8(%ebp),%edx
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

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c2:	8b 1c 24             	mov    (%esp),%ebx
  8002c5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c9:	89 ec                	mov    %ebp,%esp
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 28             	sub    $0x28,%esp
  8002d3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002d6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002de:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e9:	89 df                	mov    %ebx,%edi
  8002eb:	51                   	push   %ecx
  8002ec:	52                   	push   %edx
  8002ed:	53                   	push   %ebx
  8002ee:	54                   	push   %esp
  8002ef:	55                   	push   %ebp
  8002f0:	56                   	push   %esi
  8002f1:	57                   	push   %edi
  8002f2:	54                   	push   %esp
  8002f3:	5d                   	pop    %ebp
  8002f4:	8d 35 fc 02 80 00    	lea    0x8002fc,%esi
  8002fa:	0f 34                	sysenter 
  8002fc:	5f                   	pop    %edi
  8002fd:	5e                   	pop    %esi
  8002fe:	5d                   	pop    %ebp
  8002ff:	5c                   	pop    %esp
  800300:	5b                   	pop    %ebx
  800301:	5a                   	pop    %edx
  800302:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800303:	85 c0                	test   %eax,%eax
  800305:	7e 28                	jle    80032f <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800307:	89 44 24 10          	mov    %eax,0x10(%esp)
  80030b:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  800312:	00 
  800313:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  80031a:	00 
  80031b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800322:	00 
  800323:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  80032a:	e8 25 0c 00 00       	call   800f54 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80032f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800332:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800335:	89 ec                	mov    %ebp,%esp
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 28             	sub    $0x28,%esp
  80033f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800342:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800345:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80034f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800352:	8b 55 08             	mov    0x8(%ebp),%edx
  800355:	89 df                	mov    %ebx,%edi
  800357:	51                   	push   %ecx
  800358:	52                   	push   %edx
  800359:	53                   	push   %ebx
  80035a:	54                   	push   %esp
  80035b:	55                   	push   %ebp
  80035c:	56                   	push   %esi
  80035d:	57                   	push   %edi
  80035e:	54                   	push   %esp
  80035f:	5d                   	pop    %ebp
  800360:	8d 35 68 03 80 00    	lea    0x800368,%esi
  800366:	0f 34                	sysenter 
  800368:	5f                   	pop    %edi
  800369:	5e                   	pop    %esi
  80036a:	5d                   	pop    %ebp
  80036b:	5c                   	pop    %esp
  80036c:	5b                   	pop    %ebx
  80036d:	5a                   	pop    %edx
  80036e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80036f:	85 c0                	test   %eax,%eax
  800371:	7e 28                	jle    80039b <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800373:	89 44 24 10          	mov    %eax,0x10(%esp)
  800377:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80037e:	00 
  80037f:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  800386:	00 
  800387:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80038e:	00 
  80038f:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  800396:	e8 b9 0b 00 00       	call   800f54 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80039b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80039e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a1:	89 ec                	mov    %ebp,%esp
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 28             	sub    $0x28,%esp
  8003ab:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003ae:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b6:	b8 09 00 00 00       	mov    $0x9,%eax
  8003bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003be:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c1:	89 df                	mov    %ebx,%edi
  8003c3:	51                   	push   %ecx
  8003c4:	52                   	push   %edx
  8003c5:	53                   	push   %ebx
  8003c6:	54                   	push   %esp
  8003c7:	55                   	push   %ebp
  8003c8:	56                   	push   %esi
  8003c9:	57                   	push   %edi
  8003ca:	54                   	push   %esp
  8003cb:	5d                   	pop    %ebp
  8003cc:	8d 35 d4 03 80 00    	lea    0x8003d4,%esi
  8003d2:	0f 34                	sysenter 
  8003d4:	5f                   	pop    %edi
  8003d5:	5e                   	pop    %esi
  8003d6:	5d                   	pop    %ebp
  8003d7:	5c                   	pop    %esp
  8003d8:	5b                   	pop    %ebx
  8003d9:	5a                   	pop    %edx
  8003da:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	7e 28                	jle    800407 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003e3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003ea:	00 
  8003eb:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  8003f2:	00 
  8003f3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8003fa:	00 
  8003fb:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  800402:	e8 4d 0b 00 00       	call   800f54 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800407:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80040a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80040d:	89 ec                	mov    %ebp,%esp
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 28             	sub    $0x28,%esp
  800417:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80041a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80041d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800422:	b8 07 00 00 00       	mov    $0x7,%eax
  800427:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042a:	8b 55 08             	mov    0x8(%ebp),%edx
  80042d:	89 df                	mov    %ebx,%edi
  80042f:	51                   	push   %ecx
  800430:	52                   	push   %edx
  800431:	53                   	push   %ebx
  800432:	54                   	push   %esp
  800433:	55                   	push   %ebp
  800434:	56                   	push   %esi
  800435:	57                   	push   %edi
  800436:	54                   	push   %esp
  800437:	5d                   	pop    %ebp
  800438:	8d 35 40 04 80 00    	lea    0x800440,%esi
  80043e:	0f 34                	sysenter 
  800440:	5f                   	pop    %edi
  800441:	5e                   	pop    %esi
  800442:	5d                   	pop    %ebp
  800443:	5c                   	pop    %esp
  800444:	5b                   	pop    %ebx
  800445:	5a                   	pop    %edx
  800446:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800447:	85 c0                	test   %eax,%eax
  800449:	7e 28                	jle    800473 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80044b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80044f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800456:	00 
  800457:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  80045e:	00 
  80045f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800466:	00 
  800467:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  80046e:	e8 e1 0a 00 00       	call   800f54 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800473:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800476:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800479:	89 ec                	mov    %ebp,%esp
  80047b:	5d                   	pop    %ebp
  80047c:	c3                   	ret    

0080047d <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	83 ec 28             	sub    $0x28,%esp
  800483:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800486:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800489:	8b 7d 18             	mov    0x18(%ebp),%edi
  80048c:	0b 7d 14             	or     0x14(%ebp),%edi
  80048f:	b8 06 00 00 00       	mov    $0x6,%eax
  800494:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800497:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80049a:	8b 55 08             	mov    0x8(%ebp),%edx
  80049d:	51                   	push   %ecx
  80049e:	52                   	push   %edx
  80049f:	53                   	push   %ebx
  8004a0:	54                   	push   %esp
  8004a1:	55                   	push   %ebp
  8004a2:	56                   	push   %esi
  8004a3:	57                   	push   %edi
  8004a4:	54                   	push   %esp
  8004a5:	5d                   	pop    %ebp
  8004a6:	8d 35 ae 04 80 00    	lea    0x8004ae,%esi
  8004ac:	0f 34                	sysenter 
  8004ae:	5f                   	pop    %edi
  8004af:	5e                   	pop    %esi
  8004b0:	5d                   	pop    %ebp
  8004b1:	5c                   	pop    %esp
  8004b2:	5b                   	pop    %ebx
  8004b3:	5a                   	pop    %edx
  8004b4:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	7e 28                	jle    8004e1 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004bd:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8004c4:	00 
  8004c5:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  8004cc:	00 
  8004cd:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004d4:	00 
  8004d5:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  8004dc:	e8 73 0a 00 00       	call   800f54 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8004e1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004e7:	89 ec                	mov    %ebp,%esp
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 28             	sub    $0x28,%esp
  8004f1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004f4:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8004fc:	b8 05 00 00 00       	mov    $0x5,%eax
  800501:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800504:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800507:	8b 55 08             	mov    0x8(%ebp),%edx
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800522:	85 c0                	test   %eax,%eax
  800524:	7e 28                	jle    80054e <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800526:	89 44 24 10          	mov    %eax,0x10(%esp)
  80052a:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800531:	00 
  800532:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  800539:	00 
  80053a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800541:	00 
  800542:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  800549:	e8 06 0a 00 00       	call   800f54 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80054e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800551:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800554:	89 ec                	mov    %ebp,%esp
  800556:	5d                   	pop    %ebp
  800557:	c3                   	ret    

00800558 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	89 1c 24             	mov    %ebx,(%esp)
  800561:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800565:	ba 00 00 00 00       	mov    $0x0,%edx
  80056a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80056f:	89 d1                	mov    %edx,%ecx
  800571:	89 d3                	mov    %edx,%ebx
  800573:	89 d7                	mov    %edx,%edi
  800575:	51                   	push   %ecx
  800576:	52                   	push   %edx
  800577:	53                   	push   %ebx
  800578:	54                   	push   %esp
  800579:	55                   	push   %ebp
  80057a:	56                   	push   %esi
  80057b:	57                   	push   %edi
  80057c:	54                   	push   %esp
  80057d:	5d                   	pop    %ebp
  80057e:	8d 35 86 05 80 00    	lea    0x800586,%esi
  800584:	0f 34                	sysenter 
  800586:	5f                   	pop    %edi
  800587:	5e                   	pop    %esi
  800588:	5d                   	pop    %ebp
  800589:	5c                   	pop    %esp
  80058a:	5b                   	pop    %ebx
  80058b:	5a                   	pop    %edx
  80058c:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80058d:	8b 1c 24             	mov    (%esp),%ebx
  800590:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800594:	89 ec                	mov    %ebp,%esp
  800596:	5d                   	pop    %ebp
  800597:	c3                   	ret    

00800598 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	89 1c 24             	mov    %ebx,(%esp)
  8005a1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8005af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b5:	89 df                	mov    %ebx,%edi
  8005b7:	51                   	push   %ecx
  8005b8:	52                   	push   %edx
  8005b9:	53                   	push   %ebx
  8005ba:	54                   	push   %esp
  8005bb:	55                   	push   %ebp
  8005bc:	56                   	push   %esi
  8005bd:	57                   	push   %edi
  8005be:	54                   	push   %esp
  8005bf:	5d                   	pop    %ebp
  8005c0:	8d 35 c8 05 80 00    	lea    0x8005c8,%esi
  8005c6:	0f 34                	sysenter 
  8005c8:	5f                   	pop    %edi
  8005c9:	5e                   	pop    %esi
  8005ca:	5d                   	pop    %ebp
  8005cb:	5c                   	pop    %esp
  8005cc:	5b                   	pop    %ebx
  8005cd:	5a                   	pop    %edx
  8005ce:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8005cf:	8b 1c 24             	mov    (%esp),%ebx
  8005d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005d6:	89 ec                	mov    %ebp,%esp
  8005d8:	5d                   	pop    %ebp
  8005d9:	c3                   	ret    

008005da <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8005da:	55                   	push   %ebp
  8005db:	89 e5                	mov    %esp,%ebp
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	89 1c 24             	mov    %ebx,(%esp)
  8005e3:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8005f1:	89 d1                	mov    %edx,%ecx
  8005f3:	89 d3                	mov    %edx,%ebx
  8005f5:	89 d7                	mov    %edx,%edi
  8005f7:	51                   	push   %ecx
  8005f8:	52                   	push   %edx
  8005f9:	53                   	push   %ebx
  8005fa:	54                   	push   %esp
  8005fb:	55                   	push   %ebp
  8005fc:	56                   	push   %esi
  8005fd:	57                   	push   %edi
  8005fe:	54                   	push   %esp
  8005ff:	5d                   	pop    %ebp
  800600:	8d 35 08 06 80 00    	lea    0x800608,%esi
  800606:	0f 34                	sysenter 
  800608:	5f                   	pop    %edi
  800609:	5e                   	pop    %esi
  80060a:	5d                   	pop    %ebp
  80060b:	5c                   	pop    %esp
  80060c:	5b                   	pop    %ebx
  80060d:	5a                   	pop    %edx
  80060e:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80060f:	8b 1c 24             	mov    (%esp),%ebx
  800612:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800616:	89 ec                	mov    %ebp,%esp
  800618:	5d                   	pop    %ebp
  800619:	c3                   	ret    

0080061a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	83 ec 28             	sub    $0x28,%esp
  800620:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800623:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062b:	b8 03 00 00 00       	mov    $0x3,%eax
  800630:	8b 55 08             	mov    0x8(%ebp),%edx
  800633:	89 cb                	mov    %ecx,%ebx
  800635:	89 cf                	mov    %ecx,%edi
  800637:	51                   	push   %ecx
  800638:	52                   	push   %edx
  800639:	53                   	push   %ebx
  80063a:	54                   	push   %esp
  80063b:	55                   	push   %ebp
  80063c:	56                   	push   %esi
  80063d:	57                   	push   %edi
  80063e:	54                   	push   %esp
  80063f:	5d                   	pop    %ebp
  800640:	8d 35 48 06 80 00    	lea    0x800648,%esi
  800646:	0f 34                	sysenter 
  800648:	5f                   	pop    %edi
  800649:	5e                   	pop    %esi
  80064a:	5d                   	pop    %ebp
  80064b:	5c                   	pop    %esp
  80064c:	5b                   	pop    %ebx
  80064d:	5a                   	pop    %edx
  80064e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80064f:	85 c0                	test   %eax,%eax
  800651:	7e 28                	jle    80067b <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800653:	89 44 24 10          	mov    %eax,0x10(%esp)
  800657:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80065e:	00 
  80065f:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  800666:	00 
  800667:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80066e:	00 
  80066f:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  800676:	e8 d9 08 00 00       	call   800f54 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80067b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80067e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800681:	89 ec                	mov    %ebp,%esp
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    
	...

00800690 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	05 00 00 00 30       	add    $0x30000000,%eax
  80069b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80069e:	5d                   	pop    %ebp
  80069f:	c3                   	ret    

008006a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8006a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a9:	89 04 24             	mov    %eax,(%esp)
  8006ac:	e8 df ff ff ff       	call   800690 <fd2num>
  8006b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8006b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8006b9:	c9                   	leave  
  8006ba:	c3                   	ret    

008006bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	57                   	push   %edi
  8006bf:	56                   	push   %esi
  8006c0:	53                   	push   %ebx
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8006c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8006c9:	a8 01                	test   $0x1,%al
  8006cb:	74 36                	je     800703 <fd_alloc+0x48>
  8006cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8006d2:	a8 01                	test   $0x1,%al
  8006d4:	74 2d                	je     800703 <fd_alloc+0x48>
  8006d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8006db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8006e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8006e5:	89 c3                	mov    %eax,%ebx
  8006e7:	89 c2                	mov    %eax,%edx
  8006e9:	c1 ea 16             	shr    $0x16,%edx
  8006ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8006ef:	f6 c2 01             	test   $0x1,%dl
  8006f2:	74 14                	je     800708 <fd_alloc+0x4d>
  8006f4:	89 c2                	mov    %eax,%edx
  8006f6:	c1 ea 0c             	shr    $0xc,%edx
  8006f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8006fc:	f6 c2 01             	test   $0x1,%dl
  8006ff:	75 10                	jne    800711 <fd_alloc+0x56>
  800701:	eb 05                	jmp    800708 <fd_alloc+0x4d>
  800703:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800708:	89 1f                	mov    %ebx,(%edi)
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80070f:	eb 17                	jmp    800728 <fd_alloc+0x6d>
  800711:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800716:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80071b:	75 c8                	jne    8006e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80071d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800723:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800728:	5b                   	pop    %ebx
  800729:	5e                   	pop    %esi
  80072a:	5f                   	pop    %edi
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	83 f8 1f             	cmp    $0x1f,%eax
  800736:	77 36                	ja     80076e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800738:	05 00 00 0d 00       	add    $0xd0000,%eax
  80073d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800740:	89 c2                	mov    %eax,%edx
  800742:	c1 ea 16             	shr    $0x16,%edx
  800745:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80074c:	f6 c2 01             	test   $0x1,%dl
  80074f:	74 1d                	je     80076e <fd_lookup+0x41>
  800751:	89 c2                	mov    %eax,%edx
  800753:	c1 ea 0c             	shr    $0xc,%edx
  800756:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80075d:	f6 c2 01             	test   $0x1,%dl
  800760:	74 0c                	je     80076e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800762:	8b 55 0c             	mov    0xc(%ebp),%edx
  800765:	89 02                	mov    %eax,(%edx)
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80076c:	eb 05                	jmp    800773 <fd_lookup+0x46>
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80077b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80077e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	e8 a0 ff ff ff       	call   80072d <fd_lookup>
  80078d:	85 c0                	test   %eax,%eax
  80078f:	78 0e                	js     80079f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800791:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
  800797:	89 50 04             	mov    %edx,0x4(%eax)
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	56                   	push   %esi
  8007a5:	53                   	push   %ebx
  8007a6:	83 ec 10             	sub    $0x10,%esp
  8007a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8007af:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8007b4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007b9:	be 94 21 80 00       	mov    $0x802194,%esi
		if (devtab[i]->dev_id == dev_id) {
  8007be:	39 08                	cmp    %ecx,(%eax)
  8007c0:	75 10                	jne    8007d2 <dev_lookup+0x31>
  8007c2:	eb 04                	jmp    8007c8 <dev_lookup+0x27>
  8007c4:	39 08                	cmp    %ecx,(%eax)
  8007c6:	75 0a                	jne    8007d2 <dev_lookup+0x31>
			*dev = devtab[i];
  8007c8:	89 03                	mov    %eax,(%ebx)
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8007cf:	90                   	nop
  8007d0:	eb 31                	jmp    800803 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007d2:	83 c2 01             	add    $0x1,%edx
  8007d5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	75 e8                	jne    8007c4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8007e1:	8b 40 48             	mov    0x48(%eax),%eax
  8007e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ec:	c7 04 24 18 21 80 00 	movl   $0x802118,(%esp)
  8007f3:	e8 15 08 00 00       	call   80100d <cprintf>
	*dev = 0;
  8007f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8007fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	83 ec 24             	sub    $0x24,%esp
  800811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800814:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	e8 07 ff ff ff       	call   80072d <fd_lookup>
  800826:	85 c0                	test   %eax,%eax
  800828:	78 53                	js     80087d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800834:	8b 00                	mov    (%eax),%eax
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	e8 63 ff ff ff       	call   8007a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083e:	85 c0                	test   %eax,%eax
  800840:	78 3b                	js     80087d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800842:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800847:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80084a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80084e:	74 2d                	je     80087d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800850:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800853:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085a:	00 00 00 
	stat->st_isdir = 0;
  80085d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800864:	00 00 00 
	stat->st_dev = dev;
  800867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800870:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800874:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800877:	89 14 24             	mov    %edx,(%esp)
  80087a:	ff 50 14             	call   *0x14(%eax)
}
  80087d:	83 c4 24             	add    $0x24,%esp
  800880:	5b                   	pop    %ebx
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	83 ec 24             	sub    $0x24,%esp
  80088a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800890:	89 44 24 04          	mov    %eax,0x4(%esp)
  800894:	89 1c 24             	mov    %ebx,(%esp)
  800897:	e8 91 fe ff ff       	call   80072d <fd_lookup>
  80089c:	85 c0                	test   %eax,%eax
  80089e:	78 5f                	js     8008ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	89 04 24             	mov    %eax,(%esp)
  8008af:	e8 ed fe ff ff       	call   8007a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b4:	85 c0                	test   %eax,%eax
  8008b6:	78 47                	js     8008ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008bb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8008bf:	75 23                	jne    8008e4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008c1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008c6:	8b 40 48             	mov    0x48(%eax),%eax
  8008c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d1:	c7 04 24 38 21 80 00 	movl   $0x802138,(%esp)
  8008d8:	e8 30 07 00 00       	call   80100d <cprintf>
  8008dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008e2:	eb 1b                	jmp    8008ff <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8008e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e7:	8b 48 18             	mov    0x18(%eax),%ecx
  8008ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ef:	85 c9                	test   %ecx,%ecx
  8008f1:	74 0c                	je     8008ff <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	89 14 24             	mov    %edx,(%esp)
  8008fd:	ff d1                	call   *%ecx
}
  8008ff:	83 c4 24             	add    $0x24,%esp
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	53                   	push   %ebx
  800909:	83 ec 24             	sub    $0x24,%esp
  80090c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80090f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800912:	89 44 24 04          	mov    %eax,0x4(%esp)
  800916:	89 1c 24             	mov    %ebx,(%esp)
  800919:	e8 0f fe ff ff       	call   80072d <fd_lookup>
  80091e:	85 c0                	test   %eax,%eax
  800920:	78 66                	js     800988 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800922:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800925:	89 44 24 04          	mov    %eax,0x4(%esp)
  800929:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80092c:	8b 00                	mov    (%eax),%eax
  80092e:	89 04 24             	mov    %eax,(%esp)
  800931:	e8 6b fe ff ff       	call   8007a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800936:	85 c0                	test   %eax,%eax
  800938:	78 4e                	js     800988 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80093a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80093d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800941:	75 23                	jne    800966 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800943:	a1 04 40 80 00       	mov    0x804004,%eax
  800948:	8b 40 48             	mov    0x48(%eax),%eax
  80094b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80094f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800953:	c7 04 24 59 21 80 00 	movl   $0x802159,(%esp)
  80095a:	e8 ae 06 00 00       	call   80100d <cprintf>
  80095f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800964:	eb 22                	jmp    800988 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800969:	8b 48 0c             	mov    0xc(%eax),%ecx
  80096c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800971:	85 c9                	test   %ecx,%ecx
  800973:	74 13                	je     800988 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800975:	8b 45 10             	mov    0x10(%ebp),%eax
  800978:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800983:	89 14 24             	mov    %edx,(%esp)
  800986:	ff d1                	call   *%ecx
}
  800988:	83 c4 24             	add    $0x24,%esp
  80098b:	5b                   	pop    %ebx
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	53                   	push   %ebx
  800992:	83 ec 24             	sub    $0x24,%esp
  800995:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800998:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80099b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099f:	89 1c 24             	mov    %ebx,(%esp)
  8009a2:	e8 86 fd ff ff       	call   80072d <fd_lookup>
  8009a7:	85 c0                	test   %eax,%eax
  8009a9:	78 6b                	js     800a16 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b5:	8b 00                	mov    (%eax),%eax
  8009b7:	89 04 24             	mov    %eax,(%esp)
  8009ba:	e8 e2 fd ff ff       	call   8007a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009bf:	85 c0                	test   %eax,%eax
  8009c1:	78 53                	js     800a16 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009c6:	8b 42 08             	mov    0x8(%edx),%eax
  8009c9:	83 e0 03             	and    $0x3,%eax
  8009cc:	83 f8 01             	cmp    $0x1,%eax
  8009cf:	75 23                	jne    8009f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8009d6:	8b 40 48             	mov    0x48(%eax),%eax
  8009d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e1:	c7 04 24 76 21 80 00 	movl   $0x802176,(%esp)
  8009e8:	e8 20 06 00 00       	call   80100d <cprintf>
  8009ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8009f2:	eb 22                	jmp    800a16 <read+0x88>
	}
	if (!dev->dev_read)
  8009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f7:	8b 48 08             	mov    0x8(%eax),%ecx
  8009fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8009ff:	85 c9                	test   %ecx,%ecx
  800a01:	74 13                	je     800a16 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a03:	8b 45 10             	mov    0x10(%ebp),%eax
  800a06:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a11:	89 14 24             	mov    %edx,(%esp)
  800a14:	ff d1                	call   *%ecx
}
  800a16:	83 c4 24             	add    $0x24,%esp
  800a19:	5b                   	pop    %ebx
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	83 ec 1c             	sub    $0x1c,%esp
  800a25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a28:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3a:	85 f6                	test   %esi,%esi
  800a3c:	74 29                	je     800a67 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a3e:	89 f0                	mov    %esi,%eax
  800a40:	29 d0                	sub    %edx,%eax
  800a42:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a46:	03 55 0c             	add    0xc(%ebp),%edx
  800a49:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a4d:	89 3c 24             	mov    %edi,(%esp)
  800a50:	e8 39 ff ff ff       	call   80098e <read>
		if (m < 0)
  800a55:	85 c0                	test   %eax,%eax
  800a57:	78 0e                	js     800a67 <readn+0x4b>
			return m;
		if (m == 0)
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	74 08                	je     800a65 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a5d:	01 c3                	add    %eax,%ebx
  800a5f:	89 da                	mov    %ebx,%edx
  800a61:	39 f3                	cmp    %esi,%ebx
  800a63:	72 d9                	jb     800a3e <readn+0x22>
  800a65:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a67:	83 c4 1c             	add    $0x1c,%esp
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	83 ec 20             	sub    $0x20,%esp
  800a77:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a7a:	89 34 24             	mov    %esi,(%esp)
  800a7d:	e8 0e fc ff ff       	call   800690 <fd2num>
  800a82:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800a85:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a89:	89 04 24             	mov    %eax,(%esp)
  800a8c:	e8 9c fc ff ff       	call   80072d <fd_lookup>
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	85 c0                	test   %eax,%eax
  800a95:	78 05                	js     800a9c <fd_close+0x2d>
  800a97:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a9a:	74 0c                	je     800aa8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800a9c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800aa0:	19 c0                	sbb    %eax,%eax
  800aa2:	f7 d0                	not    %eax
  800aa4:	21 c3                	and    %eax,%ebx
  800aa6:	eb 3d                	jmp    800ae5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800aa8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aaf:	8b 06                	mov    (%esi),%eax
  800ab1:	89 04 24             	mov    %eax,(%esp)
  800ab4:	e8 e8 fc ff ff       	call   8007a1 <dev_lookup>
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	85 c0                	test   %eax,%eax
  800abd:	78 16                	js     800ad5 <fd_close+0x66>
		if (dev->dev_close)
  800abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac2:	8b 40 10             	mov    0x10(%eax),%eax
  800ac5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aca:	85 c0                	test   %eax,%eax
  800acc:	74 07                	je     800ad5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800ace:	89 34 24             	mov    %esi,(%esp)
  800ad1:	ff d0                	call   *%eax
  800ad3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ad5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ad9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ae0:	e8 2c f9 ff ff       	call   800411 <sys_page_unmap>
	return r;
}
  800ae5:	89 d8                	mov    %ebx,%eax
  800ae7:	83 c4 20             	add    $0x20,%esp
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800af4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	89 04 24             	mov    %eax,(%esp)
  800b01:	e8 27 fc ff ff       	call   80072d <fd_lookup>
  800b06:	85 c0                	test   %eax,%eax
  800b08:	78 13                	js     800b1d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800b0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800b11:	00 
  800b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b15:	89 04 24             	mov    %eax,(%esp)
  800b18:	e8 52 ff ff ff       	call   800a6f <fd_close>
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 18             	sub    $0x18,%esp
  800b25:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b28:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b32:	00 
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	e8 79 03 00 00       	call   800eb7 <open>
  800b3e:	89 c3                	mov    %eax,%ebx
  800b40:	85 c0                	test   %eax,%eax
  800b42:	78 1b                	js     800b5f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4b:	89 1c 24             	mov    %ebx,(%esp)
  800b4e:	e8 b7 fc ff ff       	call   80080a <fstat>
  800b53:	89 c6                	mov    %eax,%esi
	close(fd);
  800b55:	89 1c 24             	mov    %ebx,(%esp)
  800b58:	e8 91 ff ff ff       	call   800aee <close>
  800b5d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800b5f:	89 d8                	mov    %ebx,%eax
  800b61:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b64:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b67:	89 ec                	mov    %ebp,%esp
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 14             	sub    $0x14,%esp
  800b72:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800b77:	89 1c 24             	mov    %ebx,(%esp)
  800b7a:	e8 6f ff ff ff       	call   800aee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b7f:	83 c3 01             	add    $0x1,%ebx
  800b82:	83 fb 20             	cmp    $0x20,%ebx
  800b85:	75 f0                	jne    800b77 <close_all+0xc>
		close(i);
}
  800b87:	83 c4 14             	add    $0x14,%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 58             	sub    $0x58,%esp
  800b93:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b96:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b99:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	89 04 24             	mov    %eax,(%esp)
  800bac:	e8 7c fb ff ff       	call   80072d <fd_lookup>
  800bb1:	89 c3                	mov    %eax,%ebx
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	0f 88 e0 00 00 00    	js     800c9b <dup+0x10e>
		return r;
	close(newfdnum);
  800bbb:	89 3c 24             	mov    %edi,(%esp)
  800bbe:	e8 2b ff ff ff       	call   800aee <close>

	newfd = INDEX2FD(newfdnum);
  800bc3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800bc9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bcf:	89 04 24             	mov    %eax,(%esp)
  800bd2:	e8 c9 fa ff ff       	call   8006a0 <fd2data>
  800bd7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800bd9:	89 34 24             	mov    %esi,(%esp)
  800bdc:	e8 bf fa ff ff       	call   8006a0 <fd2data>
  800be1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800be4:	89 da                	mov    %ebx,%edx
  800be6:	89 d8                	mov    %ebx,%eax
  800be8:	c1 e8 16             	shr    $0x16,%eax
  800beb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800bf2:	a8 01                	test   $0x1,%al
  800bf4:	74 43                	je     800c39 <dup+0xac>
  800bf6:	c1 ea 0c             	shr    $0xc,%edx
  800bf9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c00:	a8 01                	test   $0x1,%al
  800c02:	74 35                	je     800c39 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800c04:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c0b:	25 07 0e 00 00       	and    $0xe07,%eax
  800c10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c22:	00 
  800c23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c2e:	e8 4a f8 ff ff       	call   80047d <sys_page_map>
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	85 c0                	test   %eax,%eax
  800c37:	78 3f                	js     800c78 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3c:	89 c2                	mov    %eax,%edx
  800c3e:	c1 ea 0c             	shr    $0xc,%edx
  800c41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800c48:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800c4e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c52:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c5d:	00 
  800c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c69:	e8 0f f8 ff ff       	call   80047d <sys_page_map>
  800c6e:	89 c3                	mov    %eax,%ebx
  800c70:	85 c0                	test   %eax,%eax
  800c72:	78 04                	js     800c78 <dup+0xeb>
  800c74:	89 fb                	mov    %edi,%ebx
  800c76:	eb 23                	jmp    800c9b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c78:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c83:	e8 89 f7 ff ff       	call   800411 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c96:	e8 76 f7 ff ff       	call   800411 <sys_page_unmap>
	return r;
}
  800c9b:	89 d8                	mov    %ebx,%eax
  800c9d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ca6:	89 ec                	mov    %ebp,%esp
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
	...

00800cac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 18             	sub    $0x18,%esp
  800cb2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800cb5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800cb8:	89 c3                	mov    %eax,%ebx
  800cba:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800cbc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cc3:	75 11                	jne    800cd6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cc5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ccc:	e8 5f 10 00 00       	call   801d30 <ipc_find_env>
  800cd1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cd6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800cdd:	00 
  800cde:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ce5:	00 
  800ce6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cea:	a1 00 40 80 00       	mov    0x804000,%eax
  800cef:	89 04 24             	mov    %eax,(%esp)
  800cf2:	e8 84 10 00 00       	call   801d7b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800cfe:	00 
  800cff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d0a:	e8 ea 10 00 00       	call   801df9 <ipc_recv>
}
  800d0f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d12:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d15:	89 ec                	mov    %ebp,%esp
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	8b 40 0c             	mov    0xc(%eax),%eax
  800d25:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d32:	ba 00 00 00 00       	mov    $0x0,%edx
  800d37:	b8 02 00 00 00       	mov    $0x2,%eax
  800d3c:	e8 6b ff ff ff       	call   800cac <fsipc>
}
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    

00800d43 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	8b 40 0c             	mov    0xc(%eax),%eax
  800d4f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d54:	ba 00 00 00 00       	mov    $0x0,%edx
  800d59:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5e:	e8 49 ff ff ff       	call   800cac <fsipc>
}
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    

00800d65 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d70:	b8 08 00 00 00       	mov    $0x8,%eax
  800d75:	e8 32 ff ff ff       	call   800cac <fsipc>
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 14             	sub    $0x14,%esp
  800d83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	8b 40 0c             	mov    0xc(%eax),%eax
  800d8c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d91:	ba 00 00 00 00       	mov    $0x0,%edx
  800d96:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9b:	e8 0c ff ff ff       	call   800cac <fsipc>
  800da0:	85 c0                	test   %eax,%eax
  800da2:	78 2b                	js     800dcf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800da4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800dab:	00 
  800dac:	89 1c 24             	mov    %ebx,(%esp)
  800daf:	e8 86 0b 00 00       	call   80193a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800db4:	a1 80 50 80 00       	mov    0x805080,%eax
  800db9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dbf:	a1 84 50 80 00       	mov    0x805084,%eax
  800dc4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800dca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800dcf:	83 c4 14             	add    $0x14,%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 18             	sub    $0x18,%esp
  800ddb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dde:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800de3:	76 05                	jbe    800dea <devfile_write+0x15>
  800de5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	8b 52 0c             	mov    0xc(%edx),%edx
  800df0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800df6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e06:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800e0d:	e8 13 0d 00 00       	call   801b25 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800e12:	ba 00 00 00 00       	mov    $0x0,%edx
  800e17:	b8 04 00 00 00       	mov    $0x4,%eax
  800e1c:	e8 8b fe ff ff       	call   800cac <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800e21:	c9                   	leave  
  800e22:	c3                   	ret    

00800e23 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	53                   	push   %ebx
  800e27:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e30:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800e35:	8b 45 10             	mov    0x10(%ebp),%eax
  800e38:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e42:	b8 03 00 00 00       	mov    $0x3,%eax
  800e47:	e8 60 fe ff ff       	call   800cac <fsipc>
  800e4c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	78 17                	js     800e69 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800e52:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e56:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800e5d:	00 
  800e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e61:	89 04 24             	mov    %eax,(%esp)
  800e64:	e8 bc 0c 00 00       	call   801b25 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	83 c4 14             	add    $0x14,%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	53                   	push   %ebx
  800e75:	83 ec 14             	sub    $0x14,%esp
  800e78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800e7b:	89 1c 24             	mov    %ebx,(%esp)
  800e7e:	e8 6d 0a 00 00       	call   8018f0 <strlen>
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800e8a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800e90:	7f 1f                	jg     800eb1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800e92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e96:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800e9d:	e8 98 0a 00 00       	call   80193a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800ea2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea7:	b8 07 00 00 00       	mov    $0x7,%eax
  800eac:	e8 fb fd ff ff       	call   800cac <fsipc>
}
  800eb1:	83 c4 14             	add    $0x14,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 28             	sub    $0x28,%esp
  800ebd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ec0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800ec3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  800ec6:	89 34 24             	mov    %esi,(%esp)
  800ec9:	e8 22 0a 00 00       	call   8018f0 <strlen>
  800ece:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800ed3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ed8:	7f 6d                	jg     800f47 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  800eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edd:	89 04 24             	mov    %eax,(%esp)
  800ee0:	e8 d6 f7 ff ff       	call   8006bb <fd_alloc>
  800ee5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	78 5c                	js     800f47 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  800eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eee:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  800ef3:	89 34 24             	mov    %esi,(%esp)
  800ef6:	e8 f5 09 00 00       	call   8018f0 <strlen>
  800efb:	83 c0 01             	add    $0x1,%eax
  800efe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f02:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f06:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800f0d:	e8 13 0c 00 00       	call   801b25 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  800f12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f15:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1a:	e8 8d fd ff ff       	call   800cac <fsipc>
  800f1f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  800f21:	85 c0                	test   %eax,%eax
  800f23:	79 15                	jns    800f3a <open+0x83>
             fd_close(fd,0);
  800f25:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f2c:	00 
  800f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f30:	89 04 24             	mov    %eax,(%esp)
  800f33:	e8 37 fb ff ff       	call   800a6f <fd_close>
             return r;
  800f38:	eb 0d                	jmp    800f47 <open+0x90>
        }
        return fd2num(fd);
  800f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f3d:	89 04 24             	mov    %eax,(%esp)
  800f40:	e8 4b f7 ff ff       	call   800690 <fd2num>
  800f45:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  800f47:	89 d8                	mov    %ebx,%eax
  800f49:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f4c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800f4f:	89 ec                	mov    %ebp,%esp
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    
	...

00800f54 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f5c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f5f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800f65:	e8 70 f6 ff ff       	call   8005da <sys_getenvid>
  800f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f71:	8b 55 08             	mov    0x8(%ebp),%edx
  800f74:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f78:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f80:	c7 04 24 9c 21 80 00 	movl   $0x80219c,(%esp)
  800f87:	e8 81 00 00 00       	call   80100d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f90:	8b 45 10             	mov    0x10(%ebp),%eax
  800f93:	89 04 24             	mov    %eax,(%esp)
  800f96:	e8 11 00 00 00       	call   800fac <vcprintf>
	cprintf("\n");
  800f9b:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
  800fa2:	e8 66 00 00 00       	call   80100d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fa7:	cc                   	int3   
  800fa8:	eb fd                	jmp    800fa7 <_panic+0x53>
	...

00800fac <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800fb5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800fbc:	00 00 00 
	b.cnt = 0;
  800fbf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800fc6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe1:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800fe8:	e8 cf 01 00 00       	call   8011bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800fed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ffd:	89 04 24             	mov    %eax,(%esp)
  801000:	e8 ef f0 ff ff       	call   8000f4 <sys_cputs>

	return b.cnt;
}
  801005:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    

0080100d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801013:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101a:	8b 45 08             	mov    0x8(%ebp),%eax
  80101d:	89 04 24             	mov    %eax,(%esp)
  801020:	e8 87 ff ff ff       	call   800fac <vcprintf>
	va_end(ap);

	return cnt;
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	53                   	push   %ebx
  80102b:	83 ec 14             	sub    $0x14,%esp
  80102e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801031:	8b 03                	mov    (%ebx),%eax
  801033:	8b 55 08             	mov    0x8(%ebp),%edx
  801036:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80103a:	83 c0 01             	add    $0x1,%eax
  80103d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80103f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801044:	75 19                	jne    80105f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801046:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80104d:	00 
  80104e:	8d 43 08             	lea    0x8(%ebx),%eax
  801051:	89 04 24             	mov    %eax,(%esp)
  801054:	e8 9b f0 ff ff       	call   8000f4 <sys_cputs>
		b->idx = 0;
  801059:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80105f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801063:	83 c4 14             	add    $0x14,%esp
  801066:	5b                   	pop    %ebx
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    
  801069:	00 00                	add    %al,(%eax)
  80106b:	00 00                	add    %al,(%eax)
  80106d:	00 00                	add    %al,(%eax)
	...

00801070 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 4c             	sub    $0x4c,%esp
  801079:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80107c:	89 d6                	mov    %edx,%esi
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
  801081:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801084:	8b 55 0c             	mov    0xc(%ebp),%edx
  801087:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80108a:	8b 45 10             	mov    0x10(%ebp),%eax
  80108d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801090:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  801093:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801096:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109b:	39 d1                	cmp    %edx,%ecx
  80109d:	72 07                	jb     8010a6 <printnum_v2+0x36>
  80109f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8010a2:	39 d0                	cmp    %edx,%eax
  8010a4:	77 5f                	ja     801105 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8010a6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8010aa:	83 eb 01             	sub    $0x1,%ebx
  8010ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010b9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8010bd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8010c0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8010c3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8010c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d1:	00 
  8010d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010df:	e8 8c 0d 00 00       	call   801e70 <__udivdi3>
  8010e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8010e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8010ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010f2:	89 04 24             	mov    %eax,(%esp)
  8010f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010f9:	89 f2                	mov    %esi,%edx
  8010fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010fe:	e8 6d ff ff ff       	call   801070 <printnum_v2>
  801103:	eb 1e                	jmp    801123 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801105:	83 ff 2d             	cmp    $0x2d,%edi
  801108:	74 19                	je     801123 <printnum_v2+0xb3>
		while (--width > 0)
  80110a:	83 eb 01             	sub    $0x1,%ebx
  80110d:	85 db                	test   %ebx,%ebx
  80110f:	90                   	nop
  801110:	7e 11                	jle    801123 <printnum_v2+0xb3>
			putch(padc, putdat);
  801112:	89 74 24 04          	mov    %esi,0x4(%esp)
  801116:	89 3c 24             	mov    %edi,(%esp)
  801119:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80111c:	83 eb 01             	sub    $0x1,%ebx
  80111f:	85 db                	test   %ebx,%ebx
  801121:	7f ef                	jg     801112 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801123:	89 74 24 04          	mov    %esi,0x4(%esp)
  801127:	8b 74 24 04          	mov    0x4(%esp),%esi
  80112b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80112e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801132:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801139:	00 
  80113a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80113d:	89 14 24             	mov    %edx,(%esp)
  801140:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801143:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801147:	e8 54 0e 00 00       	call   801fa0 <__umoddi3>
  80114c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801150:	0f be 80 bf 21 80 00 	movsbl 0x8021bf(%eax),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80115d:	83 c4 4c             	add    $0x4c,%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801168:	83 fa 01             	cmp    $0x1,%edx
  80116b:	7e 0e                	jle    80117b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80116d:	8b 10                	mov    (%eax),%edx
  80116f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801172:	89 08                	mov    %ecx,(%eax)
  801174:	8b 02                	mov    (%edx),%eax
  801176:	8b 52 04             	mov    0x4(%edx),%edx
  801179:	eb 22                	jmp    80119d <getuint+0x38>
	else if (lflag)
  80117b:	85 d2                	test   %edx,%edx
  80117d:	74 10                	je     80118f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80117f:	8b 10                	mov    (%eax),%edx
  801181:	8d 4a 04             	lea    0x4(%edx),%ecx
  801184:	89 08                	mov    %ecx,(%eax)
  801186:	8b 02                	mov    (%edx),%eax
  801188:	ba 00 00 00 00       	mov    $0x0,%edx
  80118d:	eb 0e                	jmp    80119d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80118f:	8b 10                	mov    (%eax),%edx
  801191:	8d 4a 04             	lea    0x4(%edx),%ecx
  801194:	89 08                	mov    %ecx,(%eax)
  801196:	8b 02                	mov    (%edx),%eax
  801198:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011a9:	8b 10                	mov    (%eax),%edx
  8011ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ae:	73 0a                	jae    8011ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b3:	88 0a                	mov    %cl,(%edx)
  8011b5:	83 c2 01             	add    $0x1,%edx
  8011b8:	89 10                	mov    %edx,(%eax)
}
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	57                   	push   %edi
  8011c0:	56                   	push   %esi
  8011c1:	53                   	push   %ebx
  8011c2:	83 ec 6c             	sub    $0x6c,%esp
  8011c5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8011c8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8011cf:	eb 1a                	jmp    8011eb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	0f 84 66 06 00 00    	je     80183f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8011d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011e0:	89 04 24             	mov    %eax,(%esp)
  8011e3:	ff 55 08             	call   *0x8(%ebp)
  8011e6:	eb 03                	jmp    8011eb <vprintfmt+0x2f>
  8011e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011eb:	0f b6 07             	movzbl (%edi),%eax
  8011ee:	83 c7 01             	add    $0x1,%edi
  8011f1:	83 f8 25             	cmp    $0x25,%eax
  8011f4:	75 db                	jne    8011d1 <vprintfmt+0x15>
  8011f6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8011fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ff:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801206:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80120b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801212:	be 00 00 00 00       	mov    $0x0,%esi
  801217:	eb 06                	jmp    80121f <vprintfmt+0x63>
  801219:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80121d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80121f:	0f b6 17             	movzbl (%edi),%edx
  801222:	0f b6 c2             	movzbl %dl,%eax
  801225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801228:	8d 47 01             	lea    0x1(%edi),%eax
  80122b:	83 ea 23             	sub    $0x23,%edx
  80122e:	80 fa 55             	cmp    $0x55,%dl
  801231:	0f 87 60 05 00 00    	ja     801797 <vprintfmt+0x5db>
  801237:	0f b6 d2             	movzbl %dl,%edx
  80123a:	ff 24 95 a0 23 80 00 	jmp    *0x8023a0(,%edx,4)
  801241:	b9 01 00 00 00       	mov    $0x1,%ecx
  801246:	eb d5                	jmp    80121d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801248:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80124b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80124e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801251:	8d 7a d0             	lea    -0x30(%edx),%edi
  801254:	83 ff 09             	cmp    $0x9,%edi
  801257:	76 08                	jbe    801261 <vprintfmt+0xa5>
  801259:	eb 40                	jmp    80129b <vprintfmt+0xdf>
  80125b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80125f:	eb bc                	jmp    80121d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801261:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801264:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  801267:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80126b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80126e:	8d 7a d0             	lea    -0x30(%edx),%edi
  801271:	83 ff 09             	cmp    $0x9,%edi
  801274:	76 eb                	jbe    801261 <vprintfmt+0xa5>
  801276:	eb 23                	jmp    80129b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801278:	8b 55 14             	mov    0x14(%ebp),%edx
  80127b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80127e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801281:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  801283:	eb 16                	jmp    80129b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  801285:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801288:	c1 fa 1f             	sar    $0x1f,%edx
  80128b:	f7 d2                	not    %edx
  80128d:	21 55 d8             	and    %edx,-0x28(%ebp)
  801290:	eb 8b                	jmp    80121d <vprintfmt+0x61>
  801292:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801299:	eb 82                	jmp    80121d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80129b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80129f:	0f 89 78 ff ff ff    	jns    80121d <vprintfmt+0x61>
  8012a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8012a8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8012ab:	e9 6d ff ff ff       	jmp    80121d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012b0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8012b3:	e9 65 ff ff ff       	jmp    80121d <vprintfmt+0x61>
  8012b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8012be:	8d 50 04             	lea    0x4(%eax),%edx
  8012c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8012c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012cb:	8b 00                	mov    (%eax),%eax
  8012cd:	89 04 24             	mov    %eax,(%esp)
  8012d0:	ff 55 08             	call   *0x8(%ebp)
  8012d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8012d6:	e9 10 ff ff ff       	jmp    8011eb <vprintfmt+0x2f>
  8012db:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8012de:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e1:	8d 50 04             	lea    0x4(%eax),%edx
  8012e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8012e7:	8b 00                	mov    (%eax),%eax
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	c1 fa 1f             	sar    $0x1f,%edx
  8012ee:	31 d0                	xor    %edx,%eax
  8012f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012f2:	83 f8 0f             	cmp    $0xf,%eax
  8012f5:	7f 0b                	jg     801302 <vprintfmt+0x146>
  8012f7:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8012fe:	85 d2                	test   %edx,%edx
  801300:	75 26                	jne    801328 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801302:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801306:	c7 44 24 08 d0 21 80 	movl   $0x8021d0,0x8(%esp)
  80130d:	00 
  80130e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801311:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801315:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801318:	89 1c 24             	mov    %ebx,(%esp)
  80131b:	e8 a7 05 00 00       	call   8018c7 <printfmt>
  801320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801323:	e9 c3 fe ff ff       	jmp    8011eb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801328:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80132c:	c7 44 24 08 d9 21 80 	movl   $0x8021d9,0x8(%esp)
  801333:	00 
  801334:	8b 45 0c             	mov    0xc(%ebp),%eax
  801337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133b:	8b 55 08             	mov    0x8(%ebp),%edx
  80133e:	89 14 24             	mov    %edx,(%esp)
  801341:	e8 81 05 00 00       	call   8018c7 <printfmt>
  801346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801349:	e9 9d fe ff ff       	jmp    8011eb <vprintfmt+0x2f>
  80134e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801351:	89 c7                	mov    %eax,%edi
  801353:	89 d9                	mov    %ebx,%ecx
  801355:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801358:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80135b:	8b 45 14             	mov    0x14(%ebp),%eax
  80135e:	8d 50 04             	lea    0x4(%eax),%edx
  801361:	89 55 14             	mov    %edx,0x14(%ebp)
  801364:	8b 30                	mov    (%eax),%esi
  801366:	85 f6                	test   %esi,%esi
  801368:	75 05                	jne    80136f <vprintfmt+0x1b3>
  80136a:	be dc 21 80 00       	mov    $0x8021dc,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80136f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  801373:	7e 06                	jle    80137b <vprintfmt+0x1bf>
  801375:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  801379:	75 10                	jne    80138b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80137b:	0f be 06             	movsbl (%esi),%eax
  80137e:	85 c0                	test   %eax,%eax
  801380:	0f 85 a2 00 00 00    	jne    801428 <vprintfmt+0x26c>
  801386:	e9 92 00 00 00       	jmp    80141d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80138b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80138f:	89 34 24             	mov    %esi,(%esp)
  801392:	e8 74 05 00 00       	call   80190b <strnlen>
  801397:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80139a:	29 c2                	sub    %eax,%edx
  80139c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80139f:	85 d2                	test   %edx,%edx
  8013a1:	7e d8                	jle    80137b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8013a3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8013a7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8013aa:	89 d3                	mov    %edx,%ebx
  8013ac:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8013af:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8013b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013b5:	89 ce                	mov    %ecx,%esi
  8013b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013bb:	89 34 24             	mov    %esi,(%esp)
  8013be:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c1:	83 eb 01             	sub    $0x1,%ebx
  8013c4:	85 db                	test   %ebx,%ebx
  8013c6:	7f ef                	jg     8013b7 <vprintfmt+0x1fb>
  8013c8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8013cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013ce:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8013d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8013d8:	eb a1                	jmp    80137b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013da:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8013de:	74 1b                	je     8013fb <vprintfmt+0x23f>
  8013e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013e3:	83 fa 5e             	cmp    $0x5e,%edx
  8013e6:	76 13                	jbe    8013fb <vprintfmt+0x23f>
					putch('?', putdat);
  8013e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8013f6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013f9:	eb 0d                	jmp    801408 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8013fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801402:	89 04 24             	mov    %eax,(%esp)
  801405:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801408:	83 ef 01             	sub    $0x1,%edi
  80140b:	0f be 06             	movsbl (%esi),%eax
  80140e:	85 c0                	test   %eax,%eax
  801410:	74 05                	je     801417 <vprintfmt+0x25b>
  801412:	83 c6 01             	add    $0x1,%esi
  801415:	eb 1a                	jmp    801431 <vprintfmt+0x275>
  801417:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80141a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80141d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801421:	7f 1f                	jg     801442 <vprintfmt+0x286>
  801423:	e9 c0 fd ff ff       	jmp    8011e8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801428:	83 c6 01             	add    $0x1,%esi
  80142b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80142e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801431:	85 db                	test   %ebx,%ebx
  801433:	78 a5                	js     8013da <vprintfmt+0x21e>
  801435:	83 eb 01             	sub    $0x1,%ebx
  801438:	79 a0                	jns    8013da <vprintfmt+0x21e>
  80143a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80143d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801440:	eb db                	jmp    80141d <vprintfmt+0x261>
  801442:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801445:	8b 75 0c             	mov    0xc(%ebp),%esi
  801448:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80144b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80144e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801452:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801459:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80145b:	83 eb 01             	sub    $0x1,%ebx
  80145e:	85 db                	test   %ebx,%ebx
  801460:	7f ec                	jg     80144e <vprintfmt+0x292>
  801462:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801465:	e9 81 fd ff ff       	jmp    8011eb <vprintfmt+0x2f>
  80146a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80146d:	83 fe 01             	cmp    $0x1,%esi
  801470:	7e 10                	jle    801482 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801472:	8b 45 14             	mov    0x14(%ebp),%eax
  801475:	8d 50 08             	lea    0x8(%eax),%edx
  801478:	89 55 14             	mov    %edx,0x14(%ebp)
  80147b:	8b 18                	mov    (%eax),%ebx
  80147d:	8b 70 04             	mov    0x4(%eax),%esi
  801480:	eb 26                	jmp    8014a8 <vprintfmt+0x2ec>
	else if (lflag)
  801482:	85 f6                	test   %esi,%esi
  801484:	74 12                	je     801498 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801486:	8b 45 14             	mov    0x14(%ebp),%eax
  801489:	8d 50 04             	lea    0x4(%eax),%edx
  80148c:	89 55 14             	mov    %edx,0x14(%ebp)
  80148f:	8b 18                	mov    (%eax),%ebx
  801491:	89 de                	mov    %ebx,%esi
  801493:	c1 fe 1f             	sar    $0x1f,%esi
  801496:	eb 10                	jmp    8014a8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801498:	8b 45 14             	mov    0x14(%ebp),%eax
  80149b:	8d 50 04             	lea    0x4(%eax),%edx
  80149e:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a1:	8b 18                	mov    (%eax),%ebx
  8014a3:	89 de                	mov    %ebx,%esi
  8014a5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8014a8:	83 f9 01             	cmp    $0x1,%ecx
  8014ab:	75 1e                	jne    8014cb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8014ad:	85 f6                	test   %esi,%esi
  8014af:	78 1a                	js     8014cb <vprintfmt+0x30f>
  8014b1:	85 f6                	test   %esi,%esi
  8014b3:	7f 05                	jg     8014ba <vprintfmt+0x2fe>
  8014b5:	83 fb 00             	cmp    $0x0,%ebx
  8014b8:	76 11                	jbe    8014cb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8014ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014c1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8014c8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8014cb:	85 f6                	test   %esi,%esi
  8014cd:	78 13                	js     8014e2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014cf:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8014d2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8014d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014dd:	e9 da 00 00 00       	jmp    8015bc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8014e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8014f0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014f3:	89 da                	mov    %ebx,%edx
  8014f5:	89 f1                	mov    %esi,%ecx
  8014f7:	f7 da                	neg    %edx
  8014f9:	83 d1 00             	adc    $0x0,%ecx
  8014fc:	f7 d9                	neg    %ecx
  8014fe:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801501:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801507:	b8 0a 00 00 00       	mov    $0xa,%eax
  80150c:	e9 ab 00 00 00       	jmp    8015bc <vprintfmt+0x400>
  801511:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801514:	89 f2                	mov    %esi,%edx
  801516:	8d 45 14             	lea    0x14(%ebp),%eax
  801519:	e8 47 fc ff ff       	call   801165 <getuint>
  80151e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801521:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801527:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80152c:	e9 8b 00 00 00       	jmp    8015bc <vprintfmt+0x400>
  801531:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801534:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801537:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80153b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801542:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801545:	89 f2                	mov    %esi,%edx
  801547:	8d 45 14             	lea    0x14(%ebp),%eax
  80154a:	e8 16 fc ff ff       	call   801165 <getuint>
  80154f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801552:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801558:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80155d:	eb 5d                	jmp    8015bc <vprintfmt+0x400>
  80155f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801565:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801569:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801570:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801573:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801577:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80157e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801581:	8b 45 14             	mov    0x14(%ebp),%eax
  801584:	8d 50 04             	lea    0x4(%eax),%edx
  801587:	89 55 14             	mov    %edx,0x14(%ebp)
  80158a:	8b 10                	mov    (%eax),%edx
  80158c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801591:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801594:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80159a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80159f:	eb 1b                	jmp    8015bc <vprintfmt+0x400>
  8015a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015a4:	89 f2                	mov    %esi,%edx
  8015a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a9:	e8 b7 fb ff ff       	call   801165 <getuint>
  8015ae:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8015b1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8015b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015b7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015bc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8015c0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8015c6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8015ca:	77 09                	ja     8015d5 <vprintfmt+0x419>
  8015cc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8015cf:	0f 82 ac 00 00 00    	jb     801681 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8015d5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8015d8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8015dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8015df:	83 ea 01             	sub    $0x1,%edx
  8015e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ea:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015ee:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015f2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8015f5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8015f8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8015fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801606:	00 
  801607:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80160a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80160d:	89 0c 24             	mov    %ecx,(%esp)
  801610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801614:	e8 57 08 00 00       	call   801e70 <__udivdi3>
  801619:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80161c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80161f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801623:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801627:	89 04 24             	mov    %eax,(%esp)
  80162a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80162e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801631:	8b 45 08             	mov    0x8(%ebp),%eax
  801634:	e8 37 fa ff ff       	call   801070 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80163c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801640:	8b 74 24 04          	mov    0x4(%esp),%esi
  801644:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801647:	89 44 24 08          	mov    %eax,0x8(%esp)
  80164b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801652:	00 
  801653:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801656:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801659:	89 14 24             	mov    %edx,(%esp)
  80165c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801660:	e8 3b 09 00 00       	call   801fa0 <__umoddi3>
  801665:	89 74 24 04          	mov    %esi,0x4(%esp)
  801669:	0f be 80 bf 21 80 00 	movsbl 0x8021bf(%eax),%eax
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801676:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80167a:	74 54                	je     8016d0 <vprintfmt+0x514>
  80167c:	e9 67 fb ff ff       	jmp    8011e8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801681:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801685:	8d 76 00             	lea    0x0(%esi),%esi
  801688:	0f 84 2a 01 00 00    	je     8017b8 <vprintfmt+0x5fc>
		while (--width > 0)
  80168e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801691:	83 ef 01             	sub    $0x1,%edi
  801694:	85 ff                	test   %edi,%edi
  801696:	0f 8e 5e 01 00 00    	jle    8017fa <vprintfmt+0x63e>
  80169c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80169f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8016a2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8016a5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8016a8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016ab:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8016ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b2:	89 1c 24             	mov    %ebx,(%esp)
  8016b5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8016b8:	83 ef 01             	sub    $0x1,%edi
  8016bb:	85 ff                	test   %edi,%edi
  8016bd:	7f ef                	jg     8016ae <vprintfmt+0x4f2>
  8016bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8016c5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8016c8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8016cb:	e9 2a 01 00 00       	jmp    8017fa <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8016d0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8016d3:	83 eb 01             	sub    $0x1,%ebx
  8016d6:	85 db                	test   %ebx,%ebx
  8016d8:	0f 8e 0a fb ff ff    	jle    8011e8 <vprintfmt+0x2c>
  8016de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016e1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8016e4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8016e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016eb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8016f2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8016f4:	83 eb 01             	sub    $0x1,%ebx
  8016f7:	85 db                	test   %ebx,%ebx
  8016f9:	7f ec                	jg     8016e7 <vprintfmt+0x52b>
  8016fb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8016fe:	e9 e8 fa ff ff       	jmp    8011eb <vprintfmt+0x2f>
  801703:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801706:	8b 45 14             	mov    0x14(%ebp),%eax
  801709:	8d 50 04             	lea    0x4(%eax),%edx
  80170c:	89 55 14             	mov    %edx,0x14(%ebp)
  80170f:	8b 00                	mov    (%eax),%eax
  801711:	85 c0                	test   %eax,%eax
  801713:	75 2a                	jne    80173f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801715:	c7 44 24 0c f8 22 80 	movl   $0x8022f8,0xc(%esp)
  80171c:	00 
  80171d:	c7 44 24 08 d9 21 80 	movl   $0x8021d9,0x8(%esp)
  801724:	00 
  801725:	8b 55 0c             	mov    0xc(%ebp),%edx
  801728:	89 54 24 04          	mov    %edx,0x4(%esp)
  80172c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80172f:	89 0c 24             	mov    %ecx,(%esp)
  801732:	e8 90 01 00 00       	call   8018c7 <printfmt>
  801737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80173a:	e9 ac fa ff ff       	jmp    8011eb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80173f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801742:	8b 13                	mov    (%ebx),%edx
  801744:	83 fa 7f             	cmp    $0x7f,%edx
  801747:	7e 29                	jle    801772 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801749:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80174b:	c7 44 24 0c 30 23 80 	movl   $0x802330,0xc(%esp)
  801752:	00 
  801753:	c7 44 24 08 d9 21 80 	movl   $0x8021d9,0x8(%esp)
  80175a:	00 
  80175b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80175f:	8b 45 08             	mov    0x8(%ebp),%eax
  801762:	89 04 24             	mov    %eax,(%esp)
  801765:	e8 5d 01 00 00       	call   8018c7 <printfmt>
  80176a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80176d:	e9 79 fa ff ff       	jmp    8011eb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801772:	88 10                	mov    %dl,(%eax)
  801774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801777:	e9 6f fa ff ff       	jmp    8011eb <vprintfmt+0x2f>
  80177c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80177f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801785:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801789:	89 14 24             	mov    %edx,(%esp)
  80178c:	ff 55 08             	call   *0x8(%ebp)
  80178f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801792:	e9 54 fa ff ff       	jmp    8011eb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80179a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80179e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8017ab:	80 38 25             	cmpb   $0x25,(%eax)
  8017ae:	0f 84 37 fa ff ff    	je     8011eb <vprintfmt+0x2f>
  8017b4:	89 c7                	mov    %eax,%edi
  8017b6:	eb f0                	jmp    8017a8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017c3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8017c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017d1:	00 
  8017d2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8017d5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8017d8:	89 04 24             	mov    %eax,(%esp)
  8017db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017df:	e8 bc 07 00 00       	call   801fa0 <__umoddi3>
  8017e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e8:	0f be 80 bf 21 80 00 	movsbl 0x8021bf(%eax),%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	ff 55 08             	call   *0x8(%ebp)
  8017f5:	e9 d6 fe ff ff       	jmp    8016d0 <vprintfmt+0x514>
  8017fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801801:	8b 74 24 04          	mov    0x4(%esp),%esi
  801805:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80180c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801813:	00 
  801814:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801817:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80181a:	89 04 24             	mov    %eax,(%esp)
  80181d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801821:	e8 7a 07 00 00       	call   801fa0 <__umoddi3>
  801826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182a:	0f be 80 bf 21 80 00 	movsbl 0x8021bf(%eax),%eax
  801831:	89 04 24             	mov    %eax,(%esp)
  801834:	ff 55 08             	call   *0x8(%ebp)
  801837:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80183a:	e9 ac f9 ff ff       	jmp    8011eb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80183f:	83 c4 6c             	add    $0x6c,%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 28             	sub    $0x28,%esp
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801853:	85 c0                	test   %eax,%eax
  801855:	74 04                	je     80185b <vsnprintf+0x14>
  801857:	85 d2                	test   %edx,%edx
  801859:	7f 07                	jg     801862 <vsnprintf+0x1b>
  80185b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801860:	eb 3b                	jmp    80189d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801862:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801865:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801869:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80186c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801873:	8b 45 14             	mov    0x14(%ebp),%eax
  801876:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80187a:	8b 45 10             	mov    0x10(%ebp),%eax
  80187d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801881:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801884:	89 44 24 04          	mov    %eax,0x4(%esp)
  801888:	c7 04 24 9f 11 80 00 	movl   $0x80119f,(%esp)
  80188f:	e8 28 f9 ff ff       	call   8011bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801894:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801897:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80189a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8018a5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8018a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8018af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	e8 82 ff ff ff       	call   801847 <vsnprintf>
	va_end(ap);

	return rc;
}
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    

008018c7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8018cd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8018d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	89 04 24             	mov    %eax,(%esp)
  8018e8:	e8 cf f8 ff ff       	call   8011bc <vprintfmt>
	va_end(ap);
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    
	...

008018f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8018fe:	74 09                	je     801909 <strlen+0x19>
		n++;
  801900:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801903:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801907:	75 f7                	jne    801900 <strlen+0x10>
		n++;
	return n;
}
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801912:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801915:	85 c9                	test   %ecx,%ecx
  801917:	74 19                	je     801932 <strnlen+0x27>
  801919:	80 3b 00             	cmpb   $0x0,(%ebx)
  80191c:	74 14                	je     801932 <strnlen+0x27>
  80191e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801923:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801926:	39 c8                	cmp    %ecx,%eax
  801928:	74 0d                	je     801937 <strnlen+0x2c>
  80192a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80192e:	75 f3                	jne    801923 <strnlen+0x18>
  801930:	eb 05                	jmp    801937 <strnlen+0x2c>
  801932:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801937:	5b                   	pop    %ebx
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	53                   	push   %ebx
  80193e:	8b 45 08             	mov    0x8(%ebp),%eax
  801941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801944:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801949:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80194d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801950:	83 c2 01             	add    $0x1,%edx
  801953:	84 c9                	test   %cl,%cl
  801955:	75 f2                	jne    801949 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801957:	5b                   	pop    %ebx
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	53                   	push   %ebx
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801964:	89 1c 24             	mov    %ebx,(%esp)
  801967:	e8 84 ff ff ff       	call   8018f0 <strlen>
	strcpy(dst + len, src);
  80196c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80196f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801973:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 bc ff ff ff       	call   80193a <strcpy>
	return dst;
}
  80197e:	89 d8                	mov    %ebx,%eax
  801980:	83 c4 08             	add    $0x8,%esp
  801983:	5b                   	pop    %ebx
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    

00801986 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	56                   	push   %esi
  80198a:	53                   	push   %ebx
  80198b:	8b 45 08             	mov    0x8(%ebp),%eax
  80198e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801991:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801994:	85 f6                	test   %esi,%esi
  801996:	74 18                	je     8019b0 <strncpy+0x2a>
  801998:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80199d:	0f b6 1a             	movzbl (%edx),%ebx
  8019a0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8019a3:	80 3a 01             	cmpb   $0x1,(%edx)
  8019a6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019a9:	83 c1 01             	add    $0x1,%ecx
  8019ac:	39 ce                	cmp    %ecx,%esi
  8019ae:	77 ed                	ja     80199d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8019b0:	5b                   	pop    %ebx
  8019b1:	5e                   	pop    %esi
  8019b2:	5d                   	pop    %ebp
  8019b3:	c3                   	ret    

008019b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8019c2:	89 f0                	mov    %esi,%eax
  8019c4:	85 c9                	test   %ecx,%ecx
  8019c6:	74 27                	je     8019ef <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8019c8:	83 e9 01             	sub    $0x1,%ecx
  8019cb:	74 1d                	je     8019ea <strlcpy+0x36>
  8019cd:	0f b6 1a             	movzbl (%edx),%ebx
  8019d0:	84 db                	test   %bl,%bl
  8019d2:	74 16                	je     8019ea <strlcpy+0x36>
			*dst++ = *src++;
  8019d4:	88 18                	mov    %bl,(%eax)
  8019d6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8019d9:	83 e9 01             	sub    $0x1,%ecx
  8019dc:	74 0e                	je     8019ec <strlcpy+0x38>
			*dst++ = *src++;
  8019de:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8019e1:	0f b6 1a             	movzbl (%edx),%ebx
  8019e4:	84 db                	test   %bl,%bl
  8019e6:	75 ec                	jne    8019d4 <strlcpy+0x20>
  8019e8:	eb 02                	jmp    8019ec <strlcpy+0x38>
  8019ea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8019ec:	c6 00 00             	movb   $0x0,(%eax)
  8019ef:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8019fe:	0f b6 01             	movzbl (%ecx),%eax
  801a01:	84 c0                	test   %al,%al
  801a03:	74 15                	je     801a1a <strcmp+0x25>
  801a05:	3a 02                	cmp    (%edx),%al
  801a07:	75 11                	jne    801a1a <strcmp+0x25>
		p++, q++;
  801a09:	83 c1 01             	add    $0x1,%ecx
  801a0c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801a0f:	0f b6 01             	movzbl (%ecx),%eax
  801a12:	84 c0                	test   %al,%al
  801a14:	74 04                	je     801a1a <strcmp+0x25>
  801a16:	3a 02                	cmp    (%edx),%al
  801a18:	74 ef                	je     801a09 <strcmp+0x14>
  801a1a:	0f b6 c0             	movzbl %al,%eax
  801a1d:	0f b6 12             	movzbl (%edx),%edx
  801a20:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	53                   	push   %ebx
  801a28:	8b 55 08             	mov    0x8(%ebp),%edx
  801a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a2e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801a31:	85 c0                	test   %eax,%eax
  801a33:	74 23                	je     801a58 <strncmp+0x34>
  801a35:	0f b6 1a             	movzbl (%edx),%ebx
  801a38:	84 db                	test   %bl,%bl
  801a3a:	74 25                	je     801a61 <strncmp+0x3d>
  801a3c:	3a 19                	cmp    (%ecx),%bl
  801a3e:	75 21                	jne    801a61 <strncmp+0x3d>
  801a40:	83 e8 01             	sub    $0x1,%eax
  801a43:	74 13                	je     801a58 <strncmp+0x34>
		n--, p++, q++;
  801a45:	83 c2 01             	add    $0x1,%edx
  801a48:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801a4b:	0f b6 1a             	movzbl (%edx),%ebx
  801a4e:	84 db                	test   %bl,%bl
  801a50:	74 0f                	je     801a61 <strncmp+0x3d>
  801a52:	3a 19                	cmp    (%ecx),%bl
  801a54:	74 ea                	je     801a40 <strncmp+0x1c>
  801a56:	eb 09                	jmp    801a61 <strncmp+0x3d>
  801a58:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a5d:	5b                   	pop    %ebx
  801a5e:	5d                   	pop    %ebp
  801a5f:	90                   	nop
  801a60:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a61:	0f b6 02             	movzbl (%edx),%eax
  801a64:	0f b6 11             	movzbl (%ecx),%edx
  801a67:	29 d0                	sub    %edx,%eax
  801a69:	eb f2                	jmp    801a5d <strncmp+0x39>

00801a6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801a75:	0f b6 10             	movzbl (%eax),%edx
  801a78:	84 d2                	test   %dl,%dl
  801a7a:	74 18                	je     801a94 <strchr+0x29>
		if (*s == c)
  801a7c:	38 ca                	cmp    %cl,%dl
  801a7e:	75 0a                	jne    801a8a <strchr+0x1f>
  801a80:	eb 17                	jmp    801a99 <strchr+0x2e>
  801a82:	38 ca                	cmp    %cl,%dl
  801a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a88:	74 0f                	je     801a99 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801a8a:	83 c0 01             	add    $0x1,%eax
  801a8d:	0f b6 10             	movzbl (%eax),%edx
  801a90:	84 d2                	test   %dl,%dl
  801a92:	75 ee                	jne    801a82 <strchr+0x17>
  801a94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801aa5:	0f b6 10             	movzbl (%eax),%edx
  801aa8:	84 d2                	test   %dl,%dl
  801aaa:	74 18                	je     801ac4 <strfind+0x29>
		if (*s == c)
  801aac:	38 ca                	cmp    %cl,%dl
  801aae:	75 0a                	jne    801aba <strfind+0x1f>
  801ab0:	eb 12                	jmp    801ac4 <strfind+0x29>
  801ab2:	38 ca                	cmp    %cl,%dl
  801ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ab8:	74 0a                	je     801ac4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801aba:	83 c0 01             	add    $0x1,%eax
  801abd:	0f b6 10             	movzbl (%eax),%edx
  801ac0:	84 d2                	test   %dl,%dl
  801ac2:	75 ee                	jne    801ab2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	89 1c 24             	mov    %ebx,(%esp)
  801acf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ad3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ad7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  801add:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ae0:	85 c9                	test   %ecx,%ecx
  801ae2:	74 30                	je     801b14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ae4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801aea:	75 25                	jne    801b11 <memset+0x4b>
  801aec:	f6 c1 03             	test   $0x3,%cl
  801aef:	75 20                	jne    801b11 <memset+0x4b>
		c &= 0xFF;
  801af1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801af4:	89 d3                	mov    %edx,%ebx
  801af6:	c1 e3 08             	shl    $0x8,%ebx
  801af9:	89 d6                	mov    %edx,%esi
  801afb:	c1 e6 18             	shl    $0x18,%esi
  801afe:	89 d0                	mov    %edx,%eax
  801b00:	c1 e0 10             	shl    $0x10,%eax
  801b03:	09 f0                	or     %esi,%eax
  801b05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801b07:	09 d8                	or     %ebx,%eax
  801b09:	c1 e9 02             	shr    $0x2,%ecx
  801b0c:	fc                   	cld    
  801b0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b0f:	eb 03                	jmp    801b14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b11:	fc                   	cld    
  801b12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b14:	89 f8                	mov    %edi,%eax
  801b16:	8b 1c 24             	mov    (%esp),%ebx
  801b19:	8b 74 24 04          	mov    0x4(%esp),%esi
  801b1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b21:	89 ec                	mov    %ebp,%esp
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 08             	sub    $0x8,%esp
  801b2b:	89 34 24             	mov    %esi,(%esp)
  801b2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b32:	8b 45 08             	mov    0x8(%ebp),%eax
  801b35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801b38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801b3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801b3d:	39 c6                	cmp    %eax,%esi
  801b3f:	73 35                	jae    801b76 <memmove+0x51>
  801b41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b44:	39 d0                	cmp    %edx,%eax
  801b46:	73 2e                	jae    801b76 <memmove+0x51>
		s += n;
		d += n;
  801b48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b4a:	f6 c2 03             	test   $0x3,%dl
  801b4d:	75 1b                	jne    801b6a <memmove+0x45>
  801b4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b55:	75 13                	jne    801b6a <memmove+0x45>
  801b57:	f6 c1 03             	test   $0x3,%cl
  801b5a:	75 0e                	jne    801b6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801b5c:	83 ef 04             	sub    $0x4,%edi
  801b5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801b62:	c1 e9 02             	shr    $0x2,%ecx
  801b65:	fd                   	std    
  801b66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b68:	eb 09                	jmp    801b73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801b6a:	83 ef 01             	sub    $0x1,%edi
  801b6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801b70:	fd                   	std    
  801b71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801b73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b74:	eb 20                	jmp    801b96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801b7c:	75 15                	jne    801b93 <memmove+0x6e>
  801b7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b84:	75 0d                	jne    801b93 <memmove+0x6e>
  801b86:	f6 c1 03             	test   $0x3,%cl
  801b89:	75 08                	jne    801b93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801b8b:	c1 e9 02             	shr    $0x2,%ecx
  801b8e:	fc                   	cld    
  801b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b91:	eb 03                	jmp    801b96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801b93:	fc                   	cld    
  801b94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801b96:	8b 34 24             	mov    (%esp),%esi
  801b99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b9d:	89 ec                	mov    %ebp,%esp
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801ba7:	8b 45 10             	mov    0x10(%ebp),%eax
  801baa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb8:	89 04 24             	mov    %eax,(%esp)
  801bbb:	e8 65 ff ff ff       	call   801b25 <memmove>
}
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    

00801bc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	57                   	push   %edi
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801bd1:	85 c9                	test   %ecx,%ecx
  801bd3:	74 36                	je     801c0b <memcmp+0x49>
		if (*s1 != *s2)
  801bd5:	0f b6 06             	movzbl (%esi),%eax
  801bd8:	0f b6 1f             	movzbl (%edi),%ebx
  801bdb:	38 d8                	cmp    %bl,%al
  801bdd:	74 20                	je     801bff <memcmp+0x3d>
  801bdf:	eb 14                	jmp    801bf5 <memcmp+0x33>
  801be1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801be6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801beb:	83 c2 01             	add    $0x1,%edx
  801bee:	83 e9 01             	sub    $0x1,%ecx
  801bf1:	38 d8                	cmp    %bl,%al
  801bf3:	74 12                	je     801c07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801bf5:	0f b6 c0             	movzbl %al,%eax
  801bf8:	0f b6 db             	movzbl %bl,%ebx
  801bfb:	29 d8                	sub    %ebx,%eax
  801bfd:	eb 11                	jmp    801c10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801bff:	83 e9 01             	sub    $0x1,%ecx
  801c02:	ba 00 00 00 00       	mov    $0x0,%edx
  801c07:	85 c9                	test   %ecx,%ecx
  801c09:	75 d6                	jne    801be1 <memcmp+0x1f>
  801c0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801c10:	5b                   	pop    %ebx
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c1b:	89 c2                	mov    %eax,%edx
  801c1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801c20:	39 d0                	cmp    %edx,%eax
  801c22:	73 15                	jae    801c39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801c28:	38 08                	cmp    %cl,(%eax)
  801c2a:	75 06                	jne    801c32 <memfind+0x1d>
  801c2c:	eb 0b                	jmp    801c39 <memfind+0x24>
  801c2e:	38 08                	cmp    %cl,(%eax)
  801c30:	74 07                	je     801c39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c32:	83 c0 01             	add    $0x1,%eax
  801c35:	39 c2                	cmp    %eax,%edx
  801c37:	77 f5                	ja     801c2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	57                   	push   %edi
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 04             	sub    $0x4,%esp
  801c44:	8b 55 08             	mov    0x8(%ebp),%edx
  801c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c4a:	0f b6 02             	movzbl (%edx),%eax
  801c4d:	3c 20                	cmp    $0x20,%al
  801c4f:	74 04                	je     801c55 <strtol+0x1a>
  801c51:	3c 09                	cmp    $0x9,%al
  801c53:	75 0e                	jne    801c63 <strtol+0x28>
		s++;
  801c55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c58:	0f b6 02             	movzbl (%edx),%eax
  801c5b:	3c 20                	cmp    $0x20,%al
  801c5d:	74 f6                	je     801c55 <strtol+0x1a>
  801c5f:	3c 09                	cmp    $0x9,%al
  801c61:	74 f2                	je     801c55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c63:	3c 2b                	cmp    $0x2b,%al
  801c65:	75 0c                	jne    801c73 <strtol+0x38>
		s++;
  801c67:	83 c2 01             	add    $0x1,%edx
  801c6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801c71:	eb 15                	jmp    801c88 <strtol+0x4d>
	else if (*s == '-')
  801c73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801c7a:	3c 2d                	cmp    $0x2d,%al
  801c7c:	75 0a                	jne    801c88 <strtol+0x4d>
		s++, neg = 1;
  801c7e:	83 c2 01             	add    $0x1,%edx
  801c81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c88:	85 db                	test   %ebx,%ebx
  801c8a:	0f 94 c0             	sete   %al
  801c8d:	74 05                	je     801c94 <strtol+0x59>
  801c8f:	83 fb 10             	cmp    $0x10,%ebx
  801c92:	75 18                	jne    801cac <strtol+0x71>
  801c94:	80 3a 30             	cmpb   $0x30,(%edx)
  801c97:	75 13                	jne    801cac <strtol+0x71>
  801c99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801c9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ca0:	75 0a                	jne    801cac <strtol+0x71>
		s += 2, base = 16;
  801ca2:	83 c2 02             	add    $0x2,%edx
  801ca5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801caa:	eb 15                	jmp    801cc1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cac:	84 c0                	test   %al,%al
  801cae:	66 90                	xchg   %ax,%ax
  801cb0:	74 0f                	je     801cc1 <strtol+0x86>
  801cb2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801cb7:	80 3a 30             	cmpb   $0x30,(%edx)
  801cba:	75 05                	jne    801cc1 <strtol+0x86>
		s++, base = 8;
  801cbc:	83 c2 01             	add    $0x1,%edx
  801cbf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cc8:	0f b6 0a             	movzbl (%edx),%ecx
  801ccb:	89 cf                	mov    %ecx,%edi
  801ccd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801cd0:	80 fb 09             	cmp    $0x9,%bl
  801cd3:	77 08                	ja     801cdd <strtol+0xa2>
			dig = *s - '0';
  801cd5:	0f be c9             	movsbl %cl,%ecx
  801cd8:	83 e9 30             	sub    $0x30,%ecx
  801cdb:	eb 1e                	jmp    801cfb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801cdd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801ce0:	80 fb 19             	cmp    $0x19,%bl
  801ce3:	77 08                	ja     801ced <strtol+0xb2>
			dig = *s - 'a' + 10;
  801ce5:	0f be c9             	movsbl %cl,%ecx
  801ce8:	83 e9 57             	sub    $0x57,%ecx
  801ceb:	eb 0e                	jmp    801cfb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801ced:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801cf0:	80 fb 19             	cmp    $0x19,%bl
  801cf3:	77 15                	ja     801d0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801cf5:	0f be c9             	movsbl %cl,%ecx
  801cf8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801cfb:	39 f1                	cmp    %esi,%ecx
  801cfd:	7d 0b                	jge    801d0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801cff:	83 c2 01             	add    $0x1,%edx
  801d02:	0f af c6             	imul   %esi,%eax
  801d05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801d08:	eb be                	jmp    801cc8 <strtol+0x8d>
  801d0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801d0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d10:	74 05                	je     801d17 <strtol+0xdc>
		*endptr = (char *) s;
  801d12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801d17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801d1b:	74 04                	je     801d21 <strtol+0xe6>
  801d1d:	89 c8                	mov    %ecx,%eax
  801d1f:	f7 d8                	neg    %eax
}
  801d21:	83 c4 04             	add    $0x4,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	00 00                	add    %al,(%eax)
  801d2b:	00 00                	add    %al,(%eax)
  801d2d:	00 00                	add    %al,(%eax)
	...

00801d30 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d36:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d41:	39 ca                	cmp    %ecx,%edx
  801d43:	75 04                	jne    801d49 <ipc_find_env+0x19>
  801d45:	b0 00                	mov    $0x0,%al
  801d47:	eb 12                	jmp    801d5b <ipc_find_env+0x2b>
  801d49:	89 c2                	mov    %eax,%edx
  801d4b:	c1 e2 07             	shl    $0x7,%edx
  801d4e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801d55:	8b 12                	mov    (%edx),%edx
  801d57:	39 ca                	cmp    %ecx,%edx
  801d59:	75 10                	jne    801d6b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d5b:	89 c2                	mov    %eax,%edx
  801d5d:	c1 e2 07             	shl    $0x7,%edx
  801d60:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801d67:	8b 00                	mov    (%eax),%eax
  801d69:	eb 0e                	jmp    801d79 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d6b:	83 c0 01             	add    $0x1,%eax
  801d6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d73:	75 d4                	jne    801d49 <ipc_find_env+0x19>
  801d75:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	57                   	push   %edi
  801d7f:	56                   	push   %esi
  801d80:	53                   	push   %ebx
  801d81:	83 ec 1c             	sub    $0x1c,%esp
  801d84:	8b 75 08             	mov    0x8(%ebp),%esi
  801d87:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801d8d:	85 db                	test   %ebx,%ebx
  801d8f:	74 19                	je     801daa <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801d91:	8b 45 14             	mov    0x14(%ebp),%eax
  801d94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801da0:	89 34 24             	mov    %esi,(%esp)
  801da3:	e8 e4 e4 ff ff       	call   80028c <sys_ipc_try_send>
  801da8:	eb 1b                	jmp    801dc5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801daa:	8b 45 14             	mov    0x14(%ebp),%eax
  801dad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801db8:	ee 
  801db9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dbd:	89 34 24             	mov    %esi,(%esp)
  801dc0:	e8 c7 e4 ff ff       	call   80028c <sys_ipc_try_send>
           if(ret == 0)
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	74 28                	je     801df1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801dc9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dcc:	74 1c                	je     801dea <ipc_send+0x6f>
              panic("ipc send error");
  801dce:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  801dd5:	00 
  801dd6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801ddd:	00 
  801dde:	c7 04 24 4f 25 80 00 	movl   $0x80254f,(%esp)
  801de5:	e8 6a f1 ff ff       	call   800f54 <_panic>
           sys_yield();
  801dea:	e8 69 e7 ff ff       	call   800558 <sys_yield>
        }
  801def:	eb 9c                	jmp    801d8d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801df1:	83 c4 1c             	add    $0x1c,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    

00801df9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	56                   	push   %esi
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 10             	sub    $0x10,%esp
  801e01:	8b 75 08             	mov    0x8(%ebp),%esi
  801e04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	75 0e                	jne    801e1c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e0e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e15:	e8 07 e4 ff ff       	call   800221 <sys_ipc_recv>
  801e1a:	eb 08                	jmp    801e24 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e1c:	89 04 24             	mov    %eax,(%esp)
  801e1f:	e8 fd e3 ff ff       	call   800221 <sys_ipc_recv>
        if(ret == 0){
  801e24:	85 c0                	test   %eax,%eax
  801e26:	75 26                	jne    801e4e <ipc_recv+0x55>
           if(from_env_store)
  801e28:	85 f6                	test   %esi,%esi
  801e2a:	74 0a                	je     801e36 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e2c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e31:	8b 40 78             	mov    0x78(%eax),%eax
  801e34:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801e36:	85 db                	test   %ebx,%ebx
  801e38:	74 0a                	je     801e44 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801e3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e42:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801e44:	a1 04 40 80 00       	mov    0x804004,%eax
  801e49:	8b 40 74             	mov    0x74(%eax),%eax
  801e4c:	eb 14                	jmp    801e62 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801e4e:	85 f6                	test   %esi,%esi
  801e50:	74 06                	je     801e58 <ipc_recv+0x5f>
              *from_env_store = 0;
  801e52:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801e58:	85 db                	test   %ebx,%ebx
  801e5a:	74 06                	je     801e62 <ipc_recv+0x69>
              *perm_store = 0;
  801e5c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801e62:	83 c4 10             	add    $0x10,%esp
  801e65:	5b                   	pop    %ebx
  801e66:	5e                   	pop    %esi
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    
  801e69:	00 00                	add    %al,(%eax)
  801e6b:	00 00                	add    %al,(%eax)
  801e6d:	00 00                	add    %al,(%eax)
	...

00801e70 <__udivdi3>:
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	57                   	push   %edi
  801e74:	56                   	push   %esi
  801e75:	83 ec 10             	sub    $0x10,%esp
  801e78:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  801e7e:	8b 75 10             	mov    0x10(%ebp),%esi
  801e81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e84:	85 c0                	test   %eax,%eax
  801e86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801e89:	75 35                	jne    801ec0 <__udivdi3+0x50>
  801e8b:	39 fe                	cmp    %edi,%esi
  801e8d:	77 61                	ja     801ef0 <__udivdi3+0x80>
  801e8f:	85 f6                	test   %esi,%esi
  801e91:	75 0b                	jne    801e9e <__udivdi3+0x2e>
  801e93:	b8 01 00 00 00       	mov    $0x1,%eax
  801e98:	31 d2                	xor    %edx,%edx
  801e9a:	f7 f6                	div    %esi
  801e9c:	89 c6                	mov    %eax,%esi
  801e9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ea1:	31 d2                	xor    %edx,%edx
  801ea3:	89 f8                	mov    %edi,%eax
  801ea5:	f7 f6                	div    %esi
  801ea7:	89 c7                	mov    %eax,%edi
  801ea9:	89 c8                	mov    %ecx,%eax
  801eab:	f7 f6                	div    %esi
  801ead:	89 c1                	mov    %eax,%ecx
  801eaf:	89 fa                	mov    %edi,%edx
  801eb1:	89 c8                	mov    %ecx,%eax
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	5e                   	pop    %esi
  801eb7:	5f                   	pop    %edi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    
  801eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ec0:	39 f8                	cmp    %edi,%eax
  801ec2:	77 1c                	ja     801ee0 <__udivdi3+0x70>
  801ec4:	0f bd d0             	bsr    %eax,%edx
  801ec7:	83 f2 1f             	xor    $0x1f,%edx
  801eca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801ecd:	75 39                	jne    801f08 <__udivdi3+0x98>
  801ecf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ed2:	0f 86 a0 00 00 00    	jbe    801f78 <__udivdi3+0x108>
  801ed8:	39 f8                	cmp    %edi,%eax
  801eda:	0f 82 98 00 00 00    	jb     801f78 <__udivdi3+0x108>
  801ee0:	31 ff                	xor    %edi,%edi
  801ee2:	31 c9                	xor    %ecx,%ecx
  801ee4:	89 c8                	mov    %ecx,%eax
  801ee6:	89 fa                	mov    %edi,%edx
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	5e                   	pop    %esi
  801eec:	5f                   	pop    %edi
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    
  801eef:	90                   	nop
  801ef0:	89 d1                	mov    %edx,%ecx
  801ef2:	89 fa                	mov    %edi,%edx
  801ef4:	89 c8                	mov    %ecx,%eax
  801ef6:	31 ff                	xor    %edi,%edi
  801ef8:	f7 f6                	div    %esi
  801efa:	89 c1                	mov    %eax,%ecx
  801efc:	89 fa                	mov    %edi,%edx
  801efe:	89 c8                	mov    %ecx,%eax
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	5e                   	pop    %esi
  801f04:	5f                   	pop    %edi
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    
  801f07:	90                   	nop
  801f08:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f0c:	89 f2                	mov    %esi,%edx
  801f0e:	d3 e0                	shl    %cl,%eax
  801f10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f13:	b8 20 00 00 00       	mov    $0x20,%eax
  801f18:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f1b:	89 c1                	mov    %eax,%ecx
  801f1d:	d3 ea                	shr    %cl,%edx
  801f1f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f23:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f26:	d3 e6                	shl    %cl,%esi
  801f28:	89 c1                	mov    %eax,%ecx
  801f2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f2d:	89 fe                	mov    %edi,%esi
  801f2f:	d3 ee                	shr    %cl,%esi
  801f31:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f35:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f3b:	d3 e7                	shl    %cl,%edi
  801f3d:	89 c1                	mov    %eax,%ecx
  801f3f:	d3 ea                	shr    %cl,%edx
  801f41:	09 d7                	or     %edx,%edi
  801f43:	89 f2                	mov    %esi,%edx
  801f45:	89 f8                	mov    %edi,%eax
  801f47:	f7 75 ec             	divl   -0x14(%ebp)
  801f4a:	89 d6                	mov    %edx,%esi
  801f4c:	89 c7                	mov    %eax,%edi
  801f4e:	f7 65 e8             	mull   -0x18(%ebp)
  801f51:	39 d6                	cmp    %edx,%esi
  801f53:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f56:	72 30                	jb     801f88 <__udivdi3+0x118>
  801f58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f5b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f5f:	d3 e2                	shl    %cl,%edx
  801f61:	39 c2                	cmp    %eax,%edx
  801f63:	73 05                	jae    801f6a <__udivdi3+0xfa>
  801f65:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801f68:	74 1e                	je     801f88 <__udivdi3+0x118>
  801f6a:	89 f9                	mov    %edi,%ecx
  801f6c:	31 ff                	xor    %edi,%edi
  801f6e:	e9 71 ff ff ff       	jmp    801ee4 <__udivdi3+0x74>
  801f73:	90                   	nop
  801f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f78:	31 ff                	xor    %edi,%edi
  801f7a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801f7f:	e9 60 ff ff ff       	jmp    801ee4 <__udivdi3+0x74>
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801f8b:	31 ff                	xor    %edi,%edi
  801f8d:	89 c8                	mov    %ecx,%eax
  801f8f:	89 fa                	mov    %edi,%edx
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
	...

00801fa0 <__umoddi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	57                   	push   %edi
  801fa4:	56                   	push   %esi
  801fa5:	83 ec 20             	sub    $0x20,%esp
  801fa8:	8b 55 14             	mov    0x14(%ebp),%edx
  801fab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fae:	8b 7d 10             	mov    0x10(%ebp),%edi
  801fb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb4:	85 d2                	test   %edx,%edx
  801fb6:	89 c8                	mov    %ecx,%eax
  801fb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fbb:	75 13                	jne    801fd0 <__umoddi3+0x30>
  801fbd:	39 f7                	cmp    %esi,%edi
  801fbf:	76 3f                	jbe    802000 <__umoddi3+0x60>
  801fc1:	89 f2                	mov    %esi,%edx
  801fc3:	f7 f7                	div    %edi
  801fc5:	89 d0                	mov    %edx,%eax
  801fc7:	31 d2                	xor    %edx,%edx
  801fc9:	83 c4 20             	add    $0x20,%esp
  801fcc:	5e                   	pop    %esi
  801fcd:	5f                   	pop    %edi
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    
  801fd0:	39 f2                	cmp    %esi,%edx
  801fd2:	77 4c                	ja     802020 <__umoddi3+0x80>
  801fd4:	0f bd ca             	bsr    %edx,%ecx
  801fd7:	83 f1 1f             	xor    $0x1f,%ecx
  801fda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801fdd:	75 51                	jne    802030 <__umoddi3+0x90>
  801fdf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801fe2:	0f 87 e0 00 00 00    	ja     8020c8 <__umoddi3+0x128>
  801fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801feb:	29 f8                	sub    %edi,%eax
  801fed:	19 d6                	sbb    %edx,%esi
  801fef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff5:	89 f2                	mov    %esi,%edx
  801ff7:	83 c4 20             	add    $0x20,%esp
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    
  801ffe:	66 90                	xchg   %ax,%ax
  802000:	85 ff                	test   %edi,%edi
  802002:	75 0b                	jne    80200f <__umoddi3+0x6f>
  802004:	b8 01 00 00 00       	mov    $0x1,%eax
  802009:	31 d2                	xor    %edx,%edx
  80200b:	f7 f7                	div    %edi
  80200d:	89 c7                	mov    %eax,%edi
  80200f:	89 f0                	mov    %esi,%eax
  802011:	31 d2                	xor    %edx,%edx
  802013:	f7 f7                	div    %edi
  802015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802018:	f7 f7                	div    %edi
  80201a:	eb a9                	jmp    801fc5 <__umoddi3+0x25>
  80201c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 c8                	mov    %ecx,%eax
  802022:	89 f2                	mov    %esi,%edx
  802024:	83 c4 20             	add    $0x20,%esp
  802027:	5e                   	pop    %esi
  802028:	5f                   	pop    %edi
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    
  80202b:	90                   	nop
  80202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802030:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802034:	d3 e2                	shl    %cl,%edx
  802036:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802039:	ba 20 00 00 00       	mov    $0x20,%edx
  80203e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802041:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802044:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802048:	89 fa                	mov    %edi,%edx
  80204a:	d3 ea                	shr    %cl,%edx
  80204c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802050:	0b 55 f4             	or     -0xc(%ebp),%edx
  802053:	d3 e7                	shl    %cl,%edi
  802055:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802059:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80205c:	89 f2                	mov    %esi,%edx
  80205e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802061:	89 c7                	mov    %eax,%edi
  802063:	d3 ea                	shr    %cl,%edx
  802065:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802069:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80206c:	89 c2                	mov    %eax,%edx
  80206e:	d3 e6                	shl    %cl,%esi
  802070:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802074:	d3 ea                	shr    %cl,%edx
  802076:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80207a:	09 d6                	or     %edx,%esi
  80207c:	89 f0                	mov    %esi,%eax
  80207e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802081:	d3 e7                	shl    %cl,%edi
  802083:	89 f2                	mov    %esi,%edx
  802085:	f7 75 f4             	divl   -0xc(%ebp)
  802088:	89 d6                	mov    %edx,%esi
  80208a:	f7 65 e8             	mull   -0x18(%ebp)
  80208d:	39 d6                	cmp    %edx,%esi
  80208f:	72 2b                	jb     8020bc <__umoddi3+0x11c>
  802091:	39 c7                	cmp    %eax,%edi
  802093:	72 23                	jb     8020b8 <__umoddi3+0x118>
  802095:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802099:	29 c7                	sub    %eax,%edi
  80209b:	19 d6                	sbb    %edx,%esi
  80209d:	89 f0                	mov    %esi,%eax
  80209f:	89 f2                	mov    %esi,%edx
  8020a1:	d3 ef                	shr    %cl,%edi
  8020a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020a7:	d3 e0                	shl    %cl,%eax
  8020a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020ad:	09 f8                	or     %edi,%eax
  8020af:	d3 ea                	shr    %cl,%edx
  8020b1:	83 c4 20             	add    $0x20,%esp
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	39 d6                	cmp    %edx,%esi
  8020ba:	75 d9                	jne    802095 <__umoddi3+0xf5>
  8020bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8020c2:	eb d1                	jmp    802095 <__umoddi3+0xf5>
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 f2                	cmp    %esi,%edx
  8020ca:	0f 82 18 ff ff ff    	jb     801fe8 <__umoddi3+0x48>
  8020d0:	e9 1d ff ff ff       	jmp    801ff2 <__umoddi3+0x52>
