
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 37 03 00 00       	call   800368 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	envid_t ns_envid = sys_getenvid();
  800048:	e8 8a 17 00 00       	call   8017d7 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80004f:	c7 05 00 40 80 00 80 	movl   $0x802e80,0x804000
  800056:	2e 80 00 

	output_envid = fork();
  800059:	e8 48 18 00 00       	call   8018a6 <fork>
  80005e:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800063:	85 c0                	test   %eax,%eax
  800065:	79 1c                	jns    800083 <umain+0x43>
		panic("error forking");
  800067:	c7 44 24 08 8b 2e 80 	movl   $0x802e8b,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 99 2e 80 00 	movl   $0x802e99,(%esp)
  80007e:	e8 55 03 00 00       	call   8003d8 <_panic>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
  800083:	bb 00 00 00 00       	mov    $0x0,%ebx
	binaryname = "testoutput";

	output_envid = fork();
	if (output_envid < 0)
		panic("error forking");
	else if (output_envid == 0) {
  800088:	85 c0                	test   %eax,%eax
  80008a:	75 0d                	jne    800099 <umain+0x59>
		output(ns_envid);
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 64 02 00 00       	call   8002f8 <output>
		return;
  800094:	e9 c9 00 00 00       	jmp    800162 <umain+0x122>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800099:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8000a0:	00 
  8000a1:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  8000a8:	0f 
  8000a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b0:	e8 33 16 00 00       	call   8016e8 <sys_page_alloc>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 20                	jns    8000d9 <umain+0x99>
			panic("sys_page_alloc: %e", r);
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	c7 44 24 08 aa 2e 80 	movl   $0x802eaa,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 99 2e 80 00 	movl   $0x802e99,(%esp)
  8000d4:	e8 ff 02 00 00       	call   8003d8 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000dd:	c7 44 24 08 bd 2e 80 	movl   $0x802ebd,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 fc 0f 00 	movl   $0xffc,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  8000f4:	e8 26 0c 00 00       	call   800d1f <snprintf>
  8000f9:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800102:	c7 04 24 c9 2e 80 00 	movl   $0x802ec9,(%esp)
  800109:	e8 83 03 00 00       	call   800491 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80010e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  80011d:	0f 
  80011e:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800125:	00 
  800126:	a1 00 50 80 00       	mov    0x805000,%eax
  80012b:	89 04 24             	mov    %eax,(%esp)
  80012e:	e8 48 1b 00 00       	call   801c7b <ipc_send>
		sys_page_unmap(0, pkt);
  800133:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80013a:	0f 
  80013b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800142:	e8 c7 14 00 00       	call   80160e <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  800147:	83 c3 01             	add    $0x1,%ebx
  80014a:	83 fb 0a             	cmp    $0xa,%ebx
  80014d:	0f 85 46 ff ff ff    	jne    800099 <umain+0x59>
  800153:	b3 00                	mov    $0x0,%bl
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  800155:	e8 fb 15 00 00       	call   801755 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80015a:	83 c3 01             	add    $0x1,%ebx
  80015d:	83 fb 14             	cmp    $0x14,%ebx
  800160:	75 f3                	jne    800155 <umain+0x115>
		sys_yield();
}
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
  80016b:	00 00                	add    %al,(%eax)
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 2c             	sub    $0x2c,%esp
  800179:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  80017c:	e8 1c 12 00 00       	call   80139d <sys_time_msec>
  800181:	89 c3                	mov    %eax,%ebx
  800183:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  800186:	c7 05 00 40 80 00 e1 	movl   $0x802ee1,0x804000
  80018d:	2e 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800190:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800193:	eb 05                	jmp    80019a <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800195:	e8 bb 15 00 00       	call   801755 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  80019a:	e8 fe 11 00 00       	call   80139d <sys_time_msec>
  80019f:	39 c3                	cmp    %eax,%ebx
  8001a1:	76 07                	jbe    8001aa <timer+0x3a>
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	79 ee                	jns    800195 <timer+0x25>
  8001a7:	90                   	nop
  8001a8:	eb 08                	jmp    8001b2 <timer+0x42>
			sys_yield();
		}
		if (r < 0)
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8001b0:	79 20                	jns    8001d2 <timer+0x62>
			panic("sys_time_msec: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 ea 2e 80 	movl   $0x802eea,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  8001cd:	e8 06 02 00 00       	call   8003d8 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8001d2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d9:	00 
  8001da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001e1:	00 
  8001e2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8001e9:	00 
  8001ea:	89 34 24             	mov    %esi,(%esp)
  8001ed:	e8 89 1a 00 00       	call   801c7b <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8001f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800201:	00 
  800202:	89 3c 24             	mov    %edi,(%esp)
  800205:	e8 ef 1a 00 00       	call   801cf9 <ipc_recv>
  80020a:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  80020c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020f:	39 c6                	cmp    %eax,%esi
  800211:	74 12                	je     800225 <timer+0xb5>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800213:	89 44 24 04          	mov    %eax,0x4(%esp)
  800217:	c7 04 24 08 2f 80 00 	movl   $0x802f08,(%esp)
  80021e:	e8 6e 02 00 00       	call   800491 <cprintf>
				continue;
			}

			stop = sys_time_msec() + to;
			break;
		}
  800223:	eb cd                	jmp    8001f2 <timer+0x82>
			if (whom != ns_envid) {
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  800225:	e8 73 11 00 00       	call   80139d <sys_time_msec>
  80022a:	01 c3                	add    %eax,%ebx
  80022c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800230:	e9 65 ff ff ff       	jmp    80019a <timer+0x2a>
  800235:	00 00                	add    %al,(%eax)
	...

00800238 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	81 ec 2c 08 00 00    	sub    $0x82c,%esp
  800244:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  800247:	c7 05 00 40 80 00 43 	movl   $0x802f43,0x804000
  80024e:	2f 80 00 
	// another packet in to the same physical page.
        int r;
        int len;
        char buf[MAXBUFLEN];
        while(1){
          while((r = sys_receive_packet((uint32_t)buf,&len))<0)
  800251:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800254:	8d 9d e4 f7 ff ff    	lea    -0x81c(%ebp),%ebx
  80025a:	eb 05                	jmp    800261 <input+0x29>
             sys_yield();
  80025c:	e8 f4 14 00 00       	call   801755 <sys_yield>
	// another packet in to the same physical page.
        int r;
        int len;
        char buf[MAXBUFLEN];
        while(1){
          while((r = sys_receive_packet((uint32_t)buf,&len))<0)
  800261:	89 74 24 04          	mov    %esi,0x4(%esp)
  800265:	89 1c 24             	mov    %ebx,(%esp)
  800268:	e8 ff 0f 00 00       	call   80126c <sys_receive_packet>
  80026d:	85 c0                	test   %eax,%eax
  80026f:	78 eb                	js     80025c <input+0x24>
             sys_yield();
          r = sys_page_alloc(0,&nsipcbuf,PTE_P|PTE_U|PTE_W);
  800271:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800278:	00 
  800279:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800288:	e8 5b 14 00 00       	call   8016e8 <sys_page_alloc>
          if(r < 0)
  80028d:	85 c0                	test   %eax,%eax
  80028f:	79 20                	jns    8002b1 <input+0x79>
             panic("error: %e",r);
  800291:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800295:	c7 44 24 08 4c 2f 80 	movl   $0x802f4c,0x8(%esp)
  80029c:	00 
  80029d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8002a4:	00 
  8002a5:	c7 04 24 56 2f 80 00 	movl   $0x802f56,(%esp)
  8002ac:	e8 27 01 00 00       	call   8003d8 <_panic>
          memmove(nsipcbuf.pkt.jp_data,(void*)buf,len);
  8002b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002bc:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8002c3:	e8 dd 0c 00 00       	call   800fa5 <memmove>
          nsipcbuf.pkt.jp_len = len;
  8002c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cb:	a3 00 70 80 00       	mov    %eax,0x807000

          ipc_send(ns_envid,NSREQ_INPUT,&nsipcbuf,PTE_P|PTE_U|PTE_W);    
  8002d0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8002d7:	00 
  8002d8:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8002df:	00 
  8002e0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8002e7:	00 
  8002e8:	89 3c 24             	mov    %edi,(%esp)
  8002eb:	e8 8b 19 00 00       	call   801c7b <ipc_send>
  8002f0:	e9 6c ff ff ff       	jmp    800261 <input+0x29>
  8002f5:	00 00                	add    %al,(%eax)
	...

008002f8 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 14             	sub    $0x14,%esp
  8002ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	binaryname = "ns_output";
  800302:	c7 05 00 40 80 00 62 	movl   $0x802f62,0x804000
  800309:	2f 80 00 
	// 	- read a packet from the network server
	//	- send the packet to the device driver
        int r = 0;
        struct tx_desc td;
        while(1){            
            r = sys_ipc_recv(&nsipcbuf);
  80030c:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  800313:	e8 06 11 00 00       	call   80141e <sys_ipc_recv>
            if(r != 0 || thisenv->env_ipc_from != ns_envid || thisenv->env_ipc_value != NSREQ_OUTPUT)
  800318:	85 c0                	test   %eax,%eax
  80031a:	75 f0                	jne    80030c <output+0x14>
  80031c:	a1 10 50 80 00       	mov    0x805010,%eax
  800321:	8b 50 78             	mov    0x78(%eax),%edx
  800324:	39 da                	cmp    %ebx,%edx
  800326:	75 e4                	jne    80030c <output+0x14>
  800328:	8b 40 74             	mov    0x74(%eax),%eax
  80032b:	83 f8 0b             	cmp    $0xb,%eax
  80032e:	75 dc                	jne    80030c <output+0x14>
                continue;
          
            uint32_t addr = (uint32_t)nsipcbuf.pkt.jp_data;
            uint32_t length = nsipcbuf.pkt.jp_len;
            r = sys_transmit_packet(addr,length);
  800330:	a1 00 70 80 00       	mov    0x807000,%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  800340:	e8 69 0f 00 00       	call   8012ae <sys_transmit_packet>
            if(r < 0)
  800345:	85 c0                	test   %eax,%eax
  800347:	79 c3                	jns    80030c <output+0x14>
               panic("transmit_packet error\n");
  800349:	c7 44 24 08 6c 2f 80 	movl   $0x802f6c,0x8(%esp)
  800350:	00 
  800351:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800358:	00 
  800359:	c7 04 24 83 2f 80 00 	movl   $0x802f83,(%esp)
  800360:	e8 73 00 00 00       	call   8003d8 <_panic>
  800365:	00 00                	add    %al,(%eax)
	...

00800368 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	83 ec 18             	sub    $0x18,%esp
  80036e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800371:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800374:	8b 75 08             	mov    0x8(%ebp),%esi
  800377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80037a:	e8 58 14 00 00       	call   8017d7 <sys_getenvid>
  80037f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800384:	89 c2                	mov    %eax,%edx
  800386:	c1 e2 07             	shl    $0x7,%edx
  800389:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800390:	a3 10 50 80 00       	mov    %eax,0x805010
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800395:	85 f6                	test   %esi,%esi
  800397:	7e 07                	jle    8003a0 <libmain+0x38>
		binaryname = argv[0];
  800399:	8b 03                	mov    (%ebx),%eax
  80039b:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8003a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a4:	89 34 24             	mov    %esi,(%esp)
  8003a7:	e8 94 fc ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8003ac:	e8 0b 00 00 00       	call   8003bc <exit>
}
  8003b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8003b7:	89 ec                	mov    %ebp,%esp
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    
	...

008003bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8003c2:	e8 84 1e 00 00       	call   80224b <close_all>
	sys_env_destroy(0);
  8003c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003ce:	e8 44 14 00 00       	call   801817 <sys_env_destroy>
}
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    
  8003d5:	00 00                	add    %al,(%eax)
	...

008003d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	56                   	push   %esi
  8003dc:	53                   	push   %ebx
  8003dd:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8003e0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003e3:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8003e9:	e8 e9 13 00 00       	call   8017d7 <sys_getenvid>
  8003ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800400:	89 44 24 04          	mov    %eax,0x4(%esp)
  800404:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  80040b:	e8 81 00 00 00       	call   800491 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800410:	89 74 24 04          	mov    %esi,0x4(%esp)
  800414:	8b 45 10             	mov    0x10(%ebp),%eax
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	e8 11 00 00 00       	call   800430 <vcprintf>
	cprintf("\n");
  80041f:	c7 04 24 df 2e 80 00 	movl   $0x802edf,(%esp)
  800426:	e8 66 00 00 00       	call   800491 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80042b:	cc                   	int3   
  80042c:	eb fd                	jmp    80042b <_panic+0x53>
	...

00800430 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800439:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800440:	00 00 00 
	b.cnt = 0;
  800443:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80044a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800450:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800454:	8b 45 08             	mov    0x8(%ebp),%eax
  800457:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800461:	89 44 24 04          	mov    %eax,0x4(%esp)
  800465:	c7 04 24 ab 04 80 00 	movl   $0x8004ab,(%esp)
  80046c:	e8 cb 01 00 00       	call   80063c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800471:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800481:	89 04 24             	mov    %eax,(%esp)
  800484:	e8 63 0d 00 00       	call   8011ec <sys_cputs>

	return b.cnt;
}
  800489:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800497:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80049a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	89 04 24             	mov    %eax,(%esp)
  8004a4:	e8 87 ff ff ff       	call   800430 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	53                   	push   %ebx
  8004af:	83 ec 14             	sub    $0x14,%esp
  8004b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b5:	8b 03                	mov    (%ebx),%eax
  8004b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ba:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004be:	83 c0 01             	add    $0x1,%eax
  8004c1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c8:	75 19                	jne    8004e3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004ca:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004d1:	00 
  8004d2:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d5:	89 04 24             	mov    %eax,(%esp)
  8004d8:	e8 0f 0d 00 00       	call   8011ec <sys_cputs>
		b->idx = 0;
  8004dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e7:	83 c4 14             	add    $0x14,%esp
  8004ea:	5b                   	pop    %ebx
  8004eb:	5d                   	pop    %ebp
  8004ec:	c3                   	ret    
  8004ed:	00 00                	add    %al,(%eax)
	...

008004f0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	57                   	push   %edi
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 4c             	sub    $0x4c,%esp
  8004f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004fc:	89 d6                	mov    %edx,%esi
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800504:	8b 55 0c             	mov    0xc(%ebp),%edx
  800507:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050a:	8b 45 10             	mov    0x10(%ebp),%eax
  80050d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800510:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800513:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800516:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051b:	39 d1                	cmp    %edx,%ecx
  80051d:	72 07                	jb     800526 <printnum_v2+0x36>
  80051f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800522:	39 d0                	cmp    %edx,%eax
  800524:	77 5f                	ja     800585 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800526:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80052a:	83 eb 01             	sub    $0x1,%ebx
  80052d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800531:	89 44 24 08          	mov    %eax,0x8(%esp)
  800535:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800539:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80053d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800540:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800543:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800546:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80054a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800551:	00 
  800552:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055f:	e8 9c 26 00 00       	call   802c00 <__udivdi3>
  800564:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800567:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80056a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80056e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800572:	89 04 24             	mov    %eax,(%esp)
  800575:	89 54 24 04          	mov    %edx,0x4(%esp)
  800579:	89 f2                	mov    %esi,%edx
  80057b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057e:	e8 6d ff ff ff       	call   8004f0 <printnum_v2>
  800583:	eb 1e                	jmp    8005a3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800585:	83 ff 2d             	cmp    $0x2d,%edi
  800588:	74 19                	je     8005a3 <printnum_v2+0xb3>
		while (--width > 0)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	85 db                	test   %ebx,%ebx
  80058f:	90                   	nop
  800590:	7e 11                	jle    8005a3 <printnum_v2+0xb3>
			putch(padc, putdat);
  800592:	89 74 24 04          	mov    %esi,0x4(%esp)
  800596:	89 3c 24             	mov    %edi,(%esp)
  800599:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80059c:	83 eb 01             	sub    $0x1,%ebx
  80059f:	85 db                	test   %ebx,%ebx
  8005a1:	7f ef                	jg     800592 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8005ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b9:	00 
  8005ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bd:	89 14 24             	mov    %edx,(%esp)
  8005c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c7:	e8 64 27 00 00       	call   802d30 <__umoddi3>
  8005cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d0:	0f be 80 bf 2f 80 00 	movsbl 0x802fbf(%eax),%eax
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005dd:	83 c4 4c             	add    $0x4c,%esp
  8005e0:	5b                   	pop    %ebx
  8005e1:	5e                   	pop    %esi
  8005e2:	5f                   	pop    %edi
  8005e3:	5d                   	pop    %ebp
  8005e4:	c3                   	ret    

008005e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005e5:	55                   	push   %ebp
  8005e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005e8:	83 fa 01             	cmp    $0x1,%edx
  8005eb:	7e 0e                	jle    8005fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005ed:	8b 10                	mov    (%eax),%edx
  8005ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005f2:	89 08                	mov    %ecx,(%eax)
  8005f4:	8b 02                	mov    (%edx),%eax
  8005f6:	8b 52 04             	mov    0x4(%edx),%edx
  8005f9:	eb 22                	jmp    80061d <getuint+0x38>
	else if (lflag)
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	74 10                	je     80060f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	8d 4a 04             	lea    0x4(%edx),%ecx
  800604:	89 08                	mov    %ecx,(%eax)
  800606:	8b 02                	mov    (%edx),%eax
  800608:	ba 00 00 00 00       	mov    $0x0,%edx
  80060d:	eb 0e                	jmp    80061d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	8d 4a 04             	lea    0x4(%edx),%ecx
  800614:	89 08                	mov    %ecx,(%eax)
  800616:	8b 02                	mov    (%edx),%eax
  800618:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80061d:	5d                   	pop    %ebp
  80061e:	c3                   	ret    

0080061f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800625:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800629:	8b 10                	mov    (%eax),%edx
  80062b:	3b 50 04             	cmp    0x4(%eax),%edx
  80062e:	73 0a                	jae    80063a <sprintputch+0x1b>
		*b->buf++ = ch;
  800630:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800633:	88 0a                	mov    %cl,(%edx)
  800635:	83 c2 01             	add    $0x1,%edx
  800638:	89 10                	mov    %edx,(%eax)
}
  80063a:	5d                   	pop    %ebp
  80063b:	c3                   	ret    

0080063c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	57                   	push   %edi
  800640:	56                   	push   %esi
  800641:	53                   	push   %ebx
  800642:	83 ec 6c             	sub    $0x6c,%esp
  800645:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800648:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80064f:	eb 1a                	jmp    80066b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800651:	85 c0                	test   %eax,%eax
  800653:	0f 84 66 06 00 00    	je     800cbf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800659:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	ff 55 08             	call   *0x8(%ebp)
  800666:	eb 03                	jmp    80066b <vprintfmt+0x2f>
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066b:	0f b6 07             	movzbl (%edi),%eax
  80066e:	83 c7 01             	add    $0x1,%edi
  800671:	83 f8 25             	cmp    $0x25,%eax
  800674:	75 db                	jne    800651 <vprintfmt+0x15>
  800676:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80067a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800686:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80068b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800692:	be 00 00 00 00       	mov    $0x0,%esi
  800697:	eb 06                	jmp    80069f <vprintfmt+0x63>
  800699:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80069d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	0f b6 17             	movzbl (%edi),%edx
  8006a2:	0f b6 c2             	movzbl %dl,%eax
  8006a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a8:	8d 47 01             	lea    0x1(%edi),%eax
  8006ab:	83 ea 23             	sub    $0x23,%edx
  8006ae:	80 fa 55             	cmp    $0x55,%dl
  8006b1:	0f 87 60 05 00 00    	ja     800c17 <vprintfmt+0x5db>
  8006b7:	0f b6 d2             	movzbl %dl,%edx
  8006ba:	ff 24 95 a0 31 80 00 	jmp    *0x8031a0(,%edx,4)
  8006c1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8006c6:	eb d5                	jmp    80069d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006cb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8006ce:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8006d1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8006d4:	83 ff 09             	cmp    $0x9,%edi
  8006d7:	76 08                	jbe    8006e1 <vprintfmt+0xa5>
  8006d9:	eb 40                	jmp    80071b <vprintfmt+0xdf>
  8006db:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8006df:	eb bc                	jmp    80069d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006e1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8006e4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8006e7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8006eb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8006ee:	8d 7a d0             	lea    -0x30(%edx),%edi
  8006f1:	83 ff 09             	cmp    $0x9,%edi
  8006f4:	76 eb                	jbe    8006e1 <vprintfmt+0xa5>
  8006f6:	eb 23                	jmp    80071b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8006fb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8006fe:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800701:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800703:	eb 16                	jmp    80071b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800705:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800708:	c1 fa 1f             	sar    $0x1f,%edx
  80070b:	f7 d2                	not    %edx
  80070d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800710:	eb 8b                	jmp    80069d <vprintfmt+0x61>
  800712:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800719:	eb 82                	jmp    80069d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80071b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071f:	0f 89 78 ff ff ff    	jns    80069d <vprintfmt+0x61>
  800725:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800728:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80072b:	e9 6d ff ff ff       	jmp    80069d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800730:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800733:	e9 65 ff ff ff       	jmp    80069d <vprintfmt+0x61>
  800738:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8d 50 04             	lea    0x4(%eax),%edx
  800741:	89 55 14             	mov    %edx,0x14(%ebp)
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
  800747:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074b:	8b 00                	mov    (%eax),%eax
  80074d:	89 04 24             	mov    %eax,(%esp)
  800750:	ff 55 08             	call   *0x8(%ebp)
  800753:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800756:	e9 10 ff ff ff       	jmp    80066b <vprintfmt+0x2f>
  80075b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8d 50 04             	lea    0x4(%eax),%edx
  800764:	89 55 14             	mov    %edx,0x14(%ebp)
  800767:	8b 00                	mov    (%eax),%eax
  800769:	89 c2                	mov    %eax,%edx
  80076b:	c1 fa 1f             	sar    $0x1f,%edx
  80076e:	31 d0                	xor    %edx,%eax
  800770:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800772:	83 f8 0f             	cmp    $0xf,%eax
  800775:	7f 0b                	jg     800782 <vprintfmt+0x146>
  800777:	8b 14 85 00 33 80 00 	mov    0x803300(,%eax,4),%edx
  80077e:	85 d2                	test   %edx,%edx
  800780:	75 26                	jne    8007a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800782:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800786:	c7 44 24 08 d0 2f 80 	movl   $0x802fd0,0x8(%esp)
  80078d:	00 
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800795:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800798:	89 1c 24             	mov    %ebx,(%esp)
  80079b:	e8 a7 05 00 00       	call   800d47 <printfmt>
  8007a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007a3:	e9 c3 fe ff ff       	jmp    80066b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8007a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ac:	c7 44 24 08 e2 34 80 	movl   $0x8034e2,0x8(%esp)
  8007b3:	00 
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8007be:	89 14 24             	mov    %edx,(%esp)
  8007c1:	e8 81 05 00 00       	call   800d47 <printfmt>
  8007c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c9:	e9 9d fe ff ff       	jmp    80066b <vprintfmt+0x2f>
  8007ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d1:	89 c7                	mov    %eax,%edi
  8007d3:	89 d9                	mov    %ebx,%ecx
  8007d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 50 04             	lea    0x4(%eax),%edx
  8007e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e4:	8b 30                	mov    (%eax),%esi
  8007e6:	85 f6                	test   %esi,%esi
  8007e8:	75 05                	jne    8007ef <vprintfmt+0x1b3>
  8007ea:	be d9 2f 80 00       	mov    $0x802fd9,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8007ef:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8007f3:	7e 06                	jle    8007fb <vprintfmt+0x1bf>
  8007f5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8007f9:	75 10                	jne    80080b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fb:	0f be 06             	movsbl (%esi),%eax
  8007fe:	85 c0                	test   %eax,%eax
  800800:	0f 85 a2 00 00 00    	jne    8008a8 <vprintfmt+0x26c>
  800806:	e9 92 00 00 00       	jmp    80089d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80080b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80080f:	89 34 24             	mov    %esi,(%esp)
  800812:	e8 74 05 00 00       	call   800d8b <strnlen>
  800817:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80081a:	29 c2                	sub    %eax,%edx
  80081c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80081f:	85 d2                	test   %edx,%edx
  800821:	7e d8                	jle    8007fb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800823:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800827:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80082a:	89 d3                	mov    %edx,%ebx
  80082c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80082f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800832:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800835:	89 ce                	mov    %ecx,%esi
  800837:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80083b:	89 34 24             	mov    %esi,(%esp)
  80083e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800841:	83 eb 01             	sub    $0x1,%ebx
  800844:	85 db                	test   %ebx,%ebx
  800846:	7f ef                	jg     800837 <vprintfmt+0x1fb>
  800848:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80084b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80084e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800851:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800858:	eb a1                	jmp    8007fb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80085a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80085e:	74 1b                	je     80087b <vprintfmt+0x23f>
  800860:	8d 50 e0             	lea    -0x20(%eax),%edx
  800863:	83 fa 5e             	cmp    $0x5e,%edx
  800866:	76 13                	jbe    80087b <vprintfmt+0x23f>
					putch('?', putdat);
  800868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800876:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800879:	eb 0d                	jmp    800888 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800888:	83 ef 01             	sub    $0x1,%edi
  80088b:	0f be 06             	movsbl (%esi),%eax
  80088e:	85 c0                	test   %eax,%eax
  800890:	74 05                	je     800897 <vprintfmt+0x25b>
  800892:	83 c6 01             	add    $0x1,%esi
  800895:	eb 1a                	jmp    8008b1 <vprintfmt+0x275>
  800897:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80089a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80089d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008a1:	7f 1f                	jg     8008c2 <vprintfmt+0x286>
  8008a3:	e9 c0 fd ff ff       	jmp    800668 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008a8:	83 c6 01             	add    $0x1,%esi
  8008ab:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8008ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008b1:	85 db                	test   %ebx,%ebx
  8008b3:	78 a5                	js     80085a <vprintfmt+0x21e>
  8008b5:	83 eb 01             	sub    $0x1,%ebx
  8008b8:	79 a0                	jns    80085a <vprintfmt+0x21e>
  8008ba:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008bd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008c0:	eb db                	jmp    80089d <vprintfmt+0x261>
  8008c2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8008c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008db:	83 eb 01             	sub    $0x1,%ebx
  8008de:	85 db                	test   %ebx,%ebx
  8008e0:	7f ec                	jg     8008ce <vprintfmt+0x292>
  8008e2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008e5:	e9 81 fd ff ff       	jmp    80066b <vprintfmt+0x2f>
  8008ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ed:	83 fe 01             	cmp    $0x1,%esi
  8008f0:	7e 10                	jle    800902 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 50 08             	lea    0x8(%eax),%edx
  8008f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fb:	8b 18                	mov    (%eax),%ebx
  8008fd:	8b 70 04             	mov    0x4(%eax),%esi
  800900:	eb 26                	jmp    800928 <vprintfmt+0x2ec>
	else if (lflag)
  800902:	85 f6                	test   %esi,%esi
  800904:	74 12                	je     800918 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8d 50 04             	lea    0x4(%eax),%edx
  80090c:	89 55 14             	mov    %edx,0x14(%ebp)
  80090f:	8b 18                	mov    (%eax),%ebx
  800911:	89 de                	mov    %ebx,%esi
  800913:	c1 fe 1f             	sar    $0x1f,%esi
  800916:	eb 10                	jmp    800928 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800918:	8b 45 14             	mov    0x14(%ebp),%eax
  80091b:	8d 50 04             	lea    0x4(%eax),%edx
  80091e:	89 55 14             	mov    %edx,0x14(%ebp)
  800921:	8b 18                	mov    (%eax),%ebx
  800923:	89 de                	mov    %ebx,%esi
  800925:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800928:	83 f9 01             	cmp    $0x1,%ecx
  80092b:	75 1e                	jne    80094b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80092d:	85 f6                	test   %esi,%esi
  80092f:	78 1a                	js     80094b <vprintfmt+0x30f>
  800931:	85 f6                	test   %esi,%esi
  800933:	7f 05                	jg     80093a <vprintfmt+0x2fe>
  800935:	83 fb 00             	cmp    $0x0,%ebx
  800938:	76 11                	jbe    80094b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800941:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800948:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80094b:	85 f6                	test   %esi,%esi
  80094d:	78 13                	js     800962 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80094f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800952:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800955:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800958:	b8 0a 00 00 00       	mov    $0xa,%eax
  80095d:	e9 da 00 00 00       	jmp    800a3c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800970:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800973:	89 da                	mov    %ebx,%edx
  800975:	89 f1                	mov    %esi,%ecx
  800977:	f7 da                	neg    %edx
  800979:	83 d1 00             	adc    $0x0,%ecx
  80097c:	f7 d9                	neg    %ecx
  80097e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800981:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800984:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800987:	b8 0a 00 00 00       	mov    $0xa,%eax
  80098c:	e9 ab 00 00 00       	jmp    800a3c <vprintfmt+0x400>
  800991:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800994:	89 f2                	mov    %esi,%edx
  800996:	8d 45 14             	lea    0x14(%ebp),%eax
  800999:	e8 47 fc ff ff       	call   8005e5 <getuint>
  80099e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8009a1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8009a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8009ac:	e9 8b 00 00 00       	jmp    800a3c <vprintfmt+0x400>
  8009b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8009b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009bb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009c2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8009c5:	89 f2                	mov    %esi,%edx
  8009c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ca:	e8 16 fc ff ff       	call   8005e5 <getuint>
  8009cf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8009d2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8009d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009d8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8009dd:	eb 5d                	jmp    800a3c <vprintfmt+0x400>
  8009df:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009fe:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800a01:	8b 45 14             	mov    0x14(%ebp),%eax
  800a04:	8d 50 04             	lea    0x4(%eax),%edx
  800a07:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0a:	8b 10                	mov    (%eax),%edx
  800a0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a11:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800a14:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800a17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a1a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a1f:	eb 1b                	jmp    800a3c <vprintfmt+0x400>
  800a21:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a24:	89 f2                	mov    %esi,%edx
  800a26:	8d 45 14             	lea    0x14(%ebp),%eax
  800a29:	e8 b7 fb ff ff       	call   8005e5 <getuint>
  800a2e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800a31:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800a34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a37:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a3c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800a40:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a43:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800a46:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800a4a:	77 09                	ja     800a55 <vprintfmt+0x419>
  800a4c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800a4f:	0f 82 ac 00 00 00    	jb     800b01 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800a55:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a58:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800a5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a5f:	83 ea 01             	sub    $0x1,%edx
  800a62:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a66:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6a:	8b 44 24 08          	mov    0x8(%esp),%eax
  800a6e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800a72:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800a75:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800a78:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a7f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a86:	00 
  800a87:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800a8a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800a8d:	89 0c 24             	mov    %ecx,(%esp)
  800a90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a94:	e8 67 21 00 00       	call   802c00 <__udivdi3>
  800a99:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800a9c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800a9f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800aa3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800aa7:	89 04 24             	mov    %eax,(%esp)
  800aaa:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	e8 37 fa ff ff       	call   8004f0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ab9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ac0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ac4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ac7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800acb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ad2:	00 
  800ad3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800ad6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800ad9:	89 14 24             	mov    %edx,(%esp)
  800adc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ae0:	e8 4b 22 00 00       	call   802d30 <__umoddi3>
  800ae5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ae9:	0f be 80 bf 2f 80 00 	movsbl 0x802fbf(%eax),%eax
  800af0:	89 04 24             	mov    %eax,(%esp)
  800af3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800af6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800afa:	74 54                	je     800b50 <vprintfmt+0x514>
  800afc:	e9 67 fb ff ff       	jmp    800668 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800b01:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800b05:	8d 76 00             	lea    0x0(%esi),%esi
  800b08:	0f 84 2a 01 00 00    	je     800c38 <vprintfmt+0x5fc>
		while (--width > 0)
  800b0e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800b11:	83 ef 01             	sub    $0x1,%edi
  800b14:	85 ff                	test   %edi,%edi
  800b16:	0f 8e 5e 01 00 00    	jle    800c7a <vprintfmt+0x63e>
  800b1c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800b1f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800b22:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800b25:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800b28:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b2b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800b2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b32:	89 1c 24             	mov    %ebx,(%esp)
  800b35:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800b38:	83 ef 01             	sub    $0x1,%edi
  800b3b:	85 ff                	test   %edi,%edi
  800b3d:	7f ef                	jg     800b2e <vprintfmt+0x4f2>
  800b3f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b42:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b45:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800b48:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800b4b:	e9 2a 01 00 00       	jmp    800c7a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800b50:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800b53:	83 eb 01             	sub    $0x1,%ebx
  800b56:	85 db                	test   %ebx,%ebx
  800b58:	0f 8e 0a fb ff ff    	jle    800668 <vprintfmt+0x2c>
  800b5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b61:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800b64:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800b67:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b6b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b72:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800b74:	83 eb 01             	sub    $0x1,%ebx
  800b77:	85 db                	test   %ebx,%ebx
  800b79:	7f ec                	jg     800b67 <vprintfmt+0x52b>
  800b7b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800b7e:	e9 e8 fa ff ff       	jmp    80066b <vprintfmt+0x2f>
  800b83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800b86:	8b 45 14             	mov    0x14(%ebp),%eax
  800b89:	8d 50 04             	lea    0x4(%eax),%edx
  800b8c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b8f:	8b 00                	mov    (%eax),%eax
  800b91:	85 c0                	test   %eax,%eax
  800b93:	75 2a                	jne    800bbf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800b95:	c7 44 24 0c f4 30 80 	movl   $0x8030f4,0xc(%esp)
  800b9c:	00 
  800b9d:	c7 44 24 08 e2 34 80 	movl   $0x8034e2,0x8(%esp)
  800ba4:	00 
  800ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800baf:	89 0c 24             	mov    %ecx,(%esp)
  800bb2:	e8 90 01 00 00       	call   800d47 <printfmt>
  800bb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bba:	e9 ac fa ff ff       	jmp    80066b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800bbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc2:	8b 13                	mov    (%ebx),%edx
  800bc4:	83 fa 7f             	cmp    $0x7f,%edx
  800bc7:	7e 29                	jle    800bf2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800bc9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800bcb:	c7 44 24 0c 2c 31 80 	movl   $0x80312c,0xc(%esp)
  800bd2:	00 
  800bd3:	c7 44 24 08 e2 34 80 	movl   $0x8034e2,0x8(%esp)
  800bda:	00 
  800bdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	89 04 24             	mov    %eax,(%esp)
  800be5:	e8 5d 01 00 00       	call   800d47 <printfmt>
  800bea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bed:	e9 79 fa ff ff       	jmp    80066b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800bf2:	88 10                	mov    %dl,(%eax)
  800bf4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bf7:	e9 6f fa ff ff       	jmp    80066b <vprintfmt+0x2f>
  800bfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c09:	89 14 24             	mov    %edx,(%esp)
  800c0c:	ff 55 08             	call   *0x8(%ebp)
  800c0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800c12:	e9 54 fa ff ff       	jmp    80066b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c1e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c25:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c28:	8d 47 ff             	lea    -0x1(%edi),%eax
  800c2b:	80 38 25             	cmpb   $0x25,(%eax)
  800c2e:	0f 84 37 fa ff ff    	je     80066b <vprintfmt+0x2f>
  800c34:	89 c7                	mov    %eax,%edi
  800c36:	eb f0                	jmp    800c28 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800c38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c43:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800c46:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c4a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800c51:	00 
  800c52:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800c55:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800c58:	89 04 24             	mov    %eax,(%esp)
  800c5b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c5f:	e8 cc 20 00 00       	call   802d30 <__umoddi3>
  800c64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c68:	0f be 80 bf 2f 80 00 	movsbl 0x802fbf(%eax),%eax
  800c6f:	89 04 24             	mov    %eax,(%esp)
  800c72:	ff 55 08             	call   *0x8(%ebp)
  800c75:	e9 d6 fe ff ff       	jmp    800b50 <vprintfmt+0x514>
  800c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c81:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c85:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800c93:	00 
  800c94:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800c97:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800c9a:	89 04 24             	mov    %eax,(%esp)
  800c9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ca1:	e8 8a 20 00 00       	call   802d30 <__umoddi3>
  800ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800caa:	0f be 80 bf 2f 80 00 	movsbl 0x802fbf(%eax),%eax
  800cb1:	89 04 24             	mov    %eax,(%esp)
  800cb4:	ff 55 08             	call   *0x8(%ebp)
  800cb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cba:	e9 ac f9 ff ff       	jmp    80066b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800cbf:	83 c4 6c             	add    $0x6c,%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 28             	sub    $0x28,%esp
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	74 04                	je     800cdb <vsnprintf+0x14>
  800cd7:	85 d2                	test   %edx,%edx
  800cd9:	7f 07                	jg     800ce2 <vsnprintf+0x1b>
  800cdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ce0:	eb 3b                	jmp    800d1d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ce5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ce9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cf3:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d01:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d08:	c7 04 24 1f 06 80 00 	movl   $0x80061f,(%esp)
  800d0f:	e8 28 f9 ff ff       	call   80063c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    

00800d1f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800d25:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800d28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	89 04 24             	mov    %eax,(%esp)
  800d40:	e8 82 ff ff ff       	call   800cc7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d45:	c9                   	leave  
  800d46:	c3                   	ret    

00800d47 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800d4d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800d50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d54:	8b 45 10             	mov    0x10(%ebp),%eax
  800d57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	89 04 24             	mov    %eax,(%esp)
  800d68:	e8 cf f8 ff ff       	call   80063c <vprintfmt>
	va_end(ap);
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    
	...

00800d70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800d7e:	74 09                	je     800d89 <strlen+0x19>
		n++;
  800d80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d87:	75 f7                	jne    800d80 <strlen+0x10>
		n++;
	return n;
}
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	53                   	push   %ebx
  800d8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d95:	85 c9                	test   %ecx,%ecx
  800d97:	74 19                	je     800db2 <strnlen+0x27>
  800d99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d9c:	74 14                	je     800db2 <strnlen+0x27>
  800d9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800da3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800da6:	39 c8                	cmp    %ecx,%eax
  800da8:	74 0d                	je     800db7 <strnlen+0x2c>
  800daa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800dae:	75 f3                	jne    800da3 <strnlen+0x18>
  800db0:	eb 05                	jmp    800db7 <strnlen+0x2c>
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800db7:	5b                   	pop    %ebx
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	53                   	push   %ebx
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800dc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800dcd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800dd0:	83 c2 01             	add    $0x1,%edx
  800dd3:	84 c9                	test   %cl,%cl
  800dd5:	75 f2                	jne    800dc9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strcat>:

char *
strcat(char *dst, const char *src)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 08             	sub    $0x8,%esp
  800de1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800de4:	89 1c 24             	mov    %ebx,(%esp)
  800de7:	e8 84 ff ff ff       	call   800d70 <strlen>
	strcpy(dst + len, src);
  800dec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800def:	89 54 24 04          	mov    %edx,0x4(%esp)
  800df3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800df6:	89 04 24             	mov    %eax,(%esp)
  800df9:	e8 bc ff ff ff       	call   800dba <strcpy>
	return dst;
}
  800dfe:	89 d8                	mov    %ebx,%eax
  800e00:	83 c4 08             	add    $0x8,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e14:	85 f6                	test   %esi,%esi
  800e16:	74 18                	je     800e30 <strncpy+0x2a>
  800e18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800e1d:	0f b6 1a             	movzbl (%edx),%ebx
  800e20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e23:	80 3a 01             	cmpb   $0x1,(%edx)
  800e26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e29:	83 c1 01             	add    $0x1,%ecx
  800e2c:	39 ce                	cmp    %ecx,%esi
  800e2e:	77 ed                	ja     800e1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e42:	89 f0                	mov    %esi,%eax
  800e44:	85 c9                	test   %ecx,%ecx
  800e46:	74 27                	je     800e6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800e48:	83 e9 01             	sub    $0x1,%ecx
  800e4b:	74 1d                	je     800e6a <strlcpy+0x36>
  800e4d:	0f b6 1a             	movzbl (%edx),%ebx
  800e50:	84 db                	test   %bl,%bl
  800e52:	74 16                	je     800e6a <strlcpy+0x36>
			*dst++ = *src++;
  800e54:	88 18                	mov    %bl,(%eax)
  800e56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e59:	83 e9 01             	sub    $0x1,%ecx
  800e5c:	74 0e                	je     800e6c <strlcpy+0x38>
			*dst++ = *src++;
  800e5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e61:	0f b6 1a             	movzbl (%edx),%ebx
  800e64:	84 db                	test   %bl,%bl
  800e66:	75 ec                	jne    800e54 <strlcpy+0x20>
  800e68:	eb 02                	jmp    800e6c <strlcpy+0x38>
  800e6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e6c:	c6 00 00             	movb   $0x0,(%eax)
  800e6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e7e:	0f b6 01             	movzbl (%ecx),%eax
  800e81:	84 c0                	test   %al,%al
  800e83:	74 15                	je     800e9a <strcmp+0x25>
  800e85:	3a 02                	cmp    (%edx),%al
  800e87:	75 11                	jne    800e9a <strcmp+0x25>
		p++, q++;
  800e89:	83 c1 01             	add    $0x1,%ecx
  800e8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e8f:	0f b6 01             	movzbl (%ecx),%eax
  800e92:	84 c0                	test   %al,%al
  800e94:	74 04                	je     800e9a <strcmp+0x25>
  800e96:	3a 02                	cmp    (%edx),%al
  800e98:	74 ef                	je     800e89 <strcmp+0x14>
  800e9a:	0f b6 c0             	movzbl %al,%eax
  800e9d:	0f b6 12             	movzbl (%edx),%edx
  800ea0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	53                   	push   %ebx
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	74 23                	je     800ed8 <strncmp+0x34>
  800eb5:	0f b6 1a             	movzbl (%edx),%ebx
  800eb8:	84 db                	test   %bl,%bl
  800eba:	74 25                	je     800ee1 <strncmp+0x3d>
  800ebc:	3a 19                	cmp    (%ecx),%bl
  800ebe:	75 21                	jne    800ee1 <strncmp+0x3d>
  800ec0:	83 e8 01             	sub    $0x1,%eax
  800ec3:	74 13                	je     800ed8 <strncmp+0x34>
		n--, p++, q++;
  800ec5:	83 c2 01             	add    $0x1,%edx
  800ec8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ecb:	0f b6 1a             	movzbl (%edx),%ebx
  800ece:	84 db                	test   %bl,%bl
  800ed0:	74 0f                	je     800ee1 <strncmp+0x3d>
  800ed2:	3a 19                	cmp    (%ecx),%bl
  800ed4:	74 ea                	je     800ec0 <strncmp+0x1c>
  800ed6:	eb 09                	jmp    800ee1 <strncmp+0x3d>
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800edd:	5b                   	pop    %ebx
  800ede:	5d                   	pop    %ebp
  800edf:	90                   	nop
  800ee0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ee1:	0f b6 02             	movzbl (%edx),%eax
  800ee4:	0f b6 11             	movzbl (%ecx),%edx
  800ee7:	29 d0                	sub    %edx,%eax
  800ee9:	eb f2                	jmp    800edd <strncmp+0x39>

00800eeb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ef5:	0f b6 10             	movzbl (%eax),%edx
  800ef8:	84 d2                	test   %dl,%dl
  800efa:	74 18                	je     800f14 <strchr+0x29>
		if (*s == c)
  800efc:	38 ca                	cmp    %cl,%dl
  800efe:	75 0a                	jne    800f0a <strchr+0x1f>
  800f00:	eb 17                	jmp    800f19 <strchr+0x2e>
  800f02:	38 ca                	cmp    %cl,%dl
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	74 0f                	je     800f19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f0a:	83 c0 01             	add    $0x1,%eax
  800f0d:	0f b6 10             	movzbl (%eax),%edx
  800f10:	84 d2                	test   %dl,%dl
  800f12:	75 ee                	jne    800f02 <strchr+0x17>
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f25:	0f b6 10             	movzbl (%eax),%edx
  800f28:	84 d2                	test   %dl,%dl
  800f2a:	74 18                	je     800f44 <strfind+0x29>
		if (*s == c)
  800f2c:	38 ca                	cmp    %cl,%dl
  800f2e:	75 0a                	jne    800f3a <strfind+0x1f>
  800f30:	eb 12                	jmp    800f44 <strfind+0x29>
  800f32:	38 ca                	cmp    %cl,%dl
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	74 0a                	je     800f44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f3a:	83 c0 01             	add    $0x1,%eax
  800f3d:	0f b6 10             	movzbl (%eax),%edx
  800f40:	84 d2                	test   %dl,%dl
  800f42:	75 ee                	jne    800f32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	89 1c 24             	mov    %ebx,(%esp)
  800f4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f60:	85 c9                	test   %ecx,%ecx
  800f62:	74 30                	je     800f94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f6a:	75 25                	jne    800f91 <memset+0x4b>
  800f6c:	f6 c1 03             	test   $0x3,%cl
  800f6f:	75 20                	jne    800f91 <memset+0x4b>
		c &= 0xFF;
  800f71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f74:	89 d3                	mov    %edx,%ebx
  800f76:	c1 e3 08             	shl    $0x8,%ebx
  800f79:	89 d6                	mov    %edx,%esi
  800f7b:	c1 e6 18             	shl    $0x18,%esi
  800f7e:	89 d0                	mov    %edx,%eax
  800f80:	c1 e0 10             	shl    $0x10,%eax
  800f83:	09 f0                	or     %esi,%eax
  800f85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800f87:	09 d8                	or     %ebx,%eax
  800f89:	c1 e9 02             	shr    $0x2,%ecx
  800f8c:	fc                   	cld    
  800f8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f8f:	eb 03                	jmp    800f94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f91:	fc                   	cld    
  800f92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f94:	89 f8                	mov    %edi,%eax
  800f96:	8b 1c 24             	mov    (%esp),%ebx
  800f99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fa1:	89 ec                	mov    %ebp,%esp
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	89 34 24             	mov    %esi,(%esp)
  800fae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800fb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800fbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800fbd:	39 c6                	cmp    %eax,%esi
  800fbf:	73 35                	jae    800ff6 <memmove+0x51>
  800fc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fc4:	39 d0                	cmp    %edx,%eax
  800fc6:	73 2e                	jae    800ff6 <memmove+0x51>
		s += n;
		d += n;
  800fc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fca:	f6 c2 03             	test   $0x3,%dl
  800fcd:	75 1b                	jne    800fea <memmove+0x45>
  800fcf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fd5:	75 13                	jne    800fea <memmove+0x45>
  800fd7:	f6 c1 03             	test   $0x3,%cl
  800fda:	75 0e                	jne    800fea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800fdc:	83 ef 04             	sub    $0x4,%edi
  800fdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fe2:	c1 e9 02             	shr    $0x2,%ecx
  800fe5:	fd                   	std    
  800fe6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fe8:	eb 09                	jmp    800ff3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fea:	83 ef 01             	sub    $0x1,%edi
  800fed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ff0:	fd                   	std    
  800ff1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ff3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ff4:	eb 20                	jmp    801016 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ff6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ffc:	75 15                	jne    801013 <memmove+0x6e>
  800ffe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801004:	75 0d                	jne    801013 <memmove+0x6e>
  801006:	f6 c1 03             	test   $0x3,%cl
  801009:	75 08                	jne    801013 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80100b:	c1 e9 02             	shr    $0x2,%ecx
  80100e:	fc                   	cld    
  80100f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801011:	eb 03                	jmp    801016 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801013:	fc                   	cld    
  801014:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801016:	8b 34 24             	mov    (%esp),%esi
  801019:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80101d:	89 ec                	mov    %ebp,%esp
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801027:	8b 45 10             	mov    0x10(%ebp),%eax
  80102a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801031:	89 44 24 04          	mov    %eax,0x4(%esp)
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
  801038:	89 04 24             	mov    %eax,(%esp)
  80103b:	e8 65 ff ff ff       	call   800fa5 <memmove>
}
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	8b 75 08             	mov    0x8(%ebp),%esi
  80104b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80104e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801051:	85 c9                	test   %ecx,%ecx
  801053:	74 36                	je     80108b <memcmp+0x49>
		if (*s1 != *s2)
  801055:	0f b6 06             	movzbl (%esi),%eax
  801058:	0f b6 1f             	movzbl (%edi),%ebx
  80105b:	38 d8                	cmp    %bl,%al
  80105d:	74 20                	je     80107f <memcmp+0x3d>
  80105f:	eb 14                	jmp    801075 <memcmp+0x33>
  801061:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801066:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80106b:	83 c2 01             	add    $0x1,%edx
  80106e:	83 e9 01             	sub    $0x1,%ecx
  801071:	38 d8                	cmp    %bl,%al
  801073:	74 12                	je     801087 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801075:	0f b6 c0             	movzbl %al,%eax
  801078:	0f b6 db             	movzbl %bl,%ebx
  80107b:	29 d8                	sub    %ebx,%eax
  80107d:	eb 11                	jmp    801090 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80107f:	83 e9 01             	sub    $0x1,%ecx
  801082:	ba 00 00 00 00       	mov    $0x0,%edx
  801087:	85 c9                	test   %ecx,%ecx
  801089:	75 d6                	jne    801061 <memcmp+0x1f>
  80108b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010a0:	39 d0                	cmp    %edx,%eax
  8010a2:	73 15                	jae    8010b9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8010a8:	38 08                	cmp    %cl,(%eax)
  8010aa:	75 06                	jne    8010b2 <memfind+0x1d>
  8010ac:	eb 0b                	jmp    8010b9 <memfind+0x24>
  8010ae:	38 08                	cmp    %cl,(%eax)
  8010b0:	74 07                	je     8010b9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010b2:	83 c0 01             	add    $0x1,%eax
  8010b5:	39 c2                	cmp    %eax,%edx
  8010b7:	77 f5                	ja     8010ae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ca:	0f b6 02             	movzbl (%edx),%eax
  8010cd:	3c 20                	cmp    $0x20,%al
  8010cf:	74 04                	je     8010d5 <strtol+0x1a>
  8010d1:	3c 09                	cmp    $0x9,%al
  8010d3:	75 0e                	jne    8010e3 <strtol+0x28>
		s++;
  8010d5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010d8:	0f b6 02             	movzbl (%edx),%eax
  8010db:	3c 20                	cmp    $0x20,%al
  8010dd:	74 f6                	je     8010d5 <strtol+0x1a>
  8010df:	3c 09                	cmp    $0x9,%al
  8010e1:	74 f2                	je     8010d5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010e3:	3c 2b                	cmp    $0x2b,%al
  8010e5:	75 0c                	jne    8010f3 <strtol+0x38>
		s++;
  8010e7:	83 c2 01             	add    $0x1,%edx
  8010ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010f1:	eb 15                	jmp    801108 <strtol+0x4d>
	else if (*s == '-')
  8010f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010fa:	3c 2d                	cmp    $0x2d,%al
  8010fc:	75 0a                	jne    801108 <strtol+0x4d>
		s++, neg = 1;
  8010fe:	83 c2 01             	add    $0x1,%edx
  801101:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801108:	85 db                	test   %ebx,%ebx
  80110a:	0f 94 c0             	sete   %al
  80110d:	74 05                	je     801114 <strtol+0x59>
  80110f:	83 fb 10             	cmp    $0x10,%ebx
  801112:	75 18                	jne    80112c <strtol+0x71>
  801114:	80 3a 30             	cmpb   $0x30,(%edx)
  801117:	75 13                	jne    80112c <strtol+0x71>
  801119:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80111d:	8d 76 00             	lea    0x0(%esi),%esi
  801120:	75 0a                	jne    80112c <strtol+0x71>
		s += 2, base = 16;
  801122:	83 c2 02             	add    $0x2,%edx
  801125:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80112a:	eb 15                	jmp    801141 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80112c:	84 c0                	test   %al,%al
  80112e:	66 90                	xchg   %ax,%ax
  801130:	74 0f                	je     801141 <strtol+0x86>
  801132:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801137:	80 3a 30             	cmpb   $0x30,(%edx)
  80113a:	75 05                	jne    801141 <strtol+0x86>
		s++, base = 8;
  80113c:	83 c2 01             	add    $0x1,%edx
  80113f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801148:	0f b6 0a             	movzbl (%edx),%ecx
  80114b:	89 cf                	mov    %ecx,%edi
  80114d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801150:	80 fb 09             	cmp    $0x9,%bl
  801153:	77 08                	ja     80115d <strtol+0xa2>
			dig = *s - '0';
  801155:	0f be c9             	movsbl %cl,%ecx
  801158:	83 e9 30             	sub    $0x30,%ecx
  80115b:	eb 1e                	jmp    80117b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80115d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801160:	80 fb 19             	cmp    $0x19,%bl
  801163:	77 08                	ja     80116d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801165:	0f be c9             	movsbl %cl,%ecx
  801168:	83 e9 57             	sub    $0x57,%ecx
  80116b:	eb 0e                	jmp    80117b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80116d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801170:	80 fb 19             	cmp    $0x19,%bl
  801173:	77 15                	ja     80118a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801175:	0f be c9             	movsbl %cl,%ecx
  801178:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80117b:	39 f1                	cmp    %esi,%ecx
  80117d:	7d 0b                	jge    80118a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80117f:	83 c2 01             	add    $0x1,%edx
  801182:	0f af c6             	imul   %esi,%eax
  801185:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801188:	eb be                	jmp    801148 <strtol+0x8d>
  80118a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80118c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801190:	74 05                	je     801197 <strtol+0xdc>
		*endptr = (char *) s;
  801192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801195:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801197:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80119b:	74 04                	je     8011a1 <strtol+0xe6>
  80119d:	89 c8                	mov    %ecx,%eax
  80119f:	f7 d8                	neg    %eax
}
  8011a1:	83 c4 04             	add    $0x4,%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    
  8011a9:	00 00                	add    %al,(%eax)
	...

008011ac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	89 1c 24             	mov    %ebx,(%esp)
  8011b5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011be:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c3:	89 d1                	mov    %edx,%ecx
  8011c5:	89 d3                	mov    %edx,%ebx
  8011c7:	89 d7                	mov    %edx,%edi
  8011c9:	51                   	push   %ecx
  8011ca:	52                   	push   %edx
  8011cb:	53                   	push   %ebx
  8011cc:	54                   	push   %esp
  8011cd:	55                   	push   %ebp
  8011ce:	56                   	push   %esi
  8011cf:	57                   	push   %edi
  8011d0:	54                   	push   %esp
  8011d1:	5d                   	pop    %ebp
  8011d2:	8d 35 da 11 80 00    	lea    0x8011da,%esi
  8011d8:	0f 34                	sysenter 
  8011da:	5f                   	pop    %edi
  8011db:	5e                   	pop    %esi
  8011dc:	5d                   	pop    %ebp
  8011dd:	5c                   	pop    %esp
  8011de:	5b                   	pop    %ebx
  8011df:	5a                   	pop    %edx
  8011e0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011e1:	8b 1c 24             	mov    (%esp),%ebx
  8011e4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011e8:	89 ec                	mov    %ebp,%esp
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 08             	sub    $0x8,%esp
  8011f2:	89 1c 24             	mov    %ebx,(%esp)
  8011f5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801201:	8b 55 08             	mov    0x8(%ebp),%edx
  801204:	89 c3                	mov    %eax,%ebx
  801206:	89 c7                	mov    %eax,%edi
  801208:	51                   	push   %ecx
  801209:	52                   	push   %edx
  80120a:	53                   	push   %ebx
  80120b:	54                   	push   %esp
  80120c:	55                   	push   %ebp
  80120d:	56                   	push   %esi
  80120e:	57                   	push   %edi
  80120f:	54                   	push   %esp
  801210:	5d                   	pop    %ebp
  801211:	8d 35 19 12 80 00    	lea    0x801219,%esi
  801217:	0f 34                	sysenter 
  801219:	5f                   	pop    %edi
  80121a:	5e                   	pop    %esi
  80121b:	5d                   	pop    %ebp
  80121c:	5c                   	pop    %esp
  80121d:	5b                   	pop    %ebx
  80121e:	5a                   	pop    %edx
  80121f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801220:	8b 1c 24             	mov    (%esp),%ebx
  801223:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801227:	89 ec                	mov    %ebp,%esp
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	89 1c 24             	mov    %ebx,(%esp)
  801234:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801238:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123d:	b8 13 00 00 00       	mov    $0x13,%eax
  801242:	8b 55 08             	mov    0x8(%ebp),%edx
  801245:	89 cb                	mov    %ecx,%ebx
  801247:	89 cf                	mov    %ecx,%edi
  801249:	51                   	push   %ecx
  80124a:	52                   	push   %edx
  80124b:	53                   	push   %ebx
  80124c:	54                   	push   %esp
  80124d:	55                   	push   %ebp
  80124e:	56                   	push   %esi
  80124f:	57                   	push   %edi
  801250:	54                   	push   %esp
  801251:	5d                   	pop    %ebp
  801252:	8d 35 5a 12 80 00    	lea    0x80125a,%esi
  801258:	0f 34                	sysenter 
  80125a:	5f                   	pop    %edi
  80125b:	5e                   	pop    %esi
  80125c:	5d                   	pop    %ebp
  80125d:	5c                   	pop    %esp
  80125e:	5b                   	pop    %ebx
  80125f:	5a                   	pop    %edx
  801260:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801261:	8b 1c 24             	mov    (%esp),%ebx
  801264:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801268:	89 ec                	mov    %ebp,%esp
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 08             	sub    $0x8,%esp
  801272:	89 1c 24             	mov    %ebx,(%esp)
  801275:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801279:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127e:	b8 12 00 00 00       	mov    $0x12,%eax
  801283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801286:	8b 55 08             	mov    0x8(%ebp),%edx
  801289:	89 df                	mov    %ebx,%edi
  80128b:	51                   	push   %ecx
  80128c:	52                   	push   %edx
  80128d:	53                   	push   %ebx
  80128e:	54                   	push   %esp
  80128f:	55                   	push   %ebp
  801290:	56                   	push   %esi
  801291:	57                   	push   %edi
  801292:	54                   	push   %esp
  801293:	5d                   	pop    %ebp
  801294:	8d 35 9c 12 80 00    	lea    0x80129c,%esi
  80129a:	0f 34                	sysenter 
  80129c:	5f                   	pop    %edi
  80129d:	5e                   	pop    %esi
  80129e:	5d                   	pop    %ebp
  80129f:	5c                   	pop    %esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5a                   	pop    %edx
  8012a2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8012a3:	8b 1c 24             	mov    (%esp),%ebx
  8012a6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012aa:	89 ec                	mov    %ebp,%esp
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    

008012ae <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	89 1c 24             	mov    %ebx,(%esp)
  8012b7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c0:	b8 11 00 00 00       	mov    $0x11,%eax
  8012c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cb:	89 df                	mov    %ebx,%edi
  8012cd:	51                   	push   %ecx
  8012ce:	52                   	push   %edx
  8012cf:	53                   	push   %ebx
  8012d0:	54                   	push   %esp
  8012d1:	55                   	push   %ebp
  8012d2:	56                   	push   %esi
  8012d3:	57                   	push   %edi
  8012d4:	54                   	push   %esp
  8012d5:	5d                   	pop    %ebp
  8012d6:	8d 35 de 12 80 00    	lea    0x8012de,%esi
  8012dc:	0f 34                	sysenter 
  8012de:	5f                   	pop    %edi
  8012df:	5e                   	pop    %esi
  8012e0:	5d                   	pop    %ebp
  8012e1:	5c                   	pop    %esp
  8012e2:	5b                   	pop    %ebx
  8012e3:	5a                   	pop    %edx
  8012e4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8012e5:	8b 1c 24             	mov    (%esp),%ebx
  8012e8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012ec:	89 ec                	mov    %ebp,%esp
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	89 1c 24             	mov    %ebx,(%esp)
  8012f9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012fd:	b8 10 00 00 00       	mov    $0x10,%eax
  801302:	8b 7d 14             	mov    0x14(%ebp),%edi
  801305:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130b:	8b 55 08             	mov    0x8(%ebp),%edx
  80130e:	51                   	push   %ecx
  80130f:	52                   	push   %edx
  801310:	53                   	push   %ebx
  801311:	54                   	push   %esp
  801312:	55                   	push   %ebp
  801313:	56                   	push   %esi
  801314:	57                   	push   %edi
  801315:	54                   	push   %esp
  801316:	5d                   	pop    %ebp
  801317:	8d 35 1f 13 80 00    	lea    0x80131f,%esi
  80131d:	0f 34                	sysenter 
  80131f:	5f                   	pop    %edi
  801320:	5e                   	pop    %esi
  801321:	5d                   	pop    %ebp
  801322:	5c                   	pop    %esp
  801323:	5b                   	pop    %ebx
  801324:	5a                   	pop    %edx
  801325:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801326:	8b 1c 24             	mov    (%esp),%ebx
  801329:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80132d:	89 ec                	mov    %ebp,%esp
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 28             	sub    $0x28,%esp
  801337:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80133a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80133d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801342:	b8 0f 00 00 00       	mov    $0xf,%eax
  801347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134a:	8b 55 08             	mov    0x8(%ebp),%edx
  80134d:	89 df                	mov    %ebx,%edi
  80134f:	51                   	push   %ecx
  801350:	52                   	push   %edx
  801351:	53                   	push   %ebx
  801352:	54                   	push   %esp
  801353:	55                   	push   %ebp
  801354:	56                   	push   %esi
  801355:	57                   	push   %edi
  801356:	54                   	push   %esp
  801357:	5d                   	pop    %ebp
  801358:	8d 35 60 13 80 00    	lea    0x801360,%esi
  80135e:	0f 34                	sysenter 
  801360:	5f                   	pop    %edi
  801361:	5e                   	pop    %esi
  801362:	5d                   	pop    %ebp
  801363:	5c                   	pop    %esp
  801364:	5b                   	pop    %ebx
  801365:	5a                   	pop    %edx
  801366:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801367:	85 c0                	test   %eax,%eax
  801369:	7e 28                	jle    801393 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801376:	00 
  801377:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  80137e:	00 
  80137f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801386:	00 
  801387:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  80138e:	e8 45 f0 ff ff       	call   8003d8 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801393:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801396:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801399:	89 ec                	mov    %ebp,%esp
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	89 1c 24             	mov    %ebx,(%esp)
  8013a6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8013af:	b8 15 00 00 00       	mov    $0x15,%eax
  8013b4:	89 d1                	mov    %edx,%ecx
  8013b6:	89 d3                	mov    %edx,%ebx
  8013b8:	89 d7                	mov    %edx,%edi
  8013ba:	51                   	push   %ecx
  8013bb:	52                   	push   %edx
  8013bc:	53                   	push   %ebx
  8013bd:	54                   	push   %esp
  8013be:	55                   	push   %ebp
  8013bf:	56                   	push   %esi
  8013c0:	57                   	push   %edi
  8013c1:	54                   	push   %esp
  8013c2:	5d                   	pop    %ebp
  8013c3:	8d 35 cb 13 80 00    	lea    0x8013cb,%esi
  8013c9:	0f 34                	sysenter 
  8013cb:	5f                   	pop    %edi
  8013cc:	5e                   	pop    %esi
  8013cd:	5d                   	pop    %ebp
  8013ce:	5c                   	pop    %esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5a                   	pop    %edx
  8013d1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8013d2:	8b 1c 24             	mov    (%esp),%ebx
  8013d5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d9:	89 ec                	mov    %ebp,%esp
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013ef:	b8 14 00 00 00       	mov    $0x14,%eax
  8013f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f7:	89 cb                	mov    %ecx,%ebx
  8013f9:	89 cf                	mov    %ecx,%edi
  8013fb:	51                   	push   %ecx
  8013fc:	52                   	push   %edx
  8013fd:	53                   	push   %ebx
  8013fe:	54                   	push   %esp
  8013ff:	55                   	push   %ebp
  801400:	56                   	push   %esi
  801401:	57                   	push   %edi
  801402:	54                   	push   %esp
  801403:	5d                   	pop    %ebp
  801404:	8d 35 0c 14 80 00    	lea    0x80140c,%esi
  80140a:	0f 34                	sysenter 
  80140c:	5f                   	pop    %edi
  80140d:	5e                   	pop    %esi
  80140e:	5d                   	pop    %ebp
  80140f:	5c                   	pop    %esp
  801410:	5b                   	pop    %ebx
  801411:	5a                   	pop    %edx
  801412:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801413:	8b 1c 24             	mov    (%esp),%ebx
  801416:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80141a:	89 ec                	mov    %ebp,%esp
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 28             	sub    $0x28,%esp
  801424:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801427:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80142a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80142f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801434:	8b 55 08             	mov    0x8(%ebp),%edx
  801437:	89 cb                	mov    %ecx,%ebx
  801439:	89 cf                	mov    %ecx,%edi
  80143b:	51                   	push   %ecx
  80143c:	52                   	push   %edx
  80143d:	53                   	push   %ebx
  80143e:	54                   	push   %esp
  80143f:	55                   	push   %ebp
  801440:	56                   	push   %esi
  801441:	57                   	push   %edi
  801442:	54                   	push   %esp
  801443:	5d                   	pop    %ebp
  801444:	8d 35 4c 14 80 00    	lea    0x80144c,%esi
  80144a:	0f 34                	sysenter 
  80144c:	5f                   	pop    %edi
  80144d:	5e                   	pop    %esi
  80144e:	5d                   	pop    %ebp
  80144f:	5c                   	pop    %esp
  801450:	5b                   	pop    %ebx
  801451:	5a                   	pop    %edx
  801452:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801453:	85 c0                	test   %eax,%eax
  801455:	7e 28                	jle    80147f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801457:	89 44 24 10          	mov    %eax,0x10(%esp)
  80145b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801462:	00 
  801463:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  80146a:	00 
  80146b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801472:	00 
  801473:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  80147a:	e8 59 ef ff ff       	call   8003d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80147f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801482:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801485:	89 ec                	mov    %ebp,%esp
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	89 1c 24             	mov    %ebx,(%esp)
  801492:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801496:	b8 0d 00 00 00       	mov    $0xd,%eax
  80149b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80149e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a7:	51                   	push   %ecx
  8014a8:	52                   	push   %edx
  8014a9:	53                   	push   %ebx
  8014aa:	54                   	push   %esp
  8014ab:	55                   	push   %ebp
  8014ac:	56                   	push   %esi
  8014ad:	57                   	push   %edi
  8014ae:	54                   	push   %esp
  8014af:	5d                   	pop    %ebp
  8014b0:	8d 35 b8 14 80 00    	lea    0x8014b8,%esi
  8014b6:	0f 34                	sysenter 
  8014b8:	5f                   	pop    %edi
  8014b9:	5e                   	pop    %esi
  8014ba:	5d                   	pop    %ebp
  8014bb:	5c                   	pop    %esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5a                   	pop    %edx
  8014be:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8014bf:	8b 1c 24             	mov    (%esp),%ebx
  8014c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014c6:	89 ec                	mov    %ebp,%esp
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 28             	sub    $0x28,%esp
  8014d0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014d3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014db:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e6:	89 df                	mov    %ebx,%edi
  8014e8:	51                   	push   %ecx
  8014e9:	52                   	push   %edx
  8014ea:	53                   	push   %ebx
  8014eb:	54                   	push   %esp
  8014ec:	55                   	push   %ebp
  8014ed:	56                   	push   %esi
  8014ee:	57                   	push   %edi
  8014ef:	54                   	push   %esp
  8014f0:	5d                   	pop    %ebp
  8014f1:	8d 35 f9 14 80 00    	lea    0x8014f9,%esi
  8014f7:	0f 34                	sysenter 
  8014f9:	5f                   	pop    %edi
  8014fa:	5e                   	pop    %esi
  8014fb:	5d                   	pop    %ebp
  8014fc:	5c                   	pop    %esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5a                   	pop    %edx
  8014ff:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801500:	85 c0                	test   %eax,%eax
  801502:	7e 28                	jle    80152c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801504:	89 44 24 10          	mov    %eax,0x10(%esp)
  801508:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80150f:	00 
  801510:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  801517:	00 
  801518:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80151f:	00 
  801520:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  801527:	e8 ac ee ff ff       	call   8003d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80152c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80152f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801532:	89 ec                	mov    %ebp,%esp
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    

00801536 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	83 ec 28             	sub    $0x28,%esp
  80153c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80153f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801542:	bb 00 00 00 00       	mov    $0x0,%ebx
  801547:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154f:	8b 55 08             	mov    0x8(%ebp),%edx
  801552:	89 df                	mov    %ebx,%edi
  801554:	51                   	push   %ecx
  801555:	52                   	push   %edx
  801556:	53                   	push   %ebx
  801557:	54                   	push   %esp
  801558:	55                   	push   %ebp
  801559:	56                   	push   %esi
  80155a:	57                   	push   %edi
  80155b:	54                   	push   %esp
  80155c:	5d                   	pop    %ebp
  80155d:	8d 35 65 15 80 00    	lea    0x801565,%esi
  801563:	0f 34                	sysenter 
  801565:	5f                   	pop    %edi
  801566:	5e                   	pop    %esi
  801567:	5d                   	pop    %ebp
  801568:	5c                   	pop    %esp
  801569:	5b                   	pop    %ebx
  80156a:	5a                   	pop    %edx
  80156b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80156c:	85 c0                	test   %eax,%eax
  80156e:	7e 28                	jle    801598 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801570:	89 44 24 10          	mov    %eax,0x10(%esp)
  801574:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80157b:	00 
  80157c:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  801583:	00 
  801584:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80158b:	00 
  80158c:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  801593:	e8 40 ee ff ff       	call   8003d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801598:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80159b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80159e:	89 ec                	mov    %ebp,%esp
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	83 ec 28             	sub    $0x28,%esp
  8015a8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015ab:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8015b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8015be:	89 df                	mov    %ebx,%edi
  8015c0:	51                   	push   %ecx
  8015c1:	52                   	push   %edx
  8015c2:	53                   	push   %ebx
  8015c3:	54                   	push   %esp
  8015c4:	55                   	push   %ebp
  8015c5:	56                   	push   %esi
  8015c6:	57                   	push   %edi
  8015c7:	54                   	push   %esp
  8015c8:	5d                   	pop    %ebp
  8015c9:	8d 35 d1 15 80 00    	lea    0x8015d1,%esi
  8015cf:	0f 34                	sysenter 
  8015d1:	5f                   	pop    %edi
  8015d2:	5e                   	pop    %esi
  8015d3:	5d                   	pop    %ebp
  8015d4:	5c                   	pop    %esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5a                   	pop    %edx
  8015d7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	7e 28                	jle    801604 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8015e7:	00 
  8015e8:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  8015ef:	00 
  8015f0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015f7:	00 
  8015f8:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  8015ff:	e8 d4 ed ff ff       	call   8003d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801604:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801607:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80160a:	89 ec                	mov    %ebp,%esp
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 28             	sub    $0x28,%esp
  801614:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801617:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80161a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161f:	b8 07 00 00 00       	mov    $0x7,%eax
  801624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801627:	8b 55 08             	mov    0x8(%ebp),%edx
  80162a:	89 df                	mov    %ebx,%edi
  80162c:	51                   	push   %ecx
  80162d:	52                   	push   %edx
  80162e:	53                   	push   %ebx
  80162f:	54                   	push   %esp
  801630:	55                   	push   %ebp
  801631:	56                   	push   %esi
  801632:	57                   	push   %edi
  801633:	54                   	push   %esp
  801634:	5d                   	pop    %ebp
  801635:	8d 35 3d 16 80 00    	lea    0x80163d,%esi
  80163b:	0f 34                	sysenter 
  80163d:	5f                   	pop    %edi
  80163e:	5e                   	pop    %esi
  80163f:	5d                   	pop    %ebp
  801640:	5c                   	pop    %esp
  801641:	5b                   	pop    %ebx
  801642:	5a                   	pop    %edx
  801643:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801644:	85 c0                	test   %eax,%eax
  801646:	7e 28                	jle    801670 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801648:	89 44 24 10          	mov    %eax,0x10(%esp)
  80164c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801653:	00 
  801654:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  80165b:	00 
  80165c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801663:	00 
  801664:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  80166b:	e8 68 ed ff ff       	call   8003d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801670:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801673:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801676:	89 ec                	mov    %ebp,%esp
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    

0080167a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	83 ec 28             	sub    $0x28,%esp
  801680:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801683:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801686:	8b 7d 18             	mov    0x18(%ebp),%edi
  801689:	0b 7d 14             	or     0x14(%ebp),%edi
  80168c:	b8 06 00 00 00       	mov    $0x6,%eax
  801691:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801694:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801697:	8b 55 08             	mov    0x8(%ebp),%edx
  80169a:	51                   	push   %ecx
  80169b:	52                   	push   %edx
  80169c:	53                   	push   %ebx
  80169d:	54                   	push   %esp
  80169e:	55                   	push   %ebp
  80169f:	56                   	push   %esi
  8016a0:	57                   	push   %edi
  8016a1:	54                   	push   %esp
  8016a2:	5d                   	pop    %ebp
  8016a3:	8d 35 ab 16 80 00    	lea    0x8016ab,%esi
  8016a9:	0f 34                	sysenter 
  8016ab:	5f                   	pop    %edi
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	5c                   	pop    %esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5a                   	pop    %edx
  8016b1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	7e 28                	jle    8016de <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8016c1:	00 
  8016c2:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  8016c9:	00 
  8016ca:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8016d1:	00 
  8016d2:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  8016d9:	e8 fa ec ff ff       	call   8003d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8016de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016e4:	89 ec                	mov    %ebp,%esp
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 28             	sub    $0x28,%esp
  8016ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016f1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8016f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8016f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801704:	8b 55 08             	mov    0x8(%ebp),%edx
  801707:	51                   	push   %ecx
  801708:	52                   	push   %edx
  801709:	53                   	push   %ebx
  80170a:	54                   	push   %esp
  80170b:	55                   	push   %ebp
  80170c:	56                   	push   %esi
  80170d:	57                   	push   %edi
  80170e:	54                   	push   %esp
  80170f:	5d                   	pop    %ebp
  801710:	8d 35 18 17 80 00    	lea    0x801718,%esi
  801716:	0f 34                	sysenter 
  801718:	5f                   	pop    %edi
  801719:	5e                   	pop    %esi
  80171a:	5d                   	pop    %ebp
  80171b:	5c                   	pop    %esp
  80171c:	5b                   	pop    %ebx
  80171d:	5a                   	pop    %edx
  80171e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80171f:	85 c0                	test   %eax,%eax
  801721:	7e 28                	jle    80174b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801723:	89 44 24 10          	mov    %eax,0x10(%esp)
  801727:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80172e:	00 
  80172f:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  801736:	00 
  801737:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80173e:	00 
  80173f:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  801746:	e8 8d ec ff ff       	call   8003d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80174b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80174e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801751:	89 ec                	mov    %ebp,%esp
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	89 1c 24             	mov    %ebx,(%esp)
  80175e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801762:	ba 00 00 00 00       	mov    $0x0,%edx
  801767:	b8 0c 00 00 00       	mov    $0xc,%eax
  80176c:	89 d1                	mov    %edx,%ecx
  80176e:	89 d3                	mov    %edx,%ebx
  801770:	89 d7                	mov    %edx,%edi
  801772:	51                   	push   %ecx
  801773:	52                   	push   %edx
  801774:	53                   	push   %ebx
  801775:	54                   	push   %esp
  801776:	55                   	push   %ebp
  801777:	56                   	push   %esi
  801778:	57                   	push   %edi
  801779:	54                   	push   %esp
  80177a:	5d                   	pop    %ebp
  80177b:	8d 35 83 17 80 00    	lea    0x801783,%esi
  801781:	0f 34                	sysenter 
  801783:	5f                   	pop    %edi
  801784:	5e                   	pop    %esi
  801785:	5d                   	pop    %ebp
  801786:	5c                   	pop    %esp
  801787:	5b                   	pop    %ebx
  801788:	5a                   	pop    %edx
  801789:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80178a:	8b 1c 24             	mov    (%esp),%ebx
  80178d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801791:	89 ec                	mov    %ebp,%esp
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	89 1c 24             	mov    %ebx,(%esp)
  80179e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8017a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017af:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b2:	89 df                	mov    %ebx,%edi
  8017b4:	51                   	push   %ecx
  8017b5:	52                   	push   %edx
  8017b6:	53                   	push   %ebx
  8017b7:	54                   	push   %esp
  8017b8:	55                   	push   %ebp
  8017b9:	56                   	push   %esi
  8017ba:	57                   	push   %edi
  8017bb:	54                   	push   %esp
  8017bc:	5d                   	pop    %ebp
  8017bd:	8d 35 c5 17 80 00    	lea    0x8017c5,%esi
  8017c3:	0f 34                	sysenter 
  8017c5:	5f                   	pop    %edi
  8017c6:	5e                   	pop    %esi
  8017c7:	5d                   	pop    %ebp
  8017c8:	5c                   	pop    %esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5a                   	pop    %edx
  8017cb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8017cc:	8b 1c 24             	mov    (%esp),%ebx
  8017cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017d3:	89 ec                	mov    %ebp,%esp
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	89 1c 24             	mov    %ebx,(%esp)
  8017e0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8017e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ee:	89 d1                	mov    %edx,%ecx
  8017f0:	89 d3                	mov    %edx,%ebx
  8017f2:	89 d7                	mov    %edx,%edi
  8017f4:	51                   	push   %ecx
  8017f5:	52                   	push   %edx
  8017f6:	53                   	push   %ebx
  8017f7:	54                   	push   %esp
  8017f8:	55                   	push   %ebp
  8017f9:	56                   	push   %esi
  8017fa:	57                   	push   %edi
  8017fb:	54                   	push   %esp
  8017fc:	5d                   	pop    %ebp
  8017fd:	8d 35 05 18 80 00    	lea    0x801805,%esi
  801803:	0f 34                	sysenter 
  801805:	5f                   	pop    %edi
  801806:	5e                   	pop    %esi
  801807:	5d                   	pop    %ebp
  801808:	5c                   	pop    %esp
  801809:	5b                   	pop    %ebx
  80180a:	5a                   	pop    %edx
  80180b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80180c:	8b 1c 24             	mov    (%esp),%ebx
  80180f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801813:	89 ec                	mov    %ebp,%esp
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 28             	sub    $0x28,%esp
  80181d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801820:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801823:	b9 00 00 00 00       	mov    $0x0,%ecx
  801828:	b8 03 00 00 00       	mov    $0x3,%eax
  80182d:	8b 55 08             	mov    0x8(%ebp),%edx
  801830:	89 cb                	mov    %ecx,%ebx
  801832:	89 cf                	mov    %ecx,%edi
  801834:	51                   	push   %ecx
  801835:	52                   	push   %edx
  801836:	53                   	push   %ebx
  801837:	54                   	push   %esp
  801838:	55                   	push   %ebp
  801839:	56                   	push   %esi
  80183a:	57                   	push   %edi
  80183b:	54                   	push   %esp
  80183c:	5d                   	pop    %ebp
  80183d:	8d 35 45 18 80 00    	lea    0x801845,%esi
  801843:	0f 34                	sysenter 
  801845:	5f                   	pop    %edi
  801846:	5e                   	pop    %esi
  801847:	5d                   	pop    %ebp
  801848:	5c                   	pop    %esp
  801849:	5b                   	pop    %ebx
  80184a:	5a                   	pop    %edx
  80184b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80184c:	85 c0                	test   %eax,%eax
  80184e:	7e 28                	jle    801878 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801850:	89 44 24 10          	mov    %eax,0x10(%esp)
  801854:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80185b:	00 
  80185c:	c7 44 24 08 40 33 80 	movl   $0x803340,0x8(%esp)
  801863:	00 
  801864:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80186b:	00 
  80186c:	c7 04 24 5d 33 80 00 	movl   $0x80335d,(%esp)
  801873:	e8 60 eb ff ff       	call   8003d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801878:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80187b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80187e:	89 ec                	mov    %ebp,%esp
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    
	...

00801884 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80188a:	c7 44 24 08 6b 33 80 	movl   $0x80336b,0x8(%esp)
  801891:	00 
  801892:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801899:	00 
  80189a:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  8018a1:	e8 32 eb ff ff       	call   8003d8 <_panic>

008018a6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	57                   	push   %edi
  8018aa:	56                   	push   %esi
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  8018af:	c7 04 24 fb 1a 80 00 	movl   $0x801afb,(%esp)
  8018b6:	e8 89 12 00 00       	call   802b44 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8018bb:	ba 08 00 00 00       	mov    $0x8,%edx
  8018c0:	89 d0                	mov    %edx,%eax
  8018c2:	cd 30                	int    $0x30
  8018c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	79 20                	jns    8018eb <fork+0x45>
		panic("sys_exofork: %e", envid);
  8018cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018cf:	c7 44 24 08 8c 33 80 	movl   $0x80338c,0x8(%esp)
  8018d6:	00 
  8018d7:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8018de:	00 
  8018df:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  8018e6:	e8 ed ea ff ff       	call   8003d8 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8018eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8018f0:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8018f5:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8018fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018fe:	75 20                	jne    801920 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801900:	e8 d2 fe ff ff       	call   8017d7 <sys_getenvid>
  801905:	25 ff 03 00 00       	and    $0x3ff,%eax
  80190a:	89 c2                	mov    %eax,%edx
  80190c:	c1 e2 07             	shl    $0x7,%edx
  80190f:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801916:	a3 10 50 80 00       	mov    %eax,0x805010
		return 0;
  80191b:	e9 d0 01 00 00       	jmp    801af0 <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801920:	89 d8                	mov    %ebx,%eax
  801922:	c1 e8 16             	shr    $0x16,%eax
  801925:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801928:	a8 01                	test   $0x1,%al
  80192a:	0f 84 0d 01 00 00    	je     801a3d <fork+0x197>
  801930:	89 d8                	mov    %ebx,%eax
  801932:	c1 e8 0c             	shr    $0xc,%eax
  801935:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801938:	f6 c2 01             	test   $0x1,%dl
  80193b:	0f 84 fc 00 00 00    	je     801a3d <fork+0x197>
  801941:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801944:	f6 c2 04             	test   $0x4,%dl
  801947:	0f 84 f0 00 00 00    	je     801a3d <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  80194d:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  801950:	89 c2                	mov    %eax,%edx
  801952:	c1 ea 0c             	shr    $0xc,%edx
  801955:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801958:	f6 c2 01             	test   $0x1,%dl
  80195b:	0f 84 dc 00 00 00    	je     801a3d <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  801961:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801967:	0f 84 8d 00 00 00    	je     8019fa <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  80196d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801970:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801977:	00 
  801978:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80197c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80197f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801983:	89 44 24 04          	mov    %eax,0x4(%esp)
  801987:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80198e:	e8 e7 fc ff ff       	call   80167a <sys_page_map>
               if(r<0)
  801993:	85 c0                	test   %eax,%eax
  801995:	79 1c                	jns    8019b3 <fork+0x10d>
                 panic("map failed");
  801997:	c7 44 24 08 9c 33 80 	movl   $0x80339c,0x8(%esp)
  80199e:	00 
  80199f:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8019a6:	00 
  8019a7:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  8019ae:	e8 25 ea ff ff       	call   8003d8 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  8019b3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8019ba:	00 
  8019bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019c9:	00 
  8019ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d5:	e8 a0 fc ff ff       	call   80167a <sys_page_map>
               if(r<0)
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	79 5f                	jns    801a3d <fork+0x197>
                 panic("map failed");
  8019de:	c7 44 24 08 9c 33 80 	movl   $0x80339c,0x8(%esp)
  8019e5:	00 
  8019e6:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8019ed:	00 
  8019ee:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  8019f5:	e8 de e9 ff ff       	call   8003d8 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  8019fa:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801a01:	00 
  801a02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a09:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a18:	e8 5d fc ff ff       	call   80167a <sys_page_map>
               if(r<0)
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	79 1c                	jns    801a3d <fork+0x197>
                 panic("map failed");
  801a21:	c7 44 24 08 9c 33 80 	movl   $0x80339c,0x8(%esp)
  801a28:	00 
  801a29:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801a30:	00 
  801a31:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  801a38:	e8 9b e9 ff ff       	call   8003d8 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801a3d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a43:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a49:	0f 85 d1 fe ff ff    	jne    801920 <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801a4f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a56:	00 
  801a57:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801a5e:	ee 
  801a5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a62:	89 04 24             	mov    %eax,(%esp)
  801a65:	e8 7e fc ff ff       	call   8016e8 <sys_page_alloc>
        if(r < 0)
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	79 1c                	jns    801a8a <fork+0x1e4>
            panic("alloc failed");
  801a6e:	c7 44 24 08 a7 33 80 	movl   $0x8033a7,0x8(%esp)
  801a75:	00 
  801a76:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801a7d:	00 
  801a7e:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  801a85:	e8 4e e9 ff ff       	call   8003d8 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a8a:	c7 44 24 04 90 2b 80 	movl   $0x802b90,0x4(%esp)
  801a91:	00 
  801a92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a95:	89 14 24             	mov    %edx,(%esp)
  801a98:	e8 2d fa ff ff       	call   8014ca <sys_env_set_pgfault_upcall>
        if(r < 0)
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	79 1c                	jns    801abd <fork+0x217>
            panic("set pgfault upcall failed");
  801aa1:	c7 44 24 08 b4 33 80 	movl   $0x8033b4,0x8(%esp)
  801aa8:	00 
  801aa9:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801ab0:	00 
  801ab1:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  801ab8:	e8 1b e9 ff ff       	call   8003d8 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801abd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801ac4:	00 
  801ac5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac8:	89 04 24             	mov    %eax,(%esp)
  801acb:	e8 d2 fa ff ff       	call   8015a2 <sys_env_set_status>
        if(r < 0)
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	79 1c                	jns    801af0 <fork+0x24a>
            panic("set status failed");
  801ad4:	c7 44 24 08 ce 33 80 	movl   $0x8033ce,0x8(%esp)
  801adb:	00 
  801adc:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801ae3:	00 
  801ae4:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  801aeb:	e8 e8 e8 ff ff       	call   8003d8 <_panic>
        return envid;
	//panic("fork not implemented");
}
  801af0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af3:	83 c4 3c             	add    $0x3c,%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	53                   	push   %ebx
  801aff:	83 ec 24             	sub    $0x24,%esp
  801b02:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801b05:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801b07:	89 da                	mov    %ebx,%edx
  801b09:	c1 ea 0c             	shr    $0xc,%edx
  801b0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  801b13:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801b17:	74 08                	je     801b21 <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801b19:	f7 c2 05 08 00 00    	test   $0x805,%edx
  801b1f:	75 1c                	jne    801b3d <pgfault+0x42>
           panic("pgfault error");
  801b21:	c7 44 24 08 e0 33 80 	movl   $0x8033e0,0x8(%esp)
  801b28:	00 
  801b29:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801b30:	00 
  801b31:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  801b38:	e8 9b e8 ff ff       	call   8003d8 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b3d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b44:	00 
  801b45:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801b4c:	00 
  801b4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b54:	e8 8f fb ff ff       	call   8016e8 <sys_page_alloc>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	79 20                	jns    801b7d <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  801b5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b61:	c7 44 24 08 aa 2e 80 	movl   $0x802eaa,0x8(%esp)
  801b68:	00 
  801b69:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801b70:	00 
  801b71:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  801b78:	e8 5b e8 ff ff       	call   8003d8 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  801b7d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801b83:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801b8a:	00 
  801b8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b8f:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801b96:	e8 0a f4 ff ff       	call   800fa5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801b9b:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801ba2:	00 
  801ba3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ba7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bae:	00 
  801baf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801bb6:	00 
  801bb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbe:	e8 b7 fa ff ff       	call   80167a <sys_page_map>
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	79 20                	jns    801be7 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801bc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcb:	c7 44 24 08 ee 33 80 	movl   $0x8033ee,0x8(%esp)
  801bd2:	00 
  801bd3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801bda:	00 
  801bdb:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  801be2:	e8 f1 e7 ff ff       	call   8003d8 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801be7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801bee:	00 
  801bef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf6:	e8 13 fa ff ff       	call   80160e <sys_page_unmap>
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	79 20                	jns    801c1f <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  801bff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c03:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  801c0a:	00 
  801c0b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801c12:	00 
  801c13:	c7 04 24 81 33 80 00 	movl   $0x803381,(%esp)
  801c1a:	e8 b9 e7 ff ff       	call   8003d8 <_panic>
	//panic("pgfault not implemented");
}
  801c1f:	83 c4 24             	add    $0x24,%esp
  801c22:	5b                   	pop    %ebx
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
	...

00801c30 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c36:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801c3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c41:	39 ca                	cmp    %ecx,%edx
  801c43:	75 04                	jne    801c49 <ipc_find_env+0x19>
  801c45:	b0 00                	mov    $0x0,%al
  801c47:	eb 12                	jmp    801c5b <ipc_find_env+0x2b>
  801c49:	89 c2                	mov    %eax,%edx
  801c4b:	c1 e2 07             	shl    $0x7,%edx
  801c4e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801c55:	8b 12                	mov    (%edx),%edx
  801c57:	39 ca                	cmp    %ecx,%edx
  801c59:	75 10                	jne    801c6b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c5b:	89 c2                	mov    %eax,%edx
  801c5d:	c1 e2 07             	shl    $0x7,%edx
  801c60:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801c67:	8b 00                	mov    (%eax),%eax
  801c69:	eb 0e                	jmp    801c79 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c6b:	83 c0 01             	add    $0x1,%eax
  801c6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c73:	75 d4                	jne    801c49 <ipc_find_env+0x19>
  801c75:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	57                   	push   %edi
  801c7f:	56                   	push   %esi
  801c80:	53                   	push   %ebx
  801c81:	83 ec 1c             	sub    $0x1c,%esp
  801c84:	8b 75 08             	mov    0x8(%ebp),%esi
  801c87:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801c8d:	85 db                	test   %ebx,%ebx
  801c8f:	74 19                	je     801caa <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801c91:	8b 45 14             	mov    0x14(%ebp),%eax
  801c94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ca0:	89 34 24             	mov    %esi,(%esp)
  801ca3:	e8 e1 f7 ff ff       	call   801489 <sys_ipc_try_send>
  801ca8:	eb 1b                	jmp    801cc5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801caa:	8b 45 14             	mov    0x14(%ebp),%eax
  801cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cb1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801cb8:	ee 
  801cb9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cbd:	89 34 24             	mov    %esi,(%esp)
  801cc0:	e8 c4 f7 ff ff       	call   801489 <sys_ipc_try_send>
           if(ret == 0)
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	74 28                	je     801cf1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801cc9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ccc:	74 1c                	je     801cea <ipc_send+0x6f>
              panic("ipc send error");
  801cce:	c7 44 24 08 12 34 80 	movl   $0x803412,0x8(%esp)
  801cd5:	00 
  801cd6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801cdd:	00 
  801cde:	c7 04 24 21 34 80 00 	movl   $0x803421,(%esp)
  801ce5:	e8 ee e6 ff ff       	call   8003d8 <_panic>
           sys_yield();
  801cea:	e8 66 fa ff ff       	call   801755 <sys_yield>
        }
  801cef:	eb 9c                	jmp    801c8d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 10             	sub    $0x10,%esp
  801d01:	8b 75 08             	mov    0x8(%ebp),%esi
  801d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	75 0e                	jne    801d1c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801d0e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801d15:	e8 04 f7 ff ff       	call   80141e <sys_ipc_recv>
  801d1a:	eb 08                	jmp    801d24 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801d1c:	89 04 24             	mov    %eax,(%esp)
  801d1f:	e8 fa f6 ff ff       	call   80141e <sys_ipc_recv>
        if(ret == 0){
  801d24:	85 c0                	test   %eax,%eax
  801d26:	75 26                	jne    801d4e <ipc_recv+0x55>
           if(from_env_store)
  801d28:	85 f6                	test   %esi,%esi
  801d2a:	74 0a                	je     801d36 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801d2c:	a1 10 50 80 00       	mov    0x805010,%eax
  801d31:	8b 40 78             	mov    0x78(%eax),%eax
  801d34:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801d36:	85 db                	test   %ebx,%ebx
  801d38:	74 0a                	je     801d44 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801d3a:	a1 10 50 80 00       	mov    0x805010,%eax
  801d3f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801d42:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801d44:	a1 10 50 80 00       	mov    0x805010,%eax
  801d49:	8b 40 74             	mov    0x74(%eax),%eax
  801d4c:	eb 14                	jmp    801d62 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801d4e:	85 f6                	test   %esi,%esi
  801d50:	74 06                	je     801d58 <ipc_recv+0x5f>
              *from_env_store = 0;
  801d52:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801d58:	85 db                	test   %ebx,%ebx
  801d5a:	74 06                	je     801d62 <ipc_recv+0x69>
              *perm_store = 0;
  801d5c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	00 00                	add    %al,(%eax)
  801d6b:	00 00                	add    %al,(%eax)
  801d6d:	00 00                	add    %al,(%eax)
	...

00801d70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	8b 45 08             	mov    0x8(%ebp),%eax
  801d76:	05 00 00 00 30       	add    $0x30000000,%eax
  801d7b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801d86:	8b 45 08             	mov    0x8(%ebp),%eax
  801d89:	89 04 24             	mov    %eax,(%esp)
  801d8c:	e8 df ff ff ff       	call   801d70 <fd2num>
  801d91:	05 20 00 0d 00       	add    $0xd0020,%eax
  801d96:	c1 e0 0c             	shl    $0xc,%eax
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	57                   	push   %edi
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801da4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801da9:	a8 01                	test   $0x1,%al
  801dab:	74 36                	je     801de3 <fd_alloc+0x48>
  801dad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801db2:	a8 01                	test   $0x1,%al
  801db4:	74 2d                	je     801de3 <fd_alloc+0x48>
  801db6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801dbb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801dc0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801dc5:	89 c3                	mov    %eax,%ebx
  801dc7:	89 c2                	mov    %eax,%edx
  801dc9:	c1 ea 16             	shr    $0x16,%edx
  801dcc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801dcf:	f6 c2 01             	test   $0x1,%dl
  801dd2:	74 14                	je     801de8 <fd_alloc+0x4d>
  801dd4:	89 c2                	mov    %eax,%edx
  801dd6:	c1 ea 0c             	shr    $0xc,%edx
  801dd9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801ddc:	f6 c2 01             	test   $0x1,%dl
  801ddf:	75 10                	jne    801df1 <fd_alloc+0x56>
  801de1:	eb 05                	jmp    801de8 <fd_alloc+0x4d>
  801de3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801de8:	89 1f                	mov    %ebx,(%edi)
  801dea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801def:	eb 17                	jmp    801e08 <fd_alloc+0x6d>
  801df1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801df6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801dfb:	75 c8                	jne    801dc5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801dfd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801e03:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    

00801e0d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801e10:	8b 45 08             	mov    0x8(%ebp),%eax
  801e13:	83 f8 1f             	cmp    $0x1f,%eax
  801e16:	77 36                	ja     801e4e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801e18:	05 00 00 0d 00       	add    $0xd0000,%eax
  801e1d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801e20:	89 c2                	mov    %eax,%edx
  801e22:	c1 ea 16             	shr    $0x16,%edx
  801e25:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e2c:	f6 c2 01             	test   $0x1,%dl
  801e2f:	74 1d                	je     801e4e <fd_lookup+0x41>
  801e31:	89 c2                	mov    %eax,%edx
  801e33:	c1 ea 0c             	shr    $0xc,%edx
  801e36:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e3d:	f6 c2 01             	test   $0x1,%dl
  801e40:	74 0c                	je     801e4e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e45:	89 02                	mov    %eax,(%edx)
  801e47:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801e4c:	eb 05                	jmp    801e53 <fd_lookup+0x46>
  801e4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    

00801e55 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e62:	8b 45 08             	mov    0x8(%ebp),%eax
  801e65:	89 04 24             	mov    %eax,(%esp)
  801e68:	e8 a0 ff ff ff       	call   801e0d <fd_lookup>
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 0e                	js     801e7f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801e71:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e77:	89 50 04             	mov    %edx,0x4(%eax)
  801e7a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	83 ec 10             	sub    $0x10,%esp
  801e89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801e8f:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801e94:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801e99:	be ac 34 80 00       	mov    $0x8034ac,%esi
		if (devtab[i]->dev_id == dev_id) {
  801e9e:	39 08                	cmp    %ecx,(%eax)
  801ea0:	75 10                	jne    801eb2 <dev_lookup+0x31>
  801ea2:	eb 04                	jmp    801ea8 <dev_lookup+0x27>
  801ea4:	39 08                	cmp    %ecx,(%eax)
  801ea6:	75 0a                	jne    801eb2 <dev_lookup+0x31>
			*dev = devtab[i];
  801ea8:	89 03                	mov    %eax,(%ebx)
  801eaa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801eaf:	90                   	nop
  801eb0:	eb 31                	jmp    801ee3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801eb2:	83 c2 01             	add    $0x1,%edx
  801eb5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	75 e8                	jne    801ea4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801ebc:	a1 10 50 80 00       	mov    0x805010,%eax
  801ec1:	8b 40 48             	mov    0x48(%eax),%eax
  801ec4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecc:	c7 04 24 2c 34 80 00 	movl   $0x80342c,(%esp)
  801ed3:	e8 b9 e5 ff ff       	call   800491 <cprintf>
	*dev = 0;
  801ed8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	5b                   	pop    %ebx
  801ee7:	5e                   	pop    %esi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	53                   	push   %ebx
  801eee:	83 ec 24             	sub    $0x24,%esp
  801ef1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ef4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efb:	8b 45 08             	mov    0x8(%ebp),%eax
  801efe:	89 04 24             	mov    %eax,(%esp)
  801f01:	e8 07 ff ff ff       	call   801e0d <fd_lookup>
  801f06:	85 c0                	test   %eax,%eax
  801f08:	78 53                	js     801f5d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f14:	8b 00                	mov    (%eax),%eax
  801f16:	89 04 24             	mov    %eax,(%esp)
  801f19:	e8 63 ff ff ff       	call   801e81 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 3b                	js     801f5d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801f22:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f2a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801f2e:	74 2d                	je     801f5d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801f30:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801f33:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801f3a:	00 00 00 
	stat->st_isdir = 0;
  801f3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f44:	00 00 00 
	stat->st_dev = dev;
  801f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801f50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f57:	89 14 24             	mov    %edx,(%esp)
  801f5a:	ff 50 14             	call   *0x14(%eax)
}
  801f5d:	83 c4 24             	add    $0x24,%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    

00801f63 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	53                   	push   %ebx
  801f67:	83 ec 24             	sub    $0x24,%esp
  801f6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f74:	89 1c 24             	mov    %ebx,(%esp)
  801f77:	e8 91 fe ff ff       	call   801e0d <fd_lookup>
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 5f                	js     801fdf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f8a:	8b 00                	mov    (%eax),%eax
  801f8c:	89 04 24             	mov    %eax,(%esp)
  801f8f:	e8 ed fe ff ff       	call   801e81 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f94:	85 c0                	test   %eax,%eax
  801f96:	78 47                	js     801fdf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f9b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801f9f:	75 23                	jne    801fc4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801fa1:	a1 10 50 80 00       	mov    0x805010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801fa6:	8b 40 48             	mov    0x48(%eax),%eax
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb1:	c7 04 24 4c 34 80 00 	movl   $0x80344c,(%esp)
  801fb8:	e8 d4 e4 ff ff       	call   800491 <cprintf>
  801fbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801fc2:	eb 1b                	jmp    801fdf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc7:	8b 48 18             	mov    0x18(%eax),%ecx
  801fca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801fcf:	85 c9                	test   %ecx,%ecx
  801fd1:	74 0c                	je     801fdf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fda:	89 14 24             	mov    %edx,(%esp)
  801fdd:	ff d1                	call   *%ecx
}
  801fdf:	83 c4 24             	add    $0x24,%esp
  801fe2:	5b                   	pop    %ebx
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	53                   	push   %ebx
  801fe9:	83 ec 24             	sub    $0x24,%esp
  801fec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff6:	89 1c 24             	mov    %ebx,(%esp)
  801ff9:	e8 0f fe ff ff       	call   801e0d <fd_lookup>
  801ffe:	85 c0                	test   %eax,%eax
  802000:	78 66                	js     802068 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802002:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802005:	89 44 24 04          	mov    %eax,0x4(%esp)
  802009:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80200c:	8b 00                	mov    (%eax),%eax
  80200e:	89 04 24             	mov    %eax,(%esp)
  802011:	e8 6b fe ff ff       	call   801e81 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802016:	85 c0                	test   %eax,%eax
  802018:	78 4e                	js     802068 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80201a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80201d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  802021:	75 23                	jne    802046 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802023:	a1 10 50 80 00       	mov    0x805010,%eax
  802028:	8b 40 48             	mov    0x48(%eax),%eax
  80202b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802033:	c7 04 24 70 34 80 00 	movl   $0x803470,(%esp)
  80203a:	e8 52 e4 ff ff       	call   800491 <cprintf>
  80203f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  802044:	eb 22                	jmp    802068 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802049:	8b 48 0c             	mov    0xc(%eax),%ecx
  80204c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802051:	85 c9                	test   %ecx,%ecx
  802053:	74 13                	je     802068 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802055:	8b 45 10             	mov    0x10(%ebp),%eax
  802058:	89 44 24 08          	mov    %eax,0x8(%esp)
  80205c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802063:	89 14 24             	mov    %edx,(%esp)
  802066:	ff d1                	call   *%ecx
}
  802068:	83 c4 24             	add    $0x24,%esp
  80206b:	5b                   	pop    %ebx
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    

0080206e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	53                   	push   %ebx
  802072:	83 ec 24             	sub    $0x24,%esp
  802075:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802078:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80207b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207f:	89 1c 24             	mov    %ebx,(%esp)
  802082:	e8 86 fd ff ff       	call   801e0d <fd_lookup>
  802087:	85 c0                	test   %eax,%eax
  802089:	78 6b                	js     8020f6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80208b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802092:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802095:	8b 00                	mov    (%eax),%eax
  802097:	89 04 24             	mov    %eax,(%esp)
  80209a:	e8 e2 fd ff ff       	call   801e81 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	78 53                	js     8020f6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8020a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020a6:	8b 42 08             	mov    0x8(%edx),%eax
  8020a9:	83 e0 03             	and    $0x3,%eax
  8020ac:	83 f8 01             	cmp    $0x1,%eax
  8020af:	75 23                	jne    8020d4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8020b1:	a1 10 50 80 00       	mov    0x805010,%eax
  8020b6:	8b 40 48             	mov    0x48(%eax),%eax
  8020b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c1:	c7 04 24 8d 34 80 00 	movl   $0x80348d,(%esp)
  8020c8:	e8 c4 e3 ff ff       	call   800491 <cprintf>
  8020cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8020d2:	eb 22                	jmp    8020f6 <read+0x88>
	}
	if (!dev->dev_read)
  8020d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d7:	8b 48 08             	mov    0x8(%eax),%ecx
  8020da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020df:	85 c9                	test   %ecx,%ecx
  8020e1:	74 13                	je     8020f6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8020e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f1:	89 14 24             	mov    %edx,(%esp)
  8020f4:	ff d1                	call   *%ecx
}
  8020f6:	83 c4 24             	add    $0x24,%esp
  8020f9:	5b                   	pop    %ebx
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    

008020fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	57                   	push   %edi
  802100:	56                   	push   %esi
  802101:	53                   	push   %ebx
  802102:	83 ec 1c             	sub    $0x1c,%esp
  802105:	8b 7d 08             	mov    0x8(%ebp),%edi
  802108:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80210b:	ba 00 00 00 00       	mov    $0x0,%edx
  802110:	bb 00 00 00 00       	mov    $0x0,%ebx
  802115:	b8 00 00 00 00       	mov    $0x0,%eax
  80211a:	85 f6                	test   %esi,%esi
  80211c:	74 29                	je     802147 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80211e:	89 f0                	mov    %esi,%eax
  802120:	29 d0                	sub    %edx,%eax
  802122:	89 44 24 08          	mov    %eax,0x8(%esp)
  802126:	03 55 0c             	add    0xc(%ebp),%edx
  802129:	89 54 24 04          	mov    %edx,0x4(%esp)
  80212d:	89 3c 24             	mov    %edi,(%esp)
  802130:	e8 39 ff ff ff       	call   80206e <read>
		if (m < 0)
  802135:	85 c0                	test   %eax,%eax
  802137:	78 0e                	js     802147 <readn+0x4b>
			return m;
		if (m == 0)
  802139:	85 c0                	test   %eax,%eax
  80213b:	74 08                	je     802145 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80213d:	01 c3                	add    %eax,%ebx
  80213f:	89 da                	mov    %ebx,%edx
  802141:	39 f3                	cmp    %esi,%ebx
  802143:	72 d9                	jb     80211e <readn+0x22>
  802145:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802147:	83 c4 1c             	add    $0x1c,%esp
  80214a:	5b                   	pop    %ebx
  80214b:	5e                   	pop    %esi
  80214c:	5f                   	pop    %edi
  80214d:	5d                   	pop    %ebp
  80214e:	c3                   	ret    

0080214f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 20             	sub    $0x20,%esp
  802157:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80215a:	89 34 24             	mov    %esi,(%esp)
  80215d:	e8 0e fc ff ff       	call   801d70 <fd2num>
  802162:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802165:	89 54 24 04          	mov    %edx,0x4(%esp)
  802169:	89 04 24             	mov    %eax,(%esp)
  80216c:	e8 9c fc ff ff       	call   801e0d <fd_lookup>
  802171:	89 c3                	mov    %eax,%ebx
  802173:	85 c0                	test   %eax,%eax
  802175:	78 05                	js     80217c <fd_close+0x2d>
  802177:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80217a:	74 0c                	je     802188 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80217c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  802180:	19 c0                	sbb    %eax,%eax
  802182:	f7 d0                	not    %eax
  802184:	21 c3                	and    %eax,%ebx
  802186:	eb 3d                	jmp    8021c5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802188:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80218b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80218f:	8b 06                	mov    (%esi),%eax
  802191:	89 04 24             	mov    %eax,(%esp)
  802194:	e8 e8 fc ff ff       	call   801e81 <dev_lookup>
  802199:	89 c3                	mov    %eax,%ebx
  80219b:	85 c0                	test   %eax,%eax
  80219d:	78 16                	js     8021b5 <fd_close+0x66>
		if (dev->dev_close)
  80219f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a2:	8b 40 10             	mov    0x10(%eax),%eax
  8021a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021aa:	85 c0                	test   %eax,%eax
  8021ac:	74 07                	je     8021b5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8021ae:	89 34 24             	mov    %esi,(%esp)
  8021b1:	ff d0                	call   *%eax
  8021b3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8021b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c0:	e8 49 f4 ff ff       	call   80160e <sys_page_unmap>
	return r;
}
  8021c5:	89 d8                	mov    %ebx,%eax
  8021c7:	83 c4 20             	add    $0x20,%esp
  8021ca:	5b                   	pop    %ebx
  8021cb:	5e                   	pop    %esi
  8021cc:	5d                   	pop    %ebp
  8021cd:	c3                   	ret    

008021ce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021db:	8b 45 08             	mov    0x8(%ebp),%eax
  8021de:	89 04 24             	mov    %eax,(%esp)
  8021e1:	e8 27 fc ff ff       	call   801e0d <fd_lookup>
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	78 13                	js     8021fd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8021ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021f1:	00 
  8021f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f5:	89 04 24             	mov    %eax,(%esp)
  8021f8:	e8 52 ff ff ff       	call   80214f <fd_close>
}
  8021fd:	c9                   	leave  
  8021fe:	c3                   	ret    

008021ff <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
  802202:	83 ec 18             	sub    $0x18,%esp
  802205:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802208:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80220b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802212:	00 
  802213:	8b 45 08             	mov    0x8(%ebp),%eax
  802216:	89 04 24             	mov    %eax,(%esp)
  802219:	e8 79 03 00 00       	call   802597 <open>
  80221e:	89 c3                	mov    %eax,%ebx
  802220:	85 c0                	test   %eax,%eax
  802222:	78 1b                	js     80223f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802224:	8b 45 0c             	mov    0xc(%ebp),%eax
  802227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80222b:	89 1c 24             	mov    %ebx,(%esp)
  80222e:	e8 b7 fc ff ff       	call   801eea <fstat>
  802233:	89 c6                	mov    %eax,%esi
	close(fd);
  802235:	89 1c 24             	mov    %ebx,(%esp)
  802238:	e8 91 ff ff ff       	call   8021ce <close>
  80223d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80223f:	89 d8                	mov    %ebx,%eax
  802241:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802244:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802247:	89 ec                	mov    %ebp,%esp
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    

0080224b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	53                   	push   %ebx
  80224f:	83 ec 14             	sub    $0x14,%esp
  802252:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  802257:	89 1c 24             	mov    %ebx,(%esp)
  80225a:	e8 6f ff ff ff       	call   8021ce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80225f:	83 c3 01             	add    $0x1,%ebx
  802262:	83 fb 20             	cmp    $0x20,%ebx
  802265:	75 f0                	jne    802257 <close_all+0xc>
		close(i);
}
  802267:	83 c4 14             	add    $0x14,%esp
  80226a:	5b                   	pop    %ebx
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    

0080226d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80226d:	55                   	push   %ebp
  80226e:	89 e5                	mov    %esp,%ebp
  802270:	83 ec 58             	sub    $0x58,%esp
  802273:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802276:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802279:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80227c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80227f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802282:	89 44 24 04          	mov    %eax,0x4(%esp)
  802286:	8b 45 08             	mov    0x8(%ebp),%eax
  802289:	89 04 24             	mov    %eax,(%esp)
  80228c:	e8 7c fb ff ff       	call   801e0d <fd_lookup>
  802291:	89 c3                	mov    %eax,%ebx
  802293:	85 c0                	test   %eax,%eax
  802295:	0f 88 e0 00 00 00    	js     80237b <dup+0x10e>
		return r;
	close(newfdnum);
  80229b:	89 3c 24             	mov    %edi,(%esp)
  80229e:	e8 2b ff ff ff       	call   8021ce <close>

	newfd = INDEX2FD(newfdnum);
  8022a3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8022a9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8022ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022af:	89 04 24             	mov    %eax,(%esp)
  8022b2:	e8 c9 fa ff ff       	call   801d80 <fd2data>
  8022b7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8022b9:	89 34 24             	mov    %esi,(%esp)
  8022bc:	e8 bf fa ff ff       	call   801d80 <fd2data>
  8022c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8022c4:	89 da                	mov    %ebx,%edx
  8022c6:	89 d8                	mov    %ebx,%eax
  8022c8:	c1 e8 16             	shr    $0x16,%eax
  8022cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8022d2:	a8 01                	test   $0x1,%al
  8022d4:	74 43                	je     802319 <dup+0xac>
  8022d6:	c1 ea 0c             	shr    $0xc,%edx
  8022d9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8022e0:	a8 01                	test   $0x1,%al
  8022e2:	74 35                	je     802319 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8022e4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8022eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8022f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8022f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802302:	00 
  802303:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80230e:	e8 67 f3 ff ff       	call   80167a <sys_page_map>
  802313:	89 c3                	mov    %eax,%ebx
  802315:	85 c0                	test   %eax,%eax
  802317:	78 3f                	js     802358 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80231c:	89 c2                	mov    %eax,%edx
  80231e:	c1 ea 0c             	shr    $0xc,%edx
  802321:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802328:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80232e:	89 54 24 10          	mov    %edx,0x10(%esp)
  802332:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802336:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80233d:	00 
  80233e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802342:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802349:	e8 2c f3 ff ff       	call   80167a <sys_page_map>
  80234e:	89 c3                	mov    %eax,%ebx
  802350:	85 c0                	test   %eax,%eax
  802352:	78 04                	js     802358 <dup+0xeb>
  802354:	89 fb                	mov    %edi,%ebx
  802356:	eb 23                	jmp    80237b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802358:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802363:	e8 a6 f2 ff ff       	call   80160e <sys_page_unmap>
	sys_page_unmap(0, nva);
  802368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80236b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802376:	e8 93 f2 ff ff       	call   80160e <sys_page_unmap>
	return r;
}
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802380:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802383:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802386:	89 ec                	mov    %ebp,%esp
  802388:	5d                   	pop    %ebp
  802389:	c3                   	ret    
	...

0080238c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	83 ec 18             	sub    $0x18,%esp
  802392:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802395:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802398:	89 c3                	mov    %eax,%ebx
  80239a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80239c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8023a3:	75 11                	jne    8023b6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8023a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8023ac:	e8 7f f8 ff ff       	call   801c30 <ipc_find_env>
  8023b1:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8023b6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8023bd:	00 
  8023be:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8023c5:	00 
  8023c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023ca:	a1 04 50 80 00       	mov    0x805004,%eax
  8023cf:	89 04 24             	mov    %eax,(%esp)
  8023d2:	e8 a4 f8 ff ff       	call   801c7b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8023d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023de:	00 
  8023df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ea:	e8 0a f9 ff ff       	call   801cf9 <ipc_recv>
}
  8023ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8023f2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8023f5:	89 ec                	mov    %ebp,%esp
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    

008023f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8023f9:	55                   	push   %ebp
  8023fa:	89 e5                	mov    %esp,%ebp
  8023fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8023ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802402:	8b 40 0c             	mov    0xc(%eax),%eax
  802405:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80240a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80240d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802412:	ba 00 00 00 00       	mov    $0x0,%edx
  802417:	b8 02 00 00 00       	mov    $0x2,%eax
  80241c:	e8 6b ff ff ff       	call   80238c <fsipc>
}
  802421:	c9                   	leave  
  802422:	c3                   	ret    

00802423 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802423:	55                   	push   %ebp
  802424:	89 e5                	mov    %esp,%ebp
  802426:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802429:	8b 45 08             	mov    0x8(%ebp),%eax
  80242c:	8b 40 0c             	mov    0xc(%eax),%eax
  80242f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802434:	ba 00 00 00 00       	mov    $0x0,%edx
  802439:	b8 06 00 00 00       	mov    $0x6,%eax
  80243e:	e8 49 ff ff ff       	call   80238c <fsipc>
}
  802443:	c9                   	leave  
  802444:	c3                   	ret    

00802445 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802445:	55                   	push   %ebp
  802446:	89 e5                	mov    %esp,%ebp
  802448:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80244b:	ba 00 00 00 00       	mov    $0x0,%edx
  802450:	b8 08 00 00 00       	mov    $0x8,%eax
  802455:	e8 32 ff ff ff       	call   80238c <fsipc>
}
  80245a:	c9                   	leave  
  80245b:	c3                   	ret    

0080245c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80245c:	55                   	push   %ebp
  80245d:	89 e5                	mov    %esp,%ebp
  80245f:	53                   	push   %ebx
  802460:	83 ec 14             	sub    $0x14,%esp
  802463:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802466:	8b 45 08             	mov    0x8(%ebp),%eax
  802469:	8b 40 0c             	mov    0xc(%eax),%eax
  80246c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802471:	ba 00 00 00 00       	mov    $0x0,%edx
  802476:	b8 05 00 00 00       	mov    $0x5,%eax
  80247b:	e8 0c ff ff ff       	call   80238c <fsipc>
  802480:	85 c0                	test   %eax,%eax
  802482:	78 2b                	js     8024af <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802484:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80248b:	00 
  80248c:	89 1c 24             	mov    %ebx,(%esp)
  80248f:	e8 26 e9 ff ff       	call   800dba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802494:	a1 80 60 80 00       	mov    0x806080,%eax
  802499:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80249f:	a1 84 60 80 00       	mov    0x806084,%eax
  8024a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8024aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8024af:	83 c4 14             	add    $0x14,%esp
  8024b2:	5b                   	pop    %ebx
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    

008024b5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	83 ec 18             	sub    $0x18,%esp
  8024bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8024be:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8024c3:	76 05                	jbe    8024ca <devfile_write+0x15>
  8024c5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  8024ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8024cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8024d0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  8024d6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  8024db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8024ed:	e8 b3 ea ff ff       	call   800fa5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  8024f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8024fc:	e8 8b fe ff ff       	call   80238c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802501:	c9                   	leave  
  802502:	c3                   	ret    

00802503 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802503:	55                   	push   %ebp
  802504:	89 e5                	mov    %esp,%ebp
  802506:	53                   	push   %ebx
  802507:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80250a:	8b 45 08             	mov    0x8(%ebp),%eax
  80250d:	8b 40 0c             	mov    0xc(%eax),%eax
  802510:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  802515:	8b 45 10             	mov    0x10(%ebp),%eax
  802518:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  80251d:	ba 00 00 00 00       	mov    $0x0,%edx
  802522:	b8 03 00 00 00       	mov    $0x3,%eax
  802527:	e8 60 fe ff ff       	call   80238c <fsipc>
  80252c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80252e:	85 c0                	test   %eax,%eax
  802530:	78 17                	js     802549 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802532:	89 44 24 08          	mov    %eax,0x8(%esp)
  802536:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80253d:	00 
  80253e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802541:	89 04 24             	mov    %eax,(%esp)
  802544:	e8 5c ea ff ff       	call   800fa5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802549:	89 d8                	mov    %ebx,%eax
  80254b:	83 c4 14             	add    $0x14,%esp
  80254e:	5b                   	pop    %ebx
  80254f:	5d                   	pop    %ebp
  802550:	c3                   	ret    

00802551 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802551:	55                   	push   %ebp
  802552:	89 e5                	mov    %esp,%ebp
  802554:	53                   	push   %ebx
  802555:	83 ec 14             	sub    $0x14,%esp
  802558:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80255b:	89 1c 24             	mov    %ebx,(%esp)
  80255e:	e8 0d e8 ff ff       	call   800d70 <strlen>
  802563:	89 c2                	mov    %eax,%edx
  802565:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80256a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802570:	7f 1f                	jg     802591 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802572:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802576:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80257d:	e8 38 e8 ff ff       	call   800dba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802582:	ba 00 00 00 00       	mov    $0x0,%edx
  802587:	b8 07 00 00 00       	mov    $0x7,%eax
  80258c:	e8 fb fd ff ff       	call   80238c <fsipc>
}
  802591:	83 c4 14             	add    $0x14,%esp
  802594:	5b                   	pop    %ebx
  802595:	5d                   	pop    %ebp
  802596:	c3                   	ret    

00802597 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802597:	55                   	push   %ebp
  802598:	89 e5                	mov    %esp,%ebp
  80259a:	83 ec 28             	sub    $0x28,%esp
  80259d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8025a0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8025a3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  8025a6:	89 34 24             	mov    %esi,(%esp)
  8025a9:	e8 c2 e7 ff ff       	call   800d70 <strlen>
  8025ae:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8025b3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025b8:	7f 6d                	jg     802627 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8025ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025bd:	89 04 24             	mov    %eax,(%esp)
  8025c0:	e8 d6 f7 ff ff       	call   801d9b <fd_alloc>
  8025c5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8025c7:	85 c0                	test   %eax,%eax
  8025c9:	78 5c                	js     802627 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8025cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ce:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8025d3:	89 34 24             	mov    %esi,(%esp)
  8025d6:	e8 95 e7 ff ff       	call   800d70 <strlen>
  8025db:	83 c0 01             	add    $0x1,%eax
  8025de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025e6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8025ed:	e8 b3 e9 ff ff       	call   800fa5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8025f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fa:	e8 8d fd ff ff       	call   80238c <fsipc>
  8025ff:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802601:	85 c0                	test   %eax,%eax
  802603:	79 15                	jns    80261a <open+0x83>
             fd_close(fd,0);
  802605:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80260c:	00 
  80260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802610:	89 04 24             	mov    %eax,(%esp)
  802613:	e8 37 fb ff ff       	call   80214f <fd_close>
             return r;
  802618:	eb 0d                	jmp    802627 <open+0x90>
        }
        return fd2num(fd);
  80261a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80261d:	89 04 24             	mov    %eax,(%esp)
  802620:	e8 4b f7 ff ff       	call   801d70 <fd2num>
  802625:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802627:	89 d8                	mov    %ebx,%eax
  802629:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80262c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80262f:	89 ec                	mov    %ebp,%esp
  802631:	5d                   	pop    %ebp
  802632:	c3                   	ret    
	...

00802640 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802640:	55                   	push   %ebp
  802641:	89 e5                	mov    %esp,%ebp
  802643:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802646:	c7 44 24 04 b8 34 80 	movl   $0x8034b8,0x4(%esp)
  80264d:	00 
  80264e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802651:	89 04 24             	mov    %eax,(%esp)
  802654:	e8 61 e7 ff ff       	call   800dba <strcpy>
	return 0;
}
  802659:	b8 00 00 00 00       	mov    $0x0,%eax
  80265e:	c9                   	leave  
  80265f:	c3                   	ret    

00802660 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802660:	55                   	push   %ebp
  802661:	89 e5                	mov    %esp,%ebp
  802663:	53                   	push   %ebx
  802664:	83 ec 14             	sub    $0x14,%esp
  802667:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80266a:	89 1c 24             	mov    %ebx,(%esp)
  80266d:	e8 46 05 00 00       	call   802bb8 <pageref>
  802672:	89 c2                	mov    %eax,%edx
  802674:	b8 00 00 00 00       	mov    $0x0,%eax
  802679:	83 fa 01             	cmp    $0x1,%edx
  80267c:	75 0b                	jne    802689 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80267e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802681:	89 04 24             	mov    %eax,(%esp)
  802684:	e8 b9 02 00 00       	call   802942 <nsipc_close>
	else
		return 0;
}
  802689:	83 c4 14             	add    $0x14,%esp
  80268c:	5b                   	pop    %ebx
  80268d:	5d                   	pop    %ebp
  80268e:	c3                   	ret    

0080268f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80268f:	55                   	push   %ebp
  802690:	89 e5                	mov    %esp,%ebp
  802692:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802695:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80269c:	00 
  80269d:	8b 45 10             	mov    0x10(%ebp),%eax
  8026a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8026b1:	89 04 24             	mov    %eax,(%esp)
  8026b4:	e8 c5 02 00 00       	call   80297e <nsipc_send>
}
  8026b9:	c9                   	leave  
  8026ba:	c3                   	ret    

008026bb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8026bb:	55                   	push   %ebp
  8026bc:	89 e5                	mov    %esp,%ebp
  8026be:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8026c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8026c8:	00 
  8026c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8026cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026da:	8b 40 0c             	mov    0xc(%eax),%eax
  8026dd:	89 04 24             	mov    %eax,(%esp)
  8026e0:	e8 0c 03 00 00       	call   8029f1 <nsipc_recv>
}
  8026e5:	c9                   	leave  
  8026e6:	c3                   	ret    

008026e7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8026e7:	55                   	push   %ebp
  8026e8:	89 e5                	mov    %esp,%ebp
  8026ea:	56                   	push   %esi
  8026eb:	53                   	push   %ebx
  8026ec:	83 ec 20             	sub    $0x20,%esp
  8026ef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8026f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026f4:	89 04 24             	mov    %eax,(%esp)
  8026f7:	e8 9f f6 ff ff       	call   801d9b <fd_alloc>
  8026fc:	89 c3                	mov    %eax,%ebx
  8026fe:	85 c0                	test   %eax,%eax
  802700:	78 21                	js     802723 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802702:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802709:	00 
  80270a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802711:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802718:	e8 cb ef ff ff       	call   8016e8 <sys_page_alloc>
  80271d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80271f:	85 c0                	test   %eax,%eax
  802721:	79 0a                	jns    80272d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802723:	89 34 24             	mov    %esi,(%esp)
  802726:	e8 17 02 00 00       	call   802942 <nsipc_close>
		return r;
  80272b:	eb 28                	jmp    802755 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80272d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802736:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80273b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802745:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80274b:	89 04 24             	mov    %eax,(%esp)
  80274e:	e8 1d f6 ff ff       	call   801d70 <fd2num>
  802753:	89 c3                	mov    %eax,%ebx
}
  802755:	89 d8                	mov    %ebx,%eax
  802757:	83 c4 20             	add    $0x20,%esp
  80275a:	5b                   	pop    %ebx
  80275b:	5e                   	pop    %esi
  80275c:	5d                   	pop    %ebp
  80275d:	c3                   	ret    

0080275e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80275e:	55                   	push   %ebp
  80275f:	89 e5                	mov    %esp,%ebp
  802761:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802764:	8b 45 10             	mov    0x10(%ebp),%eax
  802767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80276b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80276e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802772:	8b 45 08             	mov    0x8(%ebp),%eax
  802775:	89 04 24             	mov    %eax,(%esp)
  802778:	e8 79 01 00 00       	call   8028f6 <nsipc_socket>
  80277d:	85 c0                	test   %eax,%eax
  80277f:	78 05                	js     802786 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802781:	e8 61 ff ff ff       	call   8026e7 <alloc_sockfd>
}
  802786:	c9                   	leave  
  802787:	c3                   	ret    

00802788 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802788:	55                   	push   %ebp
  802789:	89 e5                	mov    %esp,%ebp
  80278b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80278e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802791:	89 54 24 04          	mov    %edx,0x4(%esp)
  802795:	89 04 24             	mov    %eax,(%esp)
  802798:	e8 70 f6 ff ff       	call   801e0d <fd_lookup>
  80279d:	85 c0                	test   %eax,%eax
  80279f:	78 15                	js     8027b6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8027a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027a4:	8b 0a                	mov    (%edx),%ecx
  8027a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8027ab:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8027b1:	75 03                	jne    8027b6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8027b3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8027b6:	c9                   	leave  
  8027b7:	c3                   	ret    

008027b8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8027b8:	55                   	push   %ebp
  8027b9:	89 e5                	mov    %esp,%ebp
  8027bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027be:	8b 45 08             	mov    0x8(%ebp),%eax
  8027c1:	e8 c2 ff ff ff       	call   802788 <fd2sockid>
  8027c6:	85 c0                	test   %eax,%eax
  8027c8:	78 0f                	js     8027d9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8027ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027d1:	89 04 24             	mov    %eax,(%esp)
  8027d4:	e8 47 01 00 00       	call   802920 <nsipc_listen>
}
  8027d9:	c9                   	leave  
  8027da:	c3                   	ret    

008027db <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8027db:	55                   	push   %ebp
  8027dc:	89 e5                	mov    %esp,%ebp
  8027de:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8027e4:	e8 9f ff ff ff       	call   802788 <fd2sockid>
  8027e9:	85 c0                	test   %eax,%eax
  8027eb:	78 16                	js     802803 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8027ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8027f0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8027f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027fb:	89 04 24             	mov    %eax,(%esp)
  8027fe:	e8 6e 02 00 00       	call   802a71 <nsipc_connect>
}
  802803:	c9                   	leave  
  802804:	c3                   	ret    

00802805 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802805:	55                   	push   %ebp
  802806:	89 e5                	mov    %esp,%ebp
  802808:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80280b:	8b 45 08             	mov    0x8(%ebp),%eax
  80280e:	e8 75 ff ff ff       	call   802788 <fd2sockid>
  802813:	85 c0                	test   %eax,%eax
  802815:	78 0f                	js     802826 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80281a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80281e:	89 04 24             	mov    %eax,(%esp)
  802821:	e8 36 01 00 00       	call   80295c <nsipc_shutdown>
}
  802826:	c9                   	leave  
  802827:	c3                   	ret    

00802828 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802828:	55                   	push   %ebp
  802829:	89 e5                	mov    %esp,%ebp
  80282b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80282e:	8b 45 08             	mov    0x8(%ebp),%eax
  802831:	e8 52 ff ff ff       	call   802788 <fd2sockid>
  802836:	85 c0                	test   %eax,%eax
  802838:	78 16                	js     802850 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80283a:	8b 55 10             	mov    0x10(%ebp),%edx
  80283d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802841:	8b 55 0c             	mov    0xc(%ebp),%edx
  802844:	89 54 24 04          	mov    %edx,0x4(%esp)
  802848:	89 04 24             	mov    %eax,(%esp)
  80284b:	e8 60 02 00 00       	call   802ab0 <nsipc_bind>
}
  802850:	c9                   	leave  
  802851:	c3                   	ret    

00802852 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802852:	55                   	push   %ebp
  802853:	89 e5                	mov    %esp,%ebp
  802855:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802858:	8b 45 08             	mov    0x8(%ebp),%eax
  80285b:	e8 28 ff ff ff       	call   802788 <fd2sockid>
  802860:	85 c0                	test   %eax,%eax
  802862:	78 1f                	js     802883 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802864:	8b 55 10             	mov    0x10(%ebp),%edx
  802867:	89 54 24 08          	mov    %edx,0x8(%esp)
  80286b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80286e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802872:	89 04 24             	mov    %eax,(%esp)
  802875:	e8 75 02 00 00       	call   802aef <nsipc_accept>
  80287a:	85 c0                	test   %eax,%eax
  80287c:	78 05                	js     802883 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80287e:	e8 64 fe ff ff       	call   8026e7 <alloc_sockfd>
}
  802883:	c9                   	leave  
  802884:	c3                   	ret    
	...

00802890 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802890:	55                   	push   %ebp
  802891:	89 e5                	mov    %esp,%ebp
  802893:	53                   	push   %ebx
  802894:	83 ec 14             	sub    $0x14,%esp
  802897:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802899:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  8028a0:	75 11                	jne    8028b3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8028a2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8028a9:	e8 82 f3 ff ff       	call   801c30 <ipc_find_env>
  8028ae:	a3 08 50 80 00       	mov    %eax,0x805008
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8028b3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8028ba:	00 
  8028bb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8028c2:	00 
  8028c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8028c7:	a1 08 50 80 00       	mov    0x805008,%eax
  8028cc:	89 04 24             	mov    %eax,(%esp)
  8028cf:	e8 a7 f3 ff ff       	call   801c7b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8028d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8028db:	00 
  8028dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8028e3:	00 
  8028e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028eb:	e8 09 f4 ff ff       	call   801cf9 <ipc_recv>
}
  8028f0:	83 c4 14             	add    $0x14,%esp
  8028f3:	5b                   	pop    %ebx
  8028f4:	5d                   	pop    %ebp
  8028f5:	c3                   	ret    

008028f6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8028f6:	55                   	push   %ebp
  8028f7:	89 e5                	mov    %esp,%ebp
  8028f9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8028fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8028ff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802904:	8b 45 0c             	mov    0xc(%ebp),%eax
  802907:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80290c:	8b 45 10             	mov    0x10(%ebp),%eax
  80290f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802914:	b8 09 00 00 00       	mov    $0x9,%eax
  802919:	e8 72 ff ff ff       	call   802890 <nsipc>
}
  80291e:	c9                   	leave  
  80291f:	c3                   	ret    

00802920 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802920:	55                   	push   %ebp
  802921:	89 e5                	mov    %esp,%ebp
  802923:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802926:	8b 45 08             	mov    0x8(%ebp),%eax
  802929:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80292e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802931:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802936:	b8 06 00 00 00       	mov    $0x6,%eax
  80293b:	e8 50 ff ff ff       	call   802890 <nsipc>
}
  802940:	c9                   	leave  
  802941:	c3                   	ret    

00802942 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802942:	55                   	push   %ebp
  802943:	89 e5                	mov    %esp,%ebp
  802945:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802948:	8b 45 08             	mov    0x8(%ebp),%eax
  80294b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802950:	b8 04 00 00 00       	mov    $0x4,%eax
  802955:	e8 36 ff ff ff       	call   802890 <nsipc>
}
  80295a:	c9                   	leave  
  80295b:	c3                   	ret    

0080295c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80295c:	55                   	push   %ebp
  80295d:	89 e5                	mov    %esp,%ebp
  80295f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802962:	8b 45 08             	mov    0x8(%ebp),%eax
  802965:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80296a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80296d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802972:	b8 03 00 00 00       	mov    $0x3,%eax
  802977:	e8 14 ff ff ff       	call   802890 <nsipc>
}
  80297c:	c9                   	leave  
  80297d:	c3                   	ret    

0080297e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80297e:	55                   	push   %ebp
  80297f:	89 e5                	mov    %esp,%ebp
  802981:	53                   	push   %ebx
  802982:	83 ec 14             	sub    $0x14,%esp
  802985:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802988:	8b 45 08             	mov    0x8(%ebp),%eax
  80298b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802990:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802996:	7e 24                	jle    8029bc <nsipc_send+0x3e>
  802998:	c7 44 24 0c c4 34 80 	movl   $0x8034c4,0xc(%esp)
  80299f:	00 
  8029a0:	c7 44 24 08 d0 34 80 	movl   $0x8034d0,0x8(%esp)
  8029a7:	00 
  8029a8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8029af:	00 
  8029b0:	c7 04 24 e5 34 80 00 	movl   $0x8034e5,(%esp)
  8029b7:	e8 1c da ff ff       	call   8003d8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8029bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029c7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8029ce:	e8 d2 e5 ff ff       	call   800fa5 <memmove>
	nsipcbuf.send.req_size = size;
  8029d3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8029d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8029dc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8029e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8029e6:	e8 a5 fe ff ff       	call   802890 <nsipc>
}
  8029eb:	83 c4 14             	add    $0x14,%esp
  8029ee:	5b                   	pop    %ebx
  8029ef:	5d                   	pop    %ebp
  8029f0:	c3                   	ret    

008029f1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8029f1:	55                   	push   %ebp
  8029f2:	89 e5                	mov    %esp,%ebp
  8029f4:	56                   	push   %esi
  8029f5:	53                   	push   %ebx
  8029f6:	83 ec 10             	sub    $0x10,%esp
  8029f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8029fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8029ff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802a04:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  802a0d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802a12:	b8 07 00 00 00       	mov    $0x7,%eax
  802a17:	e8 74 fe ff ff       	call   802890 <nsipc>
  802a1c:	89 c3                	mov    %eax,%ebx
  802a1e:	85 c0                	test   %eax,%eax
  802a20:	78 46                	js     802a68 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802a22:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802a27:	7f 04                	jg     802a2d <nsipc_recv+0x3c>
  802a29:	39 c6                	cmp    %eax,%esi
  802a2b:	7d 24                	jge    802a51 <nsipc_recv+0x60>
  802a2d:	c7 44 24 0c f1 34 80 	movl   $0x8034f1,0xc(%esp)
  802a34:	00 
  802a35:	c7 44 24 08 d0 34 80 	movl   $0x8034d0,0x8(%esp)
  802a3c:	00 
  802a3d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802a44:	00 
  802a45:	c7 04 24 e5 34 80 00 	movl   $0x8034e5,(%esp)
  802a4c:	e8 87 d9 ff ff       	call   8003d8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802a51:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a55:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802a5c:	00 
  802a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a60:	89 04 24             	mov    %eax,(%esp)
  802a63:	e8 3d e5 ff ff       	call   800fa5 <memmove>
	}

	return r;
}
  802a68:	89 d8                	mov    %ebx,%eax
  802a6a:	83 c4 10             	add    $0x10,%esp
  802a6d:	5b                   	pop    %ebx
  802a6e:	5e                   	pop    %esi
  802a6f:	5d                   	pop    %ebp
  802a70:	c3                   	ret    

00802a71 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802a71:	55                   	push   %ebp
  802a72:	89 e5                	mov    %esp,%ebp
  802a74:	53                   	push   %ebx
  802a75:	83 ec 14             	sub    $0x14,%esp
  802a78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  802a7e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802a83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a8e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802a95:	e8 0b e5 ff ff       	call   800fa5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802a9a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802aa0:	b8 05 00 00 00       	mov    $0x5,%eax
  802aa5:	e8 e6 fd ff ff       	call   802890 <nsipc>
}
  802aaa:	83 c4 14             	add    $0x14,%esp
  802aad:	5b                   	pop    %ebx
  802aae:	5d                   	pop    %ebp
  802aaf:	c3                   	ret    

00802ab0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802ab0:	55                   	push   %ebp
  802ab1:	89 e5                	mov    %esp,%ebp
  802ab3:	53                   	push   %ebx
  802ab4:	83 ec 14             	sub    $0x14,%esp
  802ab7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802aba:	8b 45 08             	mov    0x8(%ebp),%eax
  802abd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802ac2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802acd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802ad4:	e8 cc e4 ff ff       	call   800fa5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802ad9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802adf:	b8 02 00 00 00       	mov    $0x2,%eax
  802ae4:	e8 a7 fd ff ff       	call   802890 <nsipc>
}
  802ae9:	83 c4 14             	add    $0x14,%esp
  802aec:	5b                   	pop    %ebx
  802aed:	5d                   	pop    %ebp
  802aee:	c3                   	ret    

00802aef <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802aef:	55                   	push   %ebp
  802af0:	89 e5                	mov    %esp,%ebp
  802af2:	83 ec 18             	sub    $0x18,%esp
  802af5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802af8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  802afb:	8b 45 08             	mov    0x8(%ebp),%eax
  802afe:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802b03:	b8 01 00 00 00       	mov    $0x1,%eax
  802b08:	e8 83 fd ff ff       	call   802890 <nsipc>
  802b0d:	89 c3                	mov    %eax,%ebx
  802b0f:	85 c0                	test   %eax,%eax
  802b11:	78 25                	js     802b38 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802b13:	be 10 70 80 00       	mov    $0x807010,%esi
  802b18:	8b 06                	mov    (%esi),%eax
  802b1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b1e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802b25:	00 
  802b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b29:	89 04 24             	mov    %eax,(%esp)
  802b2c:	e8 74 e4 ff ff       	call   800fa5 <memmove>
		*addrlen = ret->ret_addrlen;
  802b31:	8b 16                	mov    (%esi),%edx
  802b33:	8b 45 10             	mov    0x10(%ebp),%eax
  802b36:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802b38:	89 d8                	mov    %ebx,%eax
  802b3a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802b3d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802b40:	89 ec                	mov    %ebp,%esp
  802b42:	5d                   	pop    %ebp
  802b43:	c3                   	ret    

00802b44 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802b44:	55                   	push   %ebp
  802b45:	89 e5                	mov    %esp,%ebp
  802b47:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802b4a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802b51:	75 30                	jne    802b83 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  802b53:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802b5a:	00 
  802b5b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802b62:	ee 
  802b63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b6a:	e8 79 eb ff ff       	call   8016e8 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802b6f:	c7 44 24 04 90 2b 80 	movl   $0x802b90,0x4(%esp)
  802b76:	00 
  802b77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b7e:	e8 47 e9 ff ff       	call   8014ca <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b83:	8b 45 08             	mov    0x8(%ebp),%eax
  802b86:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802b8b:	c9                   	leave  
  802b8c:	c3                   	ret    
  802b8d:	00 00                	add    %al,(%eax)
	...

00802b90 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b90:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b91:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802b96:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b98:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  802b9b:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  802b9f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  802ba3:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  802ba6:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802ba8:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  802bac:	83 c4 08             	add    $0x8,%esp
        popal
  802baf:	61                   	popa   
        addl $0x4,%esp
  802bb0:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  802bb3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802bb4:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802bb5:	c3                   	ret    
	...

00802bb8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802bb8:	55                   	push   %ebp
  802bb9:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  802bbe:	89 c2                	mov    %eax,%edx
  802bc0:	c1 ea 16             	shr    $0x16,%edx
  802bc3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802bca:	f6 c2 01             	test   $0x1,%dl
  802bcd:	74 20                	je     802bef <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802bcf:	c1 e8 0c             	shr    $0xc,%eax
  802bd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802bd9:	a8 01                	test   $0x1,%al
  802bdb:	74 12                	je     802bef <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802bdd:	c1 e8 0c             	shr    $0xc,%eax
  802be0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802be5:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802bea:	0f b7 c0             	movzwl %ax,%eax
  802bed:	eb 05                	jmp    802bf4 <pageref+0x3c>
  802bef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bf4:	5d                   	pop    %ebp
  802bf5:	c3                   	ret    
	...

00802c00 <__udivdi3>:
  802c00:	55                   	push   %ebp
  802c01:	89 e5                	mov    %esp,%ebp
  802c03:	57                   	push   %edi
  802c04:	56                   	push   %esi
  802c05:	83 ec 10             	sub    $0x10,%esp
  802c08:	8b 45 14             	mov    0x14(%ebp),%eax
  802c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  802c0e:	8b 75 10             	mov    0x10(%ebp),%esi
  802c11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802c14:	85 c0                	test   %eax,%eax
  802c16:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802c19:	75 35                	jne    802c50 <__udivdi3+0x50>
  802c1b:	39 fe                	cmp    %edi,%esi
  802c1d:	77 61                	ja     802c80 <__udivdi3+0x80>
  802c1f:	85 f6                	test   %esi,%esi
  802c21:	75 0b                	jne    802c2e <__udivdi3+0x2e>
  802c23:	b8 01 00 00 00       	mov    $0x1,%eax
  802c28:	31 d2                	xor    %edx,%edx
  802c2a:	f7 f6                	div    %esi
  802c2c:	89 c6                	mov    %eax,%esi
  802c2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802c31:	31 d2                	xor    %edx,%edx
  802c33:	89 f8                	mov    %edi,%eax
  802c35:	f7 f6                	div    %esi
  802c37:	89 c7                	mov    %eax,%edi
  802c39:	89 c8                	mov    %ecx,%eax
  802c3b:	f7 f6                	div    %esi
  802c3d:	89 c1                	mov    %eax,%ecx
  802c3f:	89 fa                	mov    %edi,%edx
  802c41:	89 c8                	mov    %ecx,%eax
  802c43:	83 c4 10             	add    $0x10,%esp
  802c46:	5e                   	pop    %esi
  802c47:	5f                   	pop    %edi
  802c48:	5d                   	pop    %ebp
  802c49:	c3                   	ret    
  802c4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c50:	39 f8                	cmp    %edi,%eax
  802c52:	77 1c                	ja     802c70 <__udivdi3+0x70>
  802c54:	0f bd d0             	bsr    %eax,%edx
  802c57:	83 f2 1f             	xor    $0x1f,%edx
  802c5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802c5d:	75 39                	jne    802c98 <__udivdi3+0x98>
  802c5f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802c62:	0f 86 a0 00 00 00    	jbe    802d08 <__udivdi3+0x108>
  802c68:	39 f8                	cmp    %edi,%eax
  802c6a:	0f 82 98 00 00 00    	jb     802d08 <__udivdi3+0x108>
  802c70:	31 ff                	xor    %edi,%edi
  802c72:	31 c9                	xor    %ecx,%ecx
  802c74:	89 c8                	mov    %ecx,%eax
  802c76:	89 fa                	mov    %edi,%edx
  802c78:	83 c4 10             	add    $0x10,%esp
  802c7b:	5e                   	pop    %esi
  802c7c:	5f                   	pop    %edi
  802c7d:	5d                   	pop    %ebp
  802c7e:	c3                   	ret    
  802c7f:	90                   	nop
  802c80:	89 d1                	mov    %edx,%ecx
  802c82:	89 fa                	mov    %edi,%edx
  802c84:	89 c8                	mov    %ecx,%eax
  802c86:	31 ff                	xor    %edi,%edi
  802c88:	f7 f6                	div    %esi
  802c8a:	89 c1                	mov    %eax,%ecx
  802c8c:	89 fa                	mov    %edi,%edx
  802c8e:	89 c8                	mov    %ecx,%eax
  802c90:	83 c4 10             	add    $0x10,%esp
  802c93:	5e                   	pop    %esi
  802c94:	5f                   	pop    %edi
  802c95:	5d                   	pop    %ebp
  802c96:	c3                   	ret    
  802c97:	90                   	nop
  802c98:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802c9c:	89 f2                	mov    %esi,%edx
  802c9e:	d3 e0                	shl    %cl,%eax
  802ca0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802ca3:	b8 20 00 00 00       	mov    $0x20,%eax
  802ca8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802cab:	89 c1                	mov    %eax,%ecx
  802cad:	d3 ea                	shr    %cl,%edx
  802caf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802cb3:	0b 55 ec             	or     -0x14(%ebp),%edx
  802cb6:	d3 e6                	shl    %cl,%esi
  802cb8:	89 c1                	mov    %eax,%ecx
  802cba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802cbd:	89 fe                	mov    %edi,%esi
  802cbf:	d3 ee                	shr    %cl,%esi
  802cc1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802cc5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802cc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ccb:	d3 e7                	shl    %cl,%edi
  802ccd:	89 c1                	mov    %eax,%ecx
  802ccf:	d3 ea                	shr    %cl,%edx
  802cd1:	09 d7                	or     %edx,%edi
  802cd3:	89 f2                	mov    %esi,%edx
  802cd5:	89 f8                	mov    %edi,%eax
  802cd7:	f7 75 ec             	divl   -0x14(%ebp)
  802cda:	89 d6                	mov    %edx,%esi
  802cdc:	89 c7                	mov    %eax,%edi
  802cde:	f7 65 e8             	mull   -0x18(%ebp)
  802ce1:	39 d6                	cmp    %edx,%esi
  802ce3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802ce6:	72 30                	jb     802d18 <__udivdi3+0x118>
  802ce8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ceb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802cef:	d3 e2                	shl    %cl,%edx
  802cf1:	39 c2                	cmp    %eax,%edx
  802cf3:	73 05                	jae    802cfa <__udivdi3+0xfa>
  802cf5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802cf8:	74 1e                	je     802d18 <__udivdi3+0x118>
  802cfa:	89 f9                	mov    %edi,%ecx
  802cfc:	31 ff                	xor    %edi,%edi
  802cfe:	e9 71 ff ff ff       	jmp    802c74 <__udivdi3+0x74>
  802d03:	90                   	nop
  802d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d08:	31 ff                	xor    %edi,%edi
  802d0a:	b9 01 00 00 00       	mov    $0x1,%ecx
  802d0f:	e9 60 ff ff ff       	jmp    802c74 <__udivdi3+0x74>
  802d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d18:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802d1b:	31 ff                	xor    %edi,%edi
  802d1d:	89 c8                	mov    %ecx,%eax
  802d1f:	89 fa                	mov    %edi,%edx
  802d21:	83 c4 10             	add    $0x10,%esp
  802d24:	5e                   	pop    %esi
  802d25:	5f                   	pop    %edi
  802d26:	5d                   	pop    %ebp
  802d27:	c3                   	ret    
	...

00802d30 <__umoddi3>:
  802d30:	55                   	push   %ebp
  802d31:	89 e5                	mov    %esp,%ebp
  802d33:	57                   	push   %edi
  802d34:	56                   	push   %esi
  802d35:	83 ec 20             	sub    $0x20,%esp
  802d38:	8b 55 14             	mov    0x14(%ebp),%edx
  802d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d3e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802d41:	8b 75 0c             	mov    0xc(%ebp),%esi
  802d44:	85 d2                	test   %edx,%edx
  802d46:	89 c8                	mov    %ecx,%eax
  802d48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802d4b:	75 13                	jne    802d60 <__umoddi3+0x30>
  802d4d:	39 f7                	cmp    %esi,%edi
  802d4f:	76 3f                	jbe    802d90 <__umoddi3+0x60>
  802d51:	89 f2                	mov    %esi,%edx
  802d53:	f7 f7                	div    %edi
  802d55:	89 d0                	mov    %edx,%eax
  802d57:	31 d2                	xor    %edx,%edx
  802d59:	83 c4 20             	add    $0x20,%esp
  802d5c:	5e                   	pop    %esi
  802d5d:	5f                   	pop    %edi
  802d5e:	5d                   	pop    %ebp
  802d5f:	c3                   	ret    
  802d60:	39 f2                	cmp    %esi,%edx
  802d62:	77 4c                	ja     802db0 <__umoddi3+0x80>
  802d64:	0f bd ca             	bsr    %edx,%ecx
  802d67:	83 f1 1f             	xor    $0x1f,%ecx
  802d6a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802d6d:	75 51                	jne    802dc0 <__umoddi3+0x90>
  802d6f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802d72:	0f 87 e0 00 00 00    	ja     802e58 <__umoddi3+0x128>
  802d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d7b:	29 f8                	sub    %edi,%eax
  802d7d:	19 d6                	sbb    %edx,%esi
  802d7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d85:	89 f2                	mov    %esi,%edx
  802d87:	83 c4 20             	add    $0x20,%esp
  802d8a:	5e                   	pop    %esi
  802d8b:	5f                   	pop    %edi
  802d8c:	5d                   	pop    %ebp
  802d8d:	c3                   	ret    
  802d8e:	66 90                	xchg   %ax,%ax
  802d90:	85 ff                	test   %edi,%edi
  802d92:	75 0b                	jne    802d9f <__umoddi3+0x6f>
  802d94:	b8 01 00 00 00       	mov    $0x1,%eax
  802d99:	31 d2                	xor    %edx,%edx
  802d9b:	f7 f7                	div    %edi
  802d9d:	89 c7                	mov    %eax,%edi
  802d9f:	89 f0                	mov    %esi,%eax
  802da1:	31 d2                	xor    %edx,%edx
  802da3:	f7 f7                	div    %edi
  802da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802da8:	f7 f7                	div    %edi
  802daa:	eb a9                	jmp    802d55 <__umoddi3+0x25>
  802dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802db0:	89 c8                	mov    %ecx,%eax
  802db2:	89 f2                	mov    %esi,%edx
  802db4:	83 c4 20             	add    $0x20,%esp
  802db7:	5e                   	pop    %esi
  802db8:	5f                   	pop    %edi
  802db9:	5d                   	pop    %ebp
  802dba:	c3                   	ret    
  802dbb:	90                   	nop
  802dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802dc0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802dc4:	d3 e2                	shl    %cl,%edx
  802dc6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802dc9:	ba 20 00 00 00       	mov    $0x20,%edx
  802dce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802dd1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802dd4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802dd8:	89 fa                	mov    %edi,%edx
  802dda:	d3 ea                	shr    %cl,%edx
  802ddc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802de0:	0b 55 f4             	or     -0xc(%ebp),%edx
  802de3:	d3 e7                	shl    %cl,%edi
  802de5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802de9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802dec:	89 f2                	mov    %esi,%edx
  802dee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802df1:	89 c7                	mov    %eax,%edi
  802df3:	d3 ea                	shr    %cl,%edx
  802df5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802df9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802dfc:	89 c2                	mov    %eax,%edx
  802dfe:	d3 e6                	shl    %cl,%esi
  802e00:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802e04:	d3 ea                	shr    %cl,%edx
  802e06:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802e0a:	09 d6                	or     %edx,%esi
  802e0c:	89 f0                	mov    %esi,%eax
  802e0e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802e11:	d3 e7                	shl    %cl,%edi
  802e13:	89 f2                	mov    %esi,%edx
  802e15:	f7 75 f4             	divl   -0xc(%ebp)
  802e18:	89 d6                	mov    %edx,%esi
  802e1a:	f7 65 e8             	mull   -0x18(%ebp)
  802e1d:	39 d6                	cmp    %edx,%esi
  802e1f:	72 2b                	jb     802e4c <__umoddi3+0x11c>
  802e21:	39 c7                	cmp    %eax,%edi
  802e23:	72 23                	jb     802e48 <__umoddi3+0x118>
  802e25:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802e29:	29 c7                	sub    %eax,%edi
  802e2b:	19 d6                	sbb    %edx,%esi
  802e2d:	89 f0                	mov    %esi,%eax
  802e2f:	89 f2                	mov    %esi,%edx
  802e31:	d3 ef                	shr    %cl,%edi
  802e33:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802e37:	d3 e0                	shl    %cl,%eax
  802e39:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802e3d:	09 f8                	or     %edi,%eax
  802e3f:	d3 ea                	shr    %cl,%edx
  802e41:	83 c4 20             	add    $0x20,%esp
  802e44:	5e                   	pop    %esi
  802e45:	5f                   	pop    %edi
  802e46:	5d                   	pop    %ebp
  802e47:	c3                   	ret    
  802e48:	39 d6                	cmp    %edx,%esi
  802e4a:	75 d9                	jne    802e25 <__umoddi3+0xf5>
  802e4c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802e4f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802e52:	eb d1                	jmp    802e25 <__umoddi3+0xf5>
  802e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e58:	39 f2                	cmp    %esi,%edx
  802e5a:	0f 82 18 ff ff ff    	jb     802d78 <__umoddi3+0x48>
  802e60:	e9 1d ff ff ff       	jmp    802d82 <__umoddi3+0x52>
