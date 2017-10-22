
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 27 06 00 00       	call   800658 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	81 ec ac 00 00 00    	sub    $0xac,%esp
	envid_t ns_envid = sys_getenvid();
  80004c:	e8 76 1a 00 00       	call   801ac7 <sys_getenvid>
  800051:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800053:	c7 05 00 40 80 00 80 	movl   $0x803480,0x804000
  80005a:	34 80 00 

	output_envid = fork();
  80005d:	e8 34 1b 00 00       	call   801b96 <fork>
  800062:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800067:	85 c0                	test   %eax,%eax
  800069:	79 1c                	jns    800087 <umain+0x47>
		panic("error forking");
  80006b:	c7 44 24 08 8a 34 80 	movl   $0x80348a,0x8(%esp)
  800072:	00 
  800073:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80007a:	00 
  80007b:	c7 04 24 98 34 80 00 	movl   $0x803498,(%esp)
  800082:	e8 41 06 00 00       	call   8006c8 <_panic>
	else if (output_envid == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 0d                	jne    800098 <umain+0x58>
		output(ns_envid);
  80008b:	89 1c 24             	mov    %ebx,(%esp)
  80008e:	e8 55 05 00 00       	call   8005e8 <output>
		return;
  800093:	e9 ba 03 00 00       	jmp    800452 <umain+0x412>
	}

	input_envid = fork();
  800098:	e8 f9 1a 00 00       	call   801b96 <fork>
  80009d:	a3 04 50 80 00       	mov    %eax,0x805004
	if (input_envid < 0)
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	79 1c                	jns    8000c2 <umain+0x82>
		panic("error forking");
  8000a6:	c7 44 24 08 8a 34 80 	movl   $0x80348a,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 98 34 80 00 	movl   $0x803498,(%esp)
  8000bd:	e8 06 06 00 00       	call   8006c8 <_panic>
	else if (input_envid == 0) {
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	75 0f                	jne    8000d5 <umain+0x95>
		input(ns_envid);
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	e8 5a 04 00 00       	call   800528 <input>
  8000ce:	66 90                	xchg   %ax,%ax
  8000d0:	e9 7d 03 00 00       	jmp    800452 <umain+0x412>
		return;
	}

	cprintf("Sending ARP announcement...\n");
  8000d5:	c7 04 24 a8 34 80 00 	movl   $0x8034a8,(%esp)
  8000dc:	e8 a0 06 00 00       	call   800781 <cprintf>
	// for the gateway IP.

	//uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};

        uint8_t mac[6];
        sys_get_mac(mac);
  8000e1:	8d 45 90             	lea    -0x70(%ebp),%eax
  8000e4:	89 04 24             	mov    %eax,(%esp)
  8000e7:	e8 2f 14 00 00       	call   80151b <sys_get_mac>

	uint32_t myip = inet_addr(IP);
  8000ec:	c7 04 24 c5 34 80 00 	movl   $0x8034c5,(%esp)
  8000f3:	e8 e0 30 00 00       	call   8031d8 <inet_addr>
  8000f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000fb:	c7 04 24 cf 34 80 00 	movl   $0x8034cf,(%esp)
  800102:	e8 d1 30 00 00       	call   8031d8 <inet_addr>
  800107:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  80010a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800111:	00 
  800112:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800119:	0f 
  80011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800121:	e8 b2 18 00 00       	call   8019d8 <sys_page_alloc>
  800126:	85 c0                	test   %eax,%eax
  800128:	79 20                	jns    80014a <umain+0x10a>
		panic("sys_page_map: %e", r);
  80012a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012e:	c7 44 24 08 d8 34 80 	movl   $0x8034d8,0x8(%esp)
  800135:	00 
  800136:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80013d:	00 
  80013e:	c7 04 24 98 34 80 00 	movl   $0x803498,(%esp)
  800145:	e8 7e 05 00 00       	call   8006c8 <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
  80014a:	bb 04 b0 fe 0f       	mov    $0xffeb004,%ebx
	pkt->jp_len = sizeof(*arp);
  80014f:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  800156:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800159:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800160:	00 
  800161:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800168:	00 
  800169:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  800170:	e8 c1 10 00 00       	call   801236 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800175:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80017c:	00 
  80017d:	8d 75 90             	lea    -0x70(%ebp),%esi
  800180:	89 74 24 04          	mov    %esi,0x4(%esp)
  800184:	c7 04 24 0a b0 fe 0f 	movl   $0xffeb00a,(%esp)
  80018b:	e8 81 11 00 00       	call   801311 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800190:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800197:	e8 18 2e 00 00       	call   802fb4 <htons>
  80019c:	66 89 43 0c          	mov    %ax,0xc(%ebx)
	arp->hwtype = htons(1); // Ethernet
  8001a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a7:	e8 08 2e 00 00       	call   802fb4 <htons>
  8001ac:	66 89 43 0e          	mov    %ax,0xe(%ebx)
	arp->proto = htons(ETHTYPE_IP);
  8001b0:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  8001b7:	e8 f8 2d 00 00       	call   802fb4 <htons>
  8001bc:	66 89 43 10          	mov    %ax,0x10(%ebx)
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  8001c0:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  8001c7:	e8 e8 2d 00 00       	call   802fb4 <htons>
  8001cc:	66 89 43 12          	mov    %ax,0x12(%ebx)
	arp->opcode = htons(ARP_REQUEST);
  8001d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001d7:	e8 d8 2d 00 00       	call   802fb4 <htons>
  8001dc:	66 89 43 14          	mov    %ax,0x14(%ebx)
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001e0:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8001e7:	00 
  8001e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ec:	c7 04 24 1a b0 fe 0f 	movl   $0xffeb01a,(%esp)
  8001f3:	e8 19 11 00 00       	call   801311 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001f8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  8001ff:	00 
  800200:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800203:	89 44 24 04          	mov    %eax,0x4(%esp)
  800207:	c7 04 24 20 b0 fe 0f 	movl   $0xffeb020,(%esp)
  80020e:	e8 fe 10 00 00       	call   801311 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  800213:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80021a:	00 
  80021b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800222:	00 
  800223:	c7 04 24 24 b0 fe 0f 	movl   $0xffeb024,(%esp)
  80022a:	e8 07 10 00 00       	call   801236 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  80022f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800236:	00 
  800237:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80023a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023e:	c7 04 24 2a b0 fe 0f 	movl   $0xffeb02a,(%esp)
  800245:	e8 c7 10 00 00       	call   801311 <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80024a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800251:	00 
  800252:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  800259:	0f 
  80025a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800261:	00 
  800262:	a1 00 50 80 00       	mov    0x805000,%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	e8 fc 1c 00 00       	call   801f6b <ipc_send>
	sys_page_unmap(0, pkt);
  80026f:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800276:	0f 
  800277:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80027e:	e8 7b 16 00 00       	call   8018fe <sys_page_unmap>
  800283:	c7 85 78 ff ff ff 01 	movl   $0x1,-0x88(%ebp)
  80028a:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80028d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800290:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
  800296:	89 b5 70 ff ff ff    	mov    %esi,-0x90(%ebp)
  80029c:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  8002a2:	29 f0                	sub    %esi,%eax
  8002a4:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  8002aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8002ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b1:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  8002b8:	0f 
  8002b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 25 1d 00 00       	call   801fe9 <ipc_recv>
		if (req < 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	79 20                	jns    8002e8 <umain+0x2a8>
			panic("ipc_recv: %e", req);
  8002c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cc:	c7 44 24 08 e9 34 80 	movl   $0x8034e9,0x8(%esp)
  8002d3:	00 
  8002d4:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  8002db:	00 
  8002dc:	c7 04 24 98 34 80 00 	movl   $0x803498,(%esp)
  8002e3:	e8 e0 03 00 00       	call   8006c8 <_panic>
		if (whom != input_envid)
  8002e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002eb:	3b 15 04 50 80 00    	cmp    0x805004,%edx
  8002f1:	74 20                	je     800313 <umain+0x2d3>
			panic("IPC from unexpected environment %08x", whom);
  8002f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f7:	c7 44 24 08 40 35 80 	movl   $0x803540,0x8(%esp)
  8002fe:	00 
  8002ff:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
  800306:	00 
  800307:	c7 04 24 98 34 80 00 	movl   $0x803498,(%esp)
  80030e:	e8 b5 03 00 00       	call   8006c8 <_panic>
		if (req != NSREQ_INPUT)
  800313:	83 f8 0a             	cmp    $0xa,%eax
  800316:	74 20                	je     800338 <umain+0x2f8>
			panic("Unexpected IPC %d", req);
  800318:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031c:	c7 44 24 08 f6 34 80 	movl   $0x8034f6,0x8(%esp)
  800323:	00 
  800324:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80032b:	00 
  80032c:	c7 04 24 98 34 80 00 	movl   $0x803498,(%esp)
  800333:	e8 90 03 00 00       	call   8006c8 <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  800338:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  80033d:	89 45 84             	mov    %eax,-0x7c(%ebp)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  800340:	85 c0                	test   %eax,%eax
  800342:	0f 8e d6 00 00 00    	jle    80041e <umain+0x3de>
  800348:	be 00 00 00 00       	mov    $0x0,%esi
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  800352:	83 e8 01             	sub    $0x1,%eax
  800355:	89 45 80             	mov    %eax,-0x80(%ebp)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  800358:	89 df                	mov    %ebx,%edi
		if (i % 16 == 0)
  80035a:	f6 c3 0f             	test   $0xf,%bl
  80035d:	75 2e                	jne    80038d <umain+0x34d>
			out = buf + snprintf(buf, end - buf,
  80035f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800363:	c7 44 24 0c 08 35 80 	movl   $0x803508,0xc(%esp)
  80036a:	00 
  80036b:	c7 44 24 08 10 35 80 	movl   $0x803510,0x8(%esp)
  800372:	00 
  800373:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037d:	8d 45 90             	lea    -0x70(%ebp),%eax
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	e8 87 0c 00 00       	call   80100f <snprintf>
  800388:	8d 75 90             	lea    -0x70(%ebp),%esi
  80038b:	01 c6                	add    %eax,%esi
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  80038d:	0f b6 87 04 b0 fe 0f 	movzbl 0xffeb004(%edi),%eax
  800394:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800398:	c7 44 24 08 1a 35 80 	movl   $0x80351a,0x8(%esp)
  80039f:	00 
  8003a0:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  8003a6:	29 f0                	sub    %esi,%eax
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	89 34 24             	mov    %esi,(%esp)
  8003af:	e8 5b 0c 00 00       	call   80100f <snprintf>
  8003b4:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8003b6:	89 d8                	mov    %ebx,%eax
  8003b8:	c1 f8 1f             	sar    $0x1f,%eax
  8003bb:	c1 e8 1c             	shr    $0x1c,%eax
  8003be:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8003c1:	83 e7 0f             	and    $0xf,%edi
  8003c4:	29 c7                	sub    %eax,%edi
  8003c6:	83 ff 0f             	cmp    $0xf,%edi
  8003c9:	74 05                	je     8003d0 <umain+0x390>
  8003cb:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  8003ce:	75 1f                	jne    8003ef <umain+0x3af>
			cprintf("%.*s\n", out - buf, buf);
  8003d0:	8d 45 90             	lea    -0x70(%ebp),%eax
  8003d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d7:	89 f0                	mov    %esi,%eax
  8003d9:	2b 85 70 ff ff ff    	sub    -0x90(%ebp),%eax
  8003df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e3:	c7 04 24 1f 35 80 00 	movl   $0x80351f,(%esp)
  8003ea:	e8 92 03 00 00       	call   800781 <cprintf>
		if (i % 2 == 1)
  8003ef:	89 d8                	mov    %ebx,%eax
  8003f1:	c1 e8 1f             	shr    $0x1f,%eax
  8003f4:	8d 14 03             	lea    (%ebx,%eax,1),%edx
  8003f7:	83 e2 01             	and    $0x1,%edx
  8003fa:	29 c2                	sub    %eax,%edx
  8003fc:	83 fa 01             	cmp    $0x1,%edx
  8003ff:	75 06                	jne    800407 <umain+0x3c7>
			*(out++) = ' ';
  800401:	c6 06 20             	movb   $0x20,(%esi)
  800404:	83 c6 01             	add    $0x1,%esi
		if (i % 16 == 7)
  800407:	83 ff 07             	cmp    $0x7,%edi
  80040a:	75 06                	jne    800412 <umain+0x3d2>
			*(out++) = ' ';
  80040c:	c6 06 20             	movb   $0x20,(%esi)
  80040f:	83 c6 01             	add    $0x1,%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  800412:	83 c3 01             	add    $0x1,%ebx
  800415:	39 5d 84             	cmp    %ebx,-0x7c(%ebp)
  800418:	0f 8f 3a ff ff ff    	jg     800358 <umain+0x318>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  80041e:	c7 04 24 3b 35 80 00 	movl   $0x80353b,(%esp)
  800425:	e8 57 03 00 00       	call   800781 <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  80042a:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
  800431:	0f 84 73 fe ff ff    	je     8002aa <umain+0x26a>
			cprintf("Waiting for packets...\n");
  800437:	c7 04 24 25 35 80 00 	movl   $0x803525,(%esp)
  80043e:	e8 3e 03 00 00       	call   800781 <cprintf>
  800443:	c7 85 78 ff ff ff 00 	movl   $0x0,-0x88(%ebp)
  80044a:	00 00 00 
  80044d:	e9 58 fe ff ff       	jmp    8002aa <umain+0x26a>
		first = 0;
	}
}
  800452:	81 c4 ac 00 00 00    	add    $0xac,%esp
  800458:	5b                   	pop    %ebx
  800459:	5e                   	pop    %esi
  80045a:	5f                   	pop    %edi
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    
  80045d:	00 00                	add    %al,(%eax)
	...

00800460 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	57                   	push   %edi
  800464:	56                   	push   %esi
  800465:	53                   	push   %ebx
  800466:	83 ec 2c             	sub    $0x2c,%esp
  800469:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  80046c:	e8 1c 12 00 00       	call   80168d <sys_time_msec>
  800471:	89 c3                	mov    %eax,%ebx
  800473:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  800476:	c7 05 00 40 80 00 65 	movl   $0x803565,0x804000
  80047d:	35 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800480:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800483:	eb 05                	jmp    80048a <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800485:	e8 bb 15 00 00       	call   801a45 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  80048a:	e8 fe 11 00 00       	call   80168d <sys_time_msec>
  80048f:	39 c3                	cmp    %eax,%ebx
  800491:	76 07                	jbe    80049a <timer+0x3a>
  800493:	85 c0                	test   %eax,%eax
  800495:	79 ee                	jns    800485 <timer+0x25>
  800497:	90                   	nop
  800498:	eb 08                	jmp    8004a2 <timer+0x42>
			sys_yield();
		}
		if (r < 0)
  80049a:	85 c0                	test   %eax,%eax
  80049c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004a0:	79 20                	jns    8004c2 <timer+0x62>
			panic("sys_time_msec: %e", r);
  8004a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a6:	c7 44 24 08 6e 35 80 	movl   $0x80356e,0x8(%esp)
  8004ad:	00 
  8004ae:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8004b5:	00 
  8004b6:	c7 04 24 80 35 80 00 	movl   $0x803580,(%esp)
  8004bd:	e8 06 02 00 00       	call   8006c8 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8004c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004c9:	00 
  8004ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004d1:	00 
  8004d2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8004d9:	00 
  8004da:	89 34 24             	mov    %esi,(%esp)
  8004dd:	e8 89 1a 00 00       	call   801f6b <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8004e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004e9:	00 
  8004ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004f1:	00 
  8004f2:	89 3c 24             	mov    %edi,(%esp)
  8004f5:	e8 ef 1a 00 00       	call   801fe9 <ipc_recv>
  8004fa:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8004fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ff:	39 c6                	cmp    %eax,%esi
  800501:	74 12                	je     800515 <timer+0xb5>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	c7 04 24 8c 35 80 00 	movl   $0x80358c,(%esp)
  80050e:	e8 6e 02 00 00       	call   800781 <cprintf>
				continue;
			}

			stop = sys_time_msec() + to;
			break;
		}
  800513:	eb cd                	jmp    8004e2 <timer+0x82>
			if (whom != ns_envid) {
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  800515:	e8 73 11 00 00       	call   80168d <sys_time_msec>
  80051a:	01 c3                	add    %eax,%ebx
  80051c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800520:	e9 65 ff ff ff       	jmp    80048a <timer+0x2a>
  800525:	00 00                	add    %al,(%eax)
	...

00800528 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	57                   	push   %edi
  80052c:	56                   	push   %esi
  80052d:	53                   	push   %ebx
  80052e:	81 ec 2c 08 00 00    	sub    $0x82c,%esp
  800534:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  800537:	c7 05 00 40 80 00 c7 	movl   $0x8035c7,0x804000
  80053e:	35 80 00 
	// another packet in to the same physical page.
        int r;
        int len;
        char buf[MAXBUFLEN];
        while(1){
          while((r = sys_receive_packet((uint32_t)buf,&len))<0)
  800541:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800544:	8d 9d e4 f7 ff ff    	lea    -0x81c(%ebp),%ebx
  80054a:	eb 05                	jmp    800551 <input+0x29>
             sys_yield();
  80054c:	e8 f4 14 00 00       	call   801a45 <sys_yield>
	// another packet in to the same physical page.
        int r;
        int len;
        char buf[MAXBUFLEN];
        while(1){
          while((r = sys_receive_packet((uint32_t)buf,&len))<0)
  800551:	89 74 24 04          	mov    %esi,0x4(%esp)
  800555:	89 1c 24             	mov    %ebx,(%esp)
  800558:	e8 ff 0f 00 00       	call   80155c <sys_receive_packet>
  80055d:	85 c0                	test   %eax,%eax
  80055f:	78 eb                	js     80054c <input+0x24>
             sys_yield();
          r = sys_page_alloc(0,&nsipcbuf,PTE_P|PTE_U|PTE_W);
  800561:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800568:	00 
  800569:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  800570:	00 
  800571:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800578:	e8 5b 14 00 00       	call   8019d8 <sys_page_alloc>
          if(r < 0)
  80057d:	85 c0                	test   %eax,%eax
  80057f:	79 20                	jns    8005a1 <input+0x79>
             panic("error: %e",r);
  800581:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800585:	c7 44 24 08 d0 35 80 	movl   $0x8035d0,0x8(%esp)
  80058c:	00 
  80058d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800594:	00 
  800595:	c7 04 24 da 35 80 00 	movl   $0x8035da,(%esp)
  80059c:	e8 27 01 00 00       	call   8006c8 <_panic>
          memmove(nsipcbuf.pkt.jp_data,(void*)buf,len);
  8005a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8005b3:	e8 dd 0c 00 00       	call   801295 <memmove>
          nsipcbuf.pkt.jp_len = len;
  8005b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005bb:	a3 00 70 80 00       	mov    %eax,0x807000

          ipc_send(ns_envid,NSREQ_INPUT,&nsipcbuf,PTE_P|PTE_U|PTE_W);    
  8005c0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8005c7:	00 
  8005c8:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8005cf:	00 
  8005d0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8005d7:	00 
  8005d8:	89 3c 24             	mov    %edi,(%esp)
  8005db:	e8 8b 19 00 00       	call   801f6b <ipc_send>
  8005e0:	e9 6c ff ff ff       	jmp    800551 <input+0x29>
  8005e5:	00 00                	add    %al,(%eax)
	...

008005e8 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	53                   	push   %ebx
  8005ec:	83 ec 14             	sub    $0x14,%esp
  8005ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	binaryname = "ns_output";
  8005f2:	c7 05 00 40 80 00 e6 	movl   $0x8035e6,0x804000
  8005f9:	35 80 00 
	// 	- read a packet from the network server
	//	- send the packet to the device driver
        int r = 0;
        struct tx_desc td;
        while(1){            
            r = sys_ipc_recv(&nsipcbuf);
  8005fc:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  800603:	e8 06 11 00 00       	call   80170e <sys_ipc_recv>
            if(r != 0 || thisenv->env_ipc_from != ns_envid || thisenv->env_ipc_value != NSREQ_OUTPUT)
  800608:	85 c0                	test   %eax,%eax
  80060a:	75 f0                	jne    8005fc <output+0x14>
  80060c:	a1 24 50 80 00       	mov    0x805024,%eax
  800611:	8b 50 78             	mov    0x78(%eax),%edx
  800614:	39 da                	cmp    %ebx,%edx
  800616:	75 e4                	jne    8005fc <output+0x14>
  800618:	8b 40 74             	mov    0x74(%eax),%eax
  80061b:	83 f8 0b             	cmp    $0xb,%eax
  80061e:	75 dc                	jne    8005fc <output+0x14>
                continue;
          
            uint32_t addr = (uint32_t)nsipcbuf.pkt.jp_data;
            uint32_t length = nsipcbuf.pkt.jp_len;
            r = sys_transmit_packet(addr,length);
  800620:	a1 00 70 80 00       	mov    0x807000,%eax
  800625:	89 44 24 04          	mov    %eax,0x4(%esp)
  800629:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  800630:	e8 69 0f 00 00       	call   80159e <sys_transmit_packet>
            if(r < 0)
  800635:	85 c0                	test   %eax,%eax
  800637:	79 c3                	jns    8005fc <output+0x14>
               panic("transmit_packet error\n");
  800639:	c7 44 24 08 f0 35 80 	movl   $0x8035f0,0x8(%esp)
  800640:	00 
  800641:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800648:	00 
  800649:	c7 04 24 07 36 80 00 	movl   $0x803607,(%esp)
  800650:	e8 73 00 00 00       	call   8006c8 <_panic>
  800655:	00 00                	add    %al,(%eax)
	...

00800658 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	83 ec 18             	sub    $0x18,%esp
  80065e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800661:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800664:	8b 75 08             	mov    0x8(%ebp),%esi
  800667:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80066a:	e8 58 14 00 00       	call   801ac7 <sys_getenvid>
  80066f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800674:	89 c2                	mov    %eax,%edx
  800676:	c1 e2 07             	shl    $0x7,%edx
  800679:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800680:	a3 24 50 80 00       	mov    %eax,0x805024
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800685:	85 f6                	test   %esi,%esi
  800687:	7e 07                	jle    800690 <libmain+0x38>
		binaryname = argv[0];
  800689:	8b 03                	mov    (%ebx),%eax
  80068b:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 34 24             	mov    %esi,(%esp)
  800697:	e8 a4 f9 ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80069c:	e8 0b 00 00 00       	call   8006ac <exit>
}
  8006a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8006a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8006a7:	89 ec                	mov    %ebp,%esp
  8006a9:	5d                   	pop    %ebp
  8006aa:	c3                   	ret    
	...

008006ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8006b2:	e8 84 1e 00 00       	call   80253b <close_all>
	sys_env_destroy(0);
  8006b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006be:	e8 44 14 00 00       	call   801b07 <sys_env_destroy>
}
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    
  8006c5:	00 00                	add    %al,(%eax)
	...

008006c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	56                   	push   %esi
  8006cc:	53                   	push   %ebx
  8006cd:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8006d0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006d3:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8006d9:	e8 e9 13 00 00       	call   801ac7 <sys_getenvid>
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f4:	c7 04 24 20 36 80 00 	movl   $0x803620,(%esp)
  8006fb:	e8 81 00 00 00       	call   800781 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800700:	89 74 24 04          	mov    %esi,0x4(%esp)
  800704:	8b 45 10             	mov    0x10(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 11 00 00 00       	call   800720 <vcprintf>
	cprintf("\n");
  80070f:	c7 04 24 3b 35 80 00 	movl   $0x80353b,(%esp)
  800716:	e8 66 00 00 00       	call   800781 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80071b:	cc                   	int3   
  80071c:	eb fd                	jmp    80071b <_panic+0x53>
	...

00800720 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800729:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800730:	00 00 00 
	b.cnt = 0;
  800733:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80073a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80073d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800740:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800751:	89 44 24 04          	mov    %eax,0x4(%esp)
  800755:	c7 04 24 9b 07 80 00 	movl   $0x80079b,(%esp)
  80075c:	e8 cb 01 00 00       	call   80092c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800761:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800771:	89 04 24             	mov    %eax,(%esp)
  800774:	e8 63 0d 00 00       	call   8014dc <sys_cputs>

	return b.cnt;
}
  800779:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800787:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80078a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	89 04 24             	mov    %eax,(%esp)
  800794:	e8 87 ff ff ff       	call   800720 <vcprintf>
	va_end(ap);

	return cnt;
}
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	83 ec 14             	sub    $0x14,%esp
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007a5:	8b 03                	mov    (%ebx),%eax
  8007a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007aa:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8007ae:	83 c0 01             	add    $0x1,%eax
  8007b1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8007b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007b8:	75 19                	jne    8007d3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8007ba:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8007c1:	00 
  8007c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8007c5:	89 04 24             	mov    %eax,(%esp)
  8007c8:	e8 0f 0d 00 00       	call   8014dc <sys_cputs>
		b->idx = 0;
  8007cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007d3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8007d7:	83 c4 14             	add    $0x14,%esp
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	57                   	push   %edi
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	83 ec 4c             	sub    $0x4c,%esp
  8007e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ec:	89 d6                	mov    %edx,%esi
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800800:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800803:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800806:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080b:	39 d1                	cmp    %edx,%ecx
  80080d:	72 07                	jb     800816 <printnum_v2+0x36>
  80080f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800812:	39 d0                	cmp    %edx,%eax
  800814:	77 5f                	ja     800875 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800816:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80081a:	83 eb 01             	sub    $0x1,%ebx
  80081d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800821:	89 44 24 08          	mov    %eax,0x8(%esp)
  800825:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800829:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80082d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800830:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800833:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800836:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80083a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800841:	00 
  800842:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800845:	89 04 24             	mov    %eax,(%esp)
  800848:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80084b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084f:	e8 bc 29 00 00       	call   803210 <__udivdi3>
  800854:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800857:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80085a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80085e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	89 54 24 04          	mov    %edx,0x4(%esp)
  800869:	89 f2                	mov    %esi,%edx
  80086b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80086e:	e8 6d ff ff ff       	call   8007e0 <printnum_v2>
  800873:	eb 1e                	jmp    800893 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800875:	83 ff 2d             	cmp    $0x2d,%edi
  800878:	74 19                	je     800893 <printnum_v2+0xb3>
		while (--width > 0)
  80087a:	83 eb 01             	sub    $0x1,%ebx
  80087d:	85 db                	test   %ebx,%ebx
  80087f:	90                   	nop
  800880:	7e 11                	jle    800893 <printnum_v2+0xb3>
			putch(padc, putdat);
  800882:	89 74 24 04          	mov    %esi,0x4(%esp)
  800886:	89 3c 24             	mov    %edi,(%esp)
  800889:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80088c:	83 eb 01             	sub    $0x1,%ebx
  80088f:	85 db                	test   %ebx,%ebx
  800891:	7f ef                	jg     800882 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800893:	89 74 24 04          	mov    %esi,0x4(%esp)
  800897:	8b 74 24 04          	mov    0x4(%esp),%esi
  80089b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80089e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008a9:	00 
  8008aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008ad:	89 14 24             	mov    %edx,(%esp)
  8008b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b7:	e8 84 2a 00 00       	call   803340 <__umoddi3>
  8008bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c0:	0f be 80 43 36 80 00 	movsbl 0x803643(%eax),%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8008cd:	83 c4 4c             	add    $0x4c,%esp
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5f                   	pop    %edi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8008d8:	83 fa 01             	cmp    $0x1,%edx
  8008db:	7e 0e                	jle    8008eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8008dd:	8b 10                	mov    (%eax),%edx
  8008df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8008e2:	89 08                	mov    %ecx,(%eax)
  8008e4:	8b 02                	mov    (%edx),%eax
  8008e6:	8b 52 04             	mov    0x4(%edx),%edx
  8008e9:	eb 22                	jmp    80090d <getuint+0x38>
	else if (lflag)
  8008eb:	85 d2                	test   %edx,%edx
  8008ed:	74 10                	je     8008ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8008ef:	8b 10                	mov    (%eax),%edx
  8008f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008f4:	89 08                	mov    %ecx,(%eax)
  8008f6:	8b 02                	mov    (%edx),%eax
  8008f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fd:	eb 0e                	jmp    80090d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8008ff:	8b 10                	mov    (%eax),%edx
  800901:	8d 4a 04             	lea    0x4(%edx),%ecx
  800904:	89 08                	mov    %ecx,(%eax)
  800906:	8b 02                	mov    (%edx),%eax
  800908:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800915:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800919:	8b 10                	mov    (%eax),%edx
  80091b:	3b 50 04             	cmp    0x4(%eax),%edx
  80091e:	73 0a                	jae    80092a <sprintputch+0x1b>
		*b->buf++ = ch;
  800920:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800923:	88 0a                	mov    %cl,(%edx)
  800925:	83 c2 01             	add    $0x1,%edx
  800928:	89 10                	mov    %edx,(%eax)
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	57                   	push   %edi
  800930:	56                   	push   %esi
  800931:	53                   	push   %ebx
  800932:	83 ec 6c             	sub    $0x6c,%esp
  800935:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800938:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80093f:	eb 1a                	jmp    80095b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800941:	85 c0                	test   %eax,%eax
  800943:	0f 84 66 06 00 00    	je     800faf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	ff 55 08             	call   *0x8(%ebp)
  800956:	eb 03                	jmp    80095b <vprintfmt+0x2f>
  800958:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80095b:	0f b6 07             	movzbl (%edi),%eax
  80095e:	83 c7 01             	add    $0x1,%edi
  800961:	83 f8 25             	cmp    $0x25,%eax
  800964:	75 db                	jne    800941 <vprintfmt+0x15>
  800966:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80096a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800976:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80097b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800982:	be 00 00 00 00       	mov    $0x0,%esi
  800987:	eb 06                	jmp    80098f <vprintfmt+0x63>
  800989:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80098d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098f:	0f b6 17             	movzbl (%edi),%edx
  800992:	0f b6 c2             	movzbl %dl,%eax
  800995:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800998:	8d 47 01             	lea    0x1(%edi),%eax
  80099b:	83 ea 23             	sub    $0x23,%edx
  80099e:	80 fa 55             	cmp    $0x55,%dl
  8009a1:	0f 87 60 05 00 00    	ja     800f07 <vprintfmt+0x5db>
  8009a7:	0f b6 d2             	movzbl %dl,%edx
  8009aa:	ff 24 95 20 38 80 00 	jmp    *0x803820(,%edx,4)
  8009b1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8009b6:	eb d5                	jmp    80098d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8009b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009bb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8009be:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8009c1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8009c4:	83 ff 09             	cmp    $0x9,%edi
  8009c7:	76 08                	jbe    8009d1 <vprintfmt+0xa5>
  8009c9:	eb 40                	jmp    800a0b <vprintfmt+0xdf>
  8009cb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8009cf:	eb bc                	jmp    80098d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009d1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8009d4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8009d7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8009db:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8009de:	8d 7a d0             	lea    -0x30(%edx),%edi
  8009e1:	83 ff 09             	cmp    $0x9,%edi
  8009e4:	76 eb                	jbe    8009d1 <vprintfmt+0xa5>
  8009e6:	eb 23                	jmp    800a0b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8009e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8009eb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8009ee:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8009f1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8009f3:	eb 16                	jmp    800a0b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8009f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009f8:	c1 fa 1f             	sar    $0x1f,%edx
  8009fb:	f7 d2                	not    %edx
  8009fd:	21 55 d8             	and    %edx,-0x28(%ebp)
  800a00:	eb 8b                	jmp    80098d <vprintfmt+0x61>
  800a02:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800a09:	eb 82                	jmp    80098d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  800a0b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a0f:	0f 89 78 ff ff ff    	jns    80098d <vprintfmt+0x61>
  800a15:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800a18:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  800a1b:	e9 6d ff ff ff       	jmp    80098d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a20:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800a23:	e9 65 ff ff ff       	jmp    80098d <vprintfmt+0x61>
  800a28:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2e:	8d 50 04             	lea    0x4(%eax),%edx
  800a31:	89 55 14             	mov    %edx,0x14(%ebp)
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a37:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a3b:	8b 00                	mov    (%eax),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	ff 55 08             	call   *0x8(%ebp)
  800a43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800a46:	e9 10 ff ff ff       	jmp    80095b <vprintfmt+0x2f>
  800a4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a51:	8d 50 04             	lea    0x4(%eax),%edx
  800a54:	89 55 14             	mov    %edx,0x14(%ebp)
  800a57:	8b 00                	mov    (%eax),%eax
  800a59:	89 c2                	mov    %eax,%edx
  800a5b:	c1 fa 1f             	sar    $0x1f,%edx
  800a5e:	31 d0                	xor    %edx,%eax
  800a60:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a62:	83 f8 0f             	cmp    $0xf,%eax
  800a65:	7f 0b                	jg     800a72 <vprintfmt+0x146>
  800a67:	8b 14 85 80 39 80 00 	mov    0x803980(,%eax,4),%edx
  800a6e:	85 d2                	test   %edx,%edx
  800a70:	75 26                	jne    800a98 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800a72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a76:	c7 44 24 08 54 36 80 	movl   $0x803654,0x8(%esp)
  800a7d:	00 
  800a7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a81:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a85:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a88:	89 1c 24             	mov    %ebx,(%esp)
  800a8b:	e8 a7 05 00 00       	call   801037 <printfmt>
  800a90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a93:	e9 c3 fe ff ff       	jmp    80095b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800a98:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a9c:	c7 44 24 08 66 3b 80 	movl   $0x803b66,0x8(%esp)
  800aa3:	00 
  800aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aab:	8b 55 08             	mov    0x8(%ebp),%edx
  800aae:	89 14 24             	mov    %edx,(%esp)
  800ab1:	e8 81 05 00 00       	call   801037 <printfmt>
  800ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ab9:	e9 9d fe ff ff       	jmp    80095b <vprintfmt+0x2f>
  800abe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ac1:	89 c7                	mov    %eax,%edi
  800ac3:	89 d9                	mov    %ebx,%ecx
  800ac5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ac8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800acb:	8b 45 14             	mov    0x14(%ebp),%eax
  800ace:	8d 50 04             	lea    0x4(%eax),%edx
  800ad1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad4:	8b 30                	mov    (%eax),%esi
  800ad6:	85 f6                	test   %esi,%esi
  800ad8:	75 05                	jne    800adf <vprintfmt+0x1b3>
  800ada:	be 5d 36 80 00       	mov    $0x80365d,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  800adf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800ae3:	7e 06                	jle    800aeb <vprintfmt+0x1bf>
  800ae5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800ae9:	75 10                	jne    800afb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aeb:	0f be 06             	movsbl (%esi),%eax
  800aee:	85 c0                	test   %eax,%eax
  800af0:	0f 85 a2 00 00 00    	jne    800b98 <vprintfmt+0x26c>
  800af6:	e9 92 00 00 00       	jmp    800b8d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800afb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800aff:	89 34 24             	mov    %esi,(%esp)
  800b02:	e8 74 05 00 00       	call   80107b <strnlen>
  800b07:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800b0a:	29 c2                	sub    %eax,%edx
  800b0c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800b0f:	85 d2                	test   %edx,%edx
  800b11:	7e d8                	jle    800aeb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800b13:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800b17:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800b1a:	89 d3                	mov    %edx,%ebx
  800b1c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800b1f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800b22:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b25:	89 ce                	mov    %ecx,%esi
  800b27:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b2b:	89 34 24             	mov    %esi,(%esp)
  800b2e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b31:	83 eb 01             	sub    $0x1,%ebx
  800b34:	85 db                	test   %ebx,%ebx
  800b36:	7f ef                	jg     800b27 <vprintfmt+0x1fb>
  800b38:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800b3b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800b3e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800b41:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800b48:	eb a1                	jmp    800aeb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b4a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800b4e:	74 1b                	je     800b6b <vprintfmt+0x23f>
  800b50:	8d 50 e0             	lea    -0x20(%eax),%edx
  800b53:	83 fa 5e             	cmp    $0x5e,%edx
  800b56:	76 13                	jbe    800b6b <vprintfmt+0x23f>
					putch('?', putdat);
  800b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b66:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b69:	eb 0d                	jmp    800b78 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b72:	89 04 24             	mov    %eax,(%esp)
  800b75:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b78:	83 ef 01             	sub    $0x1,%edi
  800b7b:	0f be 06             	movsbl (%esi),%eax
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	74 05                	je     800b87 <vprintfmt+0x25b>
  800b82:	83 c6 01             	add    $0x1,%esi
  800b85:	eb 1a                	jmp    800ba1 <vprintfmt+0x275>
  800b87:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800b8a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b8d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b91:	7f 1f                	jg     800bb2 <vprintfmt+0x286>
  800b93:	e9 c0 fd ff ff       	jmp    800958 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b98:	83 c6 01             	add    $0x1,%esi
  800b9b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800b9e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800ba1:	85 db                	test   %ebx,%ebx
  800ba3:	78 a5                	js     800b4a <vprintfmt+0x21e>
  800ba5:	83 eb 01             	sub    $0x1,%ebx
  800ba8:	79 a0                	jns    800b4a <vprintfmt+0x21e>
  800baa:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800bad:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800bb0:	eb db                	jmp    800b8d <vprintfmt+0x261>
  800bb2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800bb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800bbb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bc2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bc9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bcb:	83 eb 01             	sub    $0x1,%ebx
  800bce:	85 db                	test   %ebx,%ebx
  800bd0:	7f ec                	jg     800bbe <vprintfmt+0x292>
  800bd2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800bd5:	e9 81 fd ff ff       	jmp    80095b <vprintfmt+0x2f>
  800bda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bdd:	83 fe 01             	cmp    $0x1,%esi
  800be0:	7e 10                	jle    800bf2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800be2:	8b 45 14             	mov    0x14(%ebp),%eax
  800be5:	8d 50 08             	lea    0x8(%eax),%edx
  800be8:	89 55 14             	mov    %edx,0x14(%ebp)
  800beb:	8b 18                	mov    (%eax),%ebx
  800bed:	8b 70 04             	mov    0x4(%eax),%esi
  800bf0:	eb 26                	jmp    800c18 <vprintfmt+0x2ec>
	else if (lflag)
  800bf2:	85 f6                	test   %esi,%esi
  800bf4:	74 12                	je     800c08 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800bf6:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf9:	8d 50 04             	lea    0x4(%eax),%edx
  800bfc:	89 55 14             	mov    %edx,0x14(%ebp)
  800bff:	8b 18                	mov    (%eax),%ebx
  800c01:	89 de                	mov    %ebx,%esi
  800c03:	c1 fe 1f             	sar    $0x1f,%esi
  800c06:	eb 10                	jmp    800c18 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800c08:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0b:	8d 50 04             	lea    0x4(%eax),%edx
  800c0e:	89 55 14             	mov    %edx,0x14(%ebp)
  800c11:	8b 18                	mov    (%eax),%ebx
  800c13:	89 de                	mov    %ebx,%esi
  800c15:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800c18:	83 f9 01             	cmp    $0x1,%ecx
  800c1b:	75 1e                	jne    800c3b <vprintfmt+0x30f>
                               if((long long)num > 0){
  800c1d:	85 f6                	test   %esi,%esi
  800c1f:	78 1a                	js     800c3b <vprintfmt+0x30f>
  800c21:	85 f6                	test   %esi,%esi
  800c23:	7f 05                	jg     800c2a <vprintfmt+0x2fe>
  800c25:	83 fb 00             	cmp    $0x0,%ebx
  800c28:	76 11                	jbe    800c3b <vprintfmt+0x30f>
                                   putch('+',putdat);
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c31:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800c38:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  800c3b:	85 f6                	test   %esi,%esi
  800c3d:	78 13                	js     800c52 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c3f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800c42:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800c45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4d:	e9 da 00 00 00       	jmp    800d2c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c59:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c60:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c63:	89 da                	mov    %ebx,%edx
  800c65:	89 f1                	mov    %esi,%ecx
  800c67:	f7 da                	neg    %edx
  800c69:	83 d1 00             	adc    $0x0,%ecx
  800c6c:	f7 d9                	neg    %ecx
  800c6e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800c71:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800c74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7c:	e9 ab 00 00 00       	jmp    800d2c <vprintfmt+0x400>
  800c81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c84:	89 f2                	mov    %esi,%edx
  800c86:	8d 45 14             	lea    0x14(%ebp),%eax
  800c89:	e8 47 fc ff ff       	call   8008d5 <getuint>
  800c8e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800c91:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800c94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c97:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800c9c:	e9 8b 00 00 00       	jmp    800d2c <vprintfmt+0x400>
  800ca1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cab:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cb2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800cb5:	89 f2                	mov    %esi,%edx
  800cb7:	8d 45 14             	lea    0x14(%ebp),%eax
  800cba:	e8 16 fc ff ff       	call   8008d5 <getuint>
  800cbf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800cc2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800cc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cc8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  800ccd:	eb 5d                	jmp    800d2c <vprintfmt+0x400>
  800ccf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800cd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cd5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ce0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800ce3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cee:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800cf1:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf4:	8d 50 04             	lea    0x4(%eax),%edx
  800cf7:	89 55 14             	mov    %edx,0x14(%ebp)
  800cfa:	8b 10                	mov    (%eax),%edx
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800d04:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800d07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d0a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800d0f:	eb 1b                	jmp    800d2c <vprintfmt+0x400>
  800d11:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	8d 45 14             	lea    0x14(%ebp),%eax
  800d19:	e8 b7 fb ff ff       	call   8008d5 <getuint>
  800d1e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800d21:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800d24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d27:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d2c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800d30:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800d33:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d36:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800d3a:	77 09                	ja     800d45 <vprintfmt+0x419>
  800d3c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800d3f:	0f 82 ac 00 00 00    	jb     800df1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800d45:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800d48:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800d4c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d4f:	83 ea 01             	sub    $0x1,%edx
  800d52:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d56:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d5a:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d5e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d62:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800d65:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800d68:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800d6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d6f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d76:	00 
  800d77:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800d7a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800d7d:	89 0c 24             	mov    %ecx,(%esp)
  800d80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d84:	e8 87 24 00 00       	call   803210 <__udivdi3>
  800d89:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800d8c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800d8f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d93:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d97:	89 04 24             	mov    %eax,(%esp)
  800d9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	e8 37 fa ff ff       	call   8007e0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800da9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800db0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800db4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800db7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dbb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dc2:	00 
  800dc3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800dc6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800dc9:	89 14 24             	mov    %edx,(%esp)
  800dcc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800dd0:	e8 6b 25 00 00       	call   803340 <__umoddi3>
  800dd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd9:	0f be 80 43 36 80 00 	movsbl 0x803643(%eax),%eax
  800de0:	89 04 24             	mov    %eax,(%esp)
  800de3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800de6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800dea:	74 54                	je     800e40 <vprintfmt+0x514>
  800dec:	e9 67 fb ff ff       	jmp    800958 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800df1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	0f 84 2a 01 00 00    	je     800f28 <vprintfmt+0x5fc>
		while (--width > 0)
  800dfe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800e01:	83 ef 01             	sub    $0x1,%edi
  800e04:	85 ff                	test   %edi,%edi
  800e06:	0f 8e 5e 01 00 00    	jle    800f6a <vprintfmt+0x63e>
  800e0c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800e0f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800e12:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800e15:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800e18:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800e1b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800e1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e22:	89 1c 24             	mov    %ebx,(%esp)
  800e25:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800e28:	83 ef 01             	sub    $0x1,%edi
  800e2b:	85 ff                	test   %edi,%edi
  800e2d:	7f ef                	jg     800e1e <vprintfmt+0x4f2>
  800e2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800e32:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800e35:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800e38:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800e3b:	e9 2a 01 00 00       	jmp    800f6a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800e40:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e43:	83 eb 01             	sub    $0x1,%ebx
  800e46:	85 db                	test   %ebx,%ebx
  800e48:	0f 8e 0a fb ff ff    	jle    800958 <vprintfmt+0x2c>
  800e4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e51:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800e54:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800e57:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e62:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800e64:	83 eb 01             	sub    $0x1,%ebx
  800e67:	85 db                	test   %ebx,%ebx
  800e69:	7f ec                	jg     800e57 <vprintfmt+0x52b>
  800e6b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800e6e:	e9 e8 fa ff ff       	jmp    80095b <vprintfmt+0x2f>
  800e73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800e76:	8b 45 14             	mov    0x14(%ebp),%eax
  800e79:	8d 50 04             	lea    0x4(%eax),%edx
  800e7c:	89 55 14             	mov    %edx,0x14(%ebp)
  800e7f:	8b 00                	mov    (%eax),%eax
  800e81:	85 c0                	test   %eax,%eax
  800e83:	75 2a                	jne    800eaf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800e85:	c7 44 24 0c 78 37 80 	movl   $0x803778,0xc(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 08 66 3b 80 	movl   $0x803b66,0x8(%esp)
  800e94:	00 
  800e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e98:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9f:	89 0c 24             	mov    %ecx,(%esp)
  800ea2:	e8 90 01 00 00       	call   801037 <printfmt>
  800ea7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800eaa:	e9 ac fa ff ff       	jmp    80095b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800eaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb2:	8b 13                	mov    (%ebx),%edx
  800eb4:	83 fa 7f             	cmp    $0x7f,%edx
  800eb7:	7e 29                	jle    800ee2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800eb9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800ebb:	c7 44 24 0c b0 37 80 	movl   $0x8037b0,0xc(%esp)
  800ec2:	00 
  800ec3:	c7 44 24 08 66 3b 80 	movl   $0x803b66,0x8(%esp)
  800eca:	00 
  800ecb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	89 04 24             	mov    %eax,(%esp)
  800ed5:	e8 5d 01 00 00       	call   801037 <printfmt>
  800eda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800edd:	e9 79 fa ff ff       	jmp    80095b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800ee2:	88 10                	mov    %dl,(%eax)
  800ee4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ee7:	e9 6f fa ff ff       	jmp    80095b <vprintfmt+0x2f>
  800eec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800eef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ef9:	89 14 24             	mov    %edx,(%esp)
  800efc:	ff 55 08             	call   *0x8(%ebp)
  800eff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800f02:	e9 54 fa ff ff       	jmp    80095b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f0e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800f15:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f18:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f1b:	80 38 25             	cmpb   $0x25,(%eax)
  800f1e:	0f 84 37 fa ff ff    	je     80095b <vprintfmt+0x2f>
  800f24:	89 c7                	mov    %eax,%edi
  800f26:	eb f0                	jmp    800f18 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f33:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800f36:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f41:	00 
  800f42:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800f45:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800f48:	89 04 24             	mov    %eax,(%esp)
  800f4b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f4f:	e8 ec 23 00 00       	call   803340 <__umoddi3>
  800f54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f58:	0f be 80 43 36 80 00 	movsbl 0x803643(%eax),%eax
  800f5f:	89 04 24             	mov    %eax,(%esp)
  800f62:	ff 55 08             	call   *0x8(%ebp)
  800f65:	e9 d6 fe ff ff       	jmp    800e40 <vprintfmt+0x514>
  800f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f71:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f75:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f83:	00 
  800f84:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800f87:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800f8a:	89 04 24             	mov    %eax,(%esp)
  800f8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f91:	e8 aa 23 00 00       	call   803340 <__umoddi3>
  800f96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f9a:	0f be 80 43 36 80 00 	movsbl 0x803643(%eax),%eax
  800fa1:	89 04 24             	mov    %eax,(%esp)
  800fa4:	ff 55 08             	call   *0x8(%ebp)
  800fa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800faa:	e9 ac f9 ff ff       	jmp    80095b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800faf:	83 c4 6c             	add    $0x6c,%esp
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 28             	sub    $0x28,%esp
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	74 04                	je     800fcb <vsnprintf+0x14>
  800fc7:	85 d2                	test   %edx,%edx
  800fc9:	7f 07                	jg     800fd2 <vsnprintf+0x1b>
  800fcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd0:	eb 3b                	jmp    80100d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fd5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800fd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800fe3:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fea:	8b 45 10             	mov    0x10(%ebp),%eax
  800fed:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff8:	c7 04 24 0f 09 80 00 	movl   $0x80090f,(%esp)
  800fff:	e8 28 f9 ff ff       	call   80092c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801004:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801007:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    

0080100f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801015:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801018:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80101c:	8b 45 10             	mov    0x10(%ebp),%eax
  80101f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801023:	8b 45 0c             	mov    0xc(%ebp),%eax
  801026:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	89 04 24             	mov    %eax,(%esp)
  801030:	e8 82 ff ff ff       	call   800fb7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80103d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801040:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801044:	8b 45 10             	mov    0x10(%ebp),%eax
  801047:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801052:	8b 45 08             	mov    0x8(%ebp),%eax
  801055:	89 04 24             	mov    %eax,(%esp)
  801058:	e8 cf f8 ff ff       	call   80092c <vprintfmt>
	va_end(ap);
}
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    
	...

00801060 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801066:	b8 00 00 00 00       	mov    $0x0,%eax
  80106b:	80 3a 00             	cmpb   $0x0,(%edx)
  80106e:	74 09                	je     801079 <strlen+0x19>
		n++;
  801070:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801073:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801077:	75 f7                	jne    801070 <strlen+0x10>
		n++;
	return n;
}
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	53                   	push   %ebx
  80107f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801082:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801085:	85 c9                	test   %ecx,%ecx
  801087:	74 19                	je     8010a2 <strnlen+0x27>
  801089:	80 3b 00             	cmpb   $0x0,(%ebx)
  80108c:	74 14                	je     8010a2 <strnlen+0x27>
  80108e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801093:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801096:	39 c8                	cmp    %ecx,%eax
  801098:	74 0d                	je     8010a7 <strnlen+0x2c>
  80109a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80109e:	75 f3                	jne    801093 <strnlen+0x18>
  8010a0:	eb 05                	jmp    8010a7 <strnlen+0x2c>
  8010a2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8010a7:	5b                   	pop    %ebx
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	53                   	push   %ebx
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010b4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8010b9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8010bd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8010c0:	83 c2 01             	add    $0x1,%edx
  8010c3:	84 c9                	test   %cl,%cl
  8010c5:	75 f2                	jne    8010b9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8010c7:	5b                   	pop    %ebx
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <strcat>:

char *
strcat(char *dst, const char *src)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	53                   	push   %ebx
  8010ce:	83 ec 08             	sub    $0x8,%esp
  8010d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8010d4:	89 1c 24             	mov    %ebx,(%esp)
  8010d7:	e8 84 ff ff ff       	call   801060 <strlen>
	strcpy(dst + len, src);
  8010dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010df:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010e3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8010e6:	89 04 24             	mov    %eax,(%esp)
  8010e9:	e8 bc ff ff ff       	call   8010aa <strcpy>
	return dst;
}
  8010ee:	89 d8                	mov    %ebx,%eax
  8010f0:	83 c4 08             	add    $0x8,%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801101:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801104:	85 f6                	test   %esi,%esi
  801106:	74 18                	je     801120 <strncpy+0x2a>
  801108:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80110d:	0f b6 1a             	movzbl (%edx),%ebx
  801110:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801113:	80 3a 01             	cmpb   $0x1,(%edx)
  801116:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801119:	83 c1 01             	add    $0x1,%ecx
  80111c:	39 ce                	cmp    %ecx,%esi
  80111e:	77 ed                	ja     80110d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	8b 75 08             	mov    0x8(%ebp),%esi
  80112c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801132:	89 f0                	mov    %esi,%eax
  801134:	85 c9                	test   %ecx,%ecx
  801136:	74 27                	je     80115f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801138:	83 e9 01             	sub    $0x1,%ecx
  80113b:	74 1d                	je     80115a <strlcpy+0x36>
  80113d:	0f b6 1a             	movzbl (%edx),%ebx
  801140:	84 db                	test   %bl,%bl
  801142:	74 16                	je     80115a <strlcpy+0x36>
			*dst++ = *src++;
  801144:	88 18                	mov    %bl,(%eax)
  801146:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801149:	83 e9 01             	sub    $0x1,%ecx
  80114c:	74 0e                	je     80115c <strlcpy+0x38>
			*dst++ = *src++;
  80114e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801151:	0f b6 1a             	movzbl (%edx),%ebx
  801154:	84 db                	test   %bl,%bl
  801156:	75 ec                	jne    801144 <strlcpy+0x20>
  801158:	eb 02                	jmp    80115c <strlcpy+0x38>
  80115a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80115c:	c6 00 00             	movb   $0x0,(%eax)
  80115f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80116e:	0f b6 01             	movzbl (%ecx),%eax
  801171:	84 c0                	test   %al,%al
  801173:	74 15                	je     80118a <strcmp+0x25>
  801175:	3a 02                	cmp    (%edx),%al
  801177:	75 11                	jne    80118a <strcmp+0x25>
		p++, q++;
  801179:	83 c1 01             	add    $0x1,%ecx
  80117c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80117f:	0f b6 01             	movzbl (%ecx),%eax
  801182:	84 c0                	test   %al,%al
  801184:	74 04                	je     80118a <strcmp+0x25>
  801186:	3a 02                	cmp    (%edx),%al
  801188:	74 ef                	je     801179 <strcmp+0x14>
  80118a:	0f b6 c0             	movzbl %al,%eax
  80118d:	0f b6 12             	movzbl (%edx),%edx
  801190:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	53                   	push   %ebx
  801198:	8b 55 08             	mov    0x8(%ebp),%edx
  80119b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	74 23                	je     8011c8 <strncmp+0x34>
  8011a5:	0f b6 1a             	movzbl (%edx),%ebx
  8011a8:	84 db                	test   %bl,%bl
  8011aa:	74 25                	je     8011d1 <strncmp+0x3d>
  8011ac:	3a 19                	cmp    (%ecx),%bl
  8011ae:	75 21                	jne    8011d1 <strncmp+0x3d>
  8011b0:	83 e8 01             	sub    $0x1,%eax
  8011b3:	74 13                	je     8011c8 <strncmp+0x34>
		n--, p++, q++;
  8011b5:	83 c2 01             	add    $0x1,%edx
  8011b8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8011bb:	0f b6 1a             	movzbl (%edx),%ebx
  8011be:	84 db                	test   %bl,%bl
  8011c0:	74 0f                	je     8011d1 <strncmp+0x3d>
  8011c2:	3a 19                	cmp    (%ecx),%bl
  8011c4:	74 ea                	je     8011b0 <strncmp+0x1c>
  8011c6:	eb 09                	jmp    8011d1 <strncmp+0x3d>
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8011cd:	5b                   	pop    %ebx
  8011ce:	5d                   	pop    %ebp
  8011cf:	90                   	nop
  8011d0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8011d1:	0f b6 02             	movzbl (%edx),%eax
  8011d4:	0f b6 11             	movzbl (%ecx),%edx
  8011d7:	29 d0                	sub    %edx,%eax
  8011d9:	eb f2                	jmp    8011cd <strncmp+0x39>

008011db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8011e5:	0f b6 10             	movzbl (%eax),%edx
  8011e8:	84 d2                	test   %dl,%dl
  8011ea:	74 18                	je     801204 <strchr+0x29>
		if (*s == c)
  8011ec:	38 ca                	cmp    %cl,%dl
  8011ee:	75 0a                	jne    8011fa <strchr+0x1f>
  8011f0:	eb 17                	jmp    801209 <strchr+0x2e>
  8011f2:	38 ca                	cmp    %cl,%dl
  8011f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	74 0f                	je     801209 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8011fa:	83 c0 01             	add    $0x1,%eax
  8011fd:	0f b6 10             	movzbl (%eax),%edx
  801200:	84 d2                	test   %dl,%dl
  801202:	75 ee                	jne    8011f2 <strchr+0x17>
  801204:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	8b 45 08             	mov    0x8(%ebp),%eax
  801211:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801215:	0f b6 10             	movzbl (%eax),%edx
  801218:	84 d2                	test   %dl,%dl
  80121a:	74 18                	je     801234 <strfind+0x29>
		if (*s == c)
  80121c:	38 ca                	cmp    %cl,%dl
  80121e:	75 0a                	jne    80122a <strfind+0x1f>
  801220:	eb 12                	jmp    801234 <strfind+0x29>
  801222:	38 ca                	cmp    %cl,%dl
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	74 0a                	je     801234 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80122a:	83 c0 01             	add    $0x1,%eax
  80122d:	0f b6 10             	movzbl (%eax),%edx
  801230:	84 d2                	test   %dl,%dl
  801232:	75 ee                	jne    801222 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	83 ec 0c             	sub    $0xc,%esp
  80123c:	89 1c 24             	mov    %ebx,(%esp)
  80123f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801243:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801247:	8b 7d 08             	mov    0x8(%ebp),%edi
  80124a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801250:	85 c9                	test   %ecx,%ecx
  801252:	74 30                	je     801284 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801254:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80125a:	75 25                	jne    801281 <memset+0x4b>
  80125c:	f6 c1 03             	test   $0x3,%cl
  80125f:	75 20                	jne    801281 <memset+0x4b>
		c &= 0xFF;
  801261:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801264:	89 d3                	mov    %edx,%ebx
  801266:	c1 e3 08             	shl    $0x8,%ebx
  801269:	89 d6                	mov    %edx,%esi
  80126b:	c1 e6 18             	shl    $0x18,%esi
  80126e:	89 d0                	mov    %edx,%eax
  801270:	c1 e0 10             	shl    $0x10,%eax
  801273:	09 f0                	or     %esi,%eax
  801275:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801277:	09 d8                	or     %ebx,%eax
  801279:	c1 e9 02             	shr    $0x2,%ecx
  80127c:	fc                   	cld    
  80127d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80127f:	eb 03                	jmp    801284 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801281:	fc                   	cld    
  801282:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801284:	89 f8                	mov    %edi,%eax
  801286:	8b 1c 24             	mov    (%esp),%ebx
  801289:	8b 74 24 04          	mov    0x4(%esp),%esi
  80128d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801291:	89 ec                	mov    %ebp,%esp
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	89 34 24             	mov    %esi,(%esp)
  80129e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8012a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8012ab:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8012ad:	39 c6                	cmp    %eax,%esi
  8012af:	73 35                	jae    8012e6 <memmove+0x51>
  8012b1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8012b4:	39 d0                	cmp    %edx,%eax
  8012b6:	73 2e                	jae    8012e6 <memmove+0x51>
		s += n;
		d += n;
  8012b8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012ba:	f6 c2 03             	test   $0x3,%dl
  8012bd:	75 1b                	jne    8012da <memmove+0x45>
  8012bf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012c5:	75 13                	jne    8012da <memmove+0x45>
  8012c7:	f6 c1 03             	test   $0x3,%cl
  8012ca:	75 0e                	jne    8012da <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8012cc:	83 ef 04             	sub    $0x4,%edi
  8012cf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8012d2:	c1 e9 02             	shr    $0x2,%ecx
  8012d5:	fd                   	std    
  8012d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012d8:	eb 09                	jmp    8012e3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8012da:	83 ef 01             	sub    $0x1,%edi
  8012dd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8012e0:	fd                   	std    
  8012e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8012e3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8012e4:	eb 20                	jmp    801306 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8012ec:	75 15                	jne    801303 <memmove+0x6e>
  8012ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012f4:	75 0d                	jne    801303 <memmove+0x6e>
  8012f6:	f6 c1 03             	test   $0x3,%cl
  8012f9:	75 08                	jne    801303 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8012fb:	c1 e9 02             	shr    $0x2,%ecx
  8012fe:	fc                   	cld    
  8012ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801301:	eb 03                	jmp    801306 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801303:	fc                   	cld    
  801304:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801306:	8b 34 24             	mov    (%esp),%esi
  801309:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80130d:	89 ec                	mov    %ebp,%esp
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801317:	8b 45 10             	mov    0x10(%ebp),%eax
  80131a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801321:	89 44 24 04          	mov    %eax,0x4(%esp)
  801325:	8b 45 08             	mov    0x8(%ebp),%eax
  801328:	89 04 24             	mov    %eax,(%esp)
  80132b:	e8 65 ff ff ff       	call   801295 <memmove>
}
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	57                   	push   %edi
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	8b 75 08             	mov    0x8(%ebp),%esi
  80133b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80133e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801341:	85 c9                	test   %ecx,%ecx
  801343:	74 36                	je     80137b <memcmp+0x49>
		if (*s1 != *s2)
  801345:	0f b6 06             	movzbl (%esi),%eax
  801348:	0f b6 1f             	movzbl (%edi),%ebx
  80134b:	38 d8                	cmp    %bl,%al
  80134d:	74 20                	je     80136f <memcmp+0x3d>
  80134f:	eb 14                	jmp    801365 <memcmp+0x33>
  801351:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801356:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80135b:	83 c2 01             	add    $0x1,%edx
  80135e:	83 e9 01             	sub    $0x1,%ecx
  801361:	38 d8                	cmp    %bl,%al
  801363:	74 12                	je     801377 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801365:	0f b6 c0             	movzbl %al,%eax
  801368:	0f b6 db             	movzbl %bl,%ebx
  80136b:	29 d8                	sub    %ebx,%eax
  80136d:	eb 11                	jmp    801380 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80136f:	83 e9 01             	sub    $0x1,%ecx
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
  801377:	85 c9                	test   %ecx,%ecx
  801379:	75 d6                	jne    801351 <memcmp+0x1f>
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801380:	5b                   	pop    %ebx
  801381:	5e                   	pop    %esi
  801382:	5f                   	pop    %edi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80138b:	89 c2                	mov    %eax,%edx
  80138d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801390:	39 d0                	cmp    %edx,%eax
  801392:	73 15                	jae    8013a9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801394:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801398:	38 08                	cmp    %cl,(%eax)
  80139a:	75 06                	jne    8013a2 <memfind+0x1d>
  80139c:	eb 0b                	jmp    8013a9 <memfind+0x24>
  80139e:	38 08                	cmp    %cl,(%eax)
  8013a0:	74 07                	je     8013a9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013a2:	83 c0 01             	add    $0x1,%eax
  8013a5:	39 c2                	cmp    %eax,%edx
  8013a7:	77 f5                	ja     80139e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	57                   	push   %edi
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 04             	sub    $0x4,%esp
  8013b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013ba:	0f b6 02             	movzbl (%edx),%eax
  8013bd:	3c 20                	cmp    $0x20,%al
  8013bf:	74 04                	je     8013c5 <strtol+0x1a>
  8013c1:	3c 09                	cmp    $0x9,%al
  8013c3:	75 0e                	jne    8013d3 <strtol+0x28>
		s++;
  8013c5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013c8:	0f b6 02             	movzbl (%edx),%eax
  8013cb:	3c 20                	cmp    $0x20,%al
  8013cd:	74 f6                	je     8013c5 <strtol+0x1a>
  8013cf:	3c 09                	cmp    $0x9,%al
  8013d1:	74 f2                	je     8013c5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013d3:	3c 2b                	cmp    $0x2b,%al
  8013d5:	75 0c                	jne    8013e3 <strtol+0x38>
		s++;
  8013d7:	83 c2 01             	add    $0x1,%edx
  8013da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8013e1:	eb 15                	jmp    8013f8 <strtol+0x4d>
	else if (*s == '-')
  8013e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8013ea:	3c 2d                	cmp    $0x2d,%al
  8013ec:	75 0a                	jne    8013f8 <strtol+0x4d>
		s++, neg = 1;
  8013ee:	83 c2 01             	add    $0x1,%edx
  8013f1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8013f8:	85 db                	test   %ebx,%ebx
  8013fa:	0f 94 c0             	sete   %al
  8013fd:	74 05                	je     801404 <strtol+0x59>
  8013ff:	83 fb 10             	cmp    $0x10,%ebx
  801402:	75 18                	jne    80141c <strtol+0x71>
  801404:	80 3a 30             	cmpb   $0x30,(%edx)
  801407:	75 13                	jne    80141c <strtol+0x71>
  801409:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80140d:	8d 76 00             	lea    0x0(%esi),%esi
  801410:	75 0a                	jne    80141c <strtol+0x71>
		s += 2, base = 16;
  801412:	83 c2 02             	add    $0x2,%edx
  801415:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80141a:	eb 15                	jmp    801431 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80141c:	84 c0                	test   %al,%al
  80141e:	66 90                	xchg   %ax,%ax
  801420:	74 0f                	je     801431 <strtol+0x86>
  801422:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801427:	80 3a 30             	cmpb   $0x30,(%edx)
  80142a:	75 05                	jne    801431 <strtol+0x86>
		s++, base = 8;
  80142c:	83 c2 01             	add    $0x1,%edx
  80142f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801431:	b8 00 00 00 00       	mov    $0x0,%eax
  801436:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801438:	0f b6 0a             	movzbl (%edx),%ecx
  80143b:	89 cf                	mov    %ecx,%edi
  80143d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801440:	80 fb 09             	cmp    $0x9,%bl
  801443:	77 08                	ja     80144d <strtol+0xa2>
			dig = *s - '0';
  801445:	0f be c9             	movsbl %cl,%ecx
  801448:	83 e9 30             	sub    $0x30,%ecx
  80144b:	eb 1e                	jmp    80146b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80144d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801450:	80 fb 19             	cmp    $0x19,%bl
  801453:	77 08                	ja     80145d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801455:	0f be c9             	movsbl %cl,%ecx
  801458:	83 e9 57             	sub    $0x57,%ecx
  80145b:	eb 0e                	jmp    80146b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80145d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801460:	80 fb 19             	cmp    $0x19,%bl
  801463:	77 15                	ja     80147a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801465:	0f be c9             	movsbl %cl,%ecx
  801468:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80146b:	39 f1                	cmp    %esi,%ecx
  80146d:	7d 0b                	jge    80147a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80146f:	83 c2 01             	add    $0x1,%edx
  801472:	0f af c6             	imul   %esi,%eax
  801475:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801478:	eb be                	jmp    801438 <strtol+0x8d>
  80147a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80147c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801480:	74 05                	je     801487 <strtol+0xdc>
		*endptr = (char *) s;
  801482:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801485:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801487:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80148b:	74 04                	je     801491 <strtol+0xe6>
  80148d:	89 c8                	mov    %ecx,%eax
  80148f:	f7 d8                	neg    %eax
}
  801491:	83 c4 04             	add    $0x4,%esp
  801494:	5b                   	pop    %ebx
  801495:	5e                   	pop    %esi
  801496:	5f                   	pop    %edi
  801497:	5d                   	pop    %ebp
  801498:	c3                   	ret    
  801499:	00 00                	add    %al,(%eax)
	...

0080149c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	89 1c 24             	mov    %ebx,(%esp)
  8014a5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b3:	89 d1                	mov    %edx,%ecx
  8014b5:	89 d3                	mov    %edx,%ebx
  8014b7:	89 d7                	mov    %edx,%edi
  8014b9:	51                   	push   %ecx
  8014ba:	52                   	push   %edx
  8014bb:	53                   	push   %ebx
  8014bc:	54                   	push   %esp
  8014bd:	55                   	push   %ebp
  8014be:	56                   	push   %esi
  8014bf:	57                   	push   %edi
  8014c0:	54                   	push   %esp
  8014c1:	5d                   	pop    %ebp
  8014c2:	8d 35 ca 14 80 00    	lea    0x8014ca,%esi
  8014c8:	0f 34                	sysenter 
  8014ca:	5f                   	pop    %edi
  8014cb:	5e                   	pop    %esi
  8014cc:	5d                   	pop    %ebp
  8014cd:	5c                   	pop    %esp
  8014ce:	5b                   	pop    %ebx
  8014cf:	5a                   	pop    %edx
  8014d0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014d1:	8b 1c 24             	mov    (%esp),%ebx
  8014d4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014d8:	89 ec                	mov    %ebp,%esp
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	89 1c 24             	mov    %ebx,(%esp)
  8014e5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f4:	89 c3                	mov    %eax,%ebx
  8014f6:	89 c7                	mov    %eax,%edi
  8014f8:	51                   	push   %ecx
  8014f9:	52                   	push   %edx
  8014fa:	53                   	push   %ebx
  8014fb:	54                   	push   %esp
  8014fc:	55                   	push   %ebp
  8014fd:	56                   	push   %esi
  8014fe:	57                   	push   %edi
  8014ff:	54                   	push   %esp
  801500:	5d                   	pop    %ebp
  801501:	8d 35 09 15 80 00    	lea    0x801509,%esi
  801507:	0f 34                	sysenter 
  801509:	5f                   	pop    %edi
  80150a:	5e                   	pop    %esi
  80150b:	5d                   	pop    %ebp
  80150c:	5c                   	pop    %esp
  80150d:	5b                   	pop    %ebx
  80150e:	5a                   	pop    %edx
  80150f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801510:	8b 1c 24             	mov    (%esp),%ebx
  801513:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801517:	89 ec                	mov    %ebp,%esp
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    

0080151b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	89 1c 24             	mov    %ebx,(%esp)
  801524:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801528:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152d:	b8 13 00 00 00       	mov    $0x13,%eax
  801532:	8b 55 08             	mov    0x8(%ebp),%edx
  801535:	89 cb                	mov    %ecx,%ebx
  801537:	89 cf                	mov    %ecx,%edi
  801539:	51                   	push   %ecx
  80153a:	52                   	push   %edx
  80153b:	53                   	push   %ebx
  80153c:	54                   	push   %esp
  80153d:	55                   	push   %ebp
  80153e:	56                   	push   %esi
  80153f:	57                   	push   %edi
  801540:	54                   	push   %esp
  801541:	5d                   	pop    %ebp
  801542:	8d 35 4a 15 80 00    	lea    0x80154a,%esi
  801548:	0f 34                	sysenter 
  80154a:	5f                   	pop    %edi
  80154b:	5e                   	pop    %esi
  80154c:	5d                   	pop    %ebp
  80154d:	5c                   	pop    %esp
  80154e:	5b                   	pop    %ebx
  80154f:	5a                   	pop    %edx
  801550:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801551:	8b 1c 24             	mov    (%esp),%ebx
  801554:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801558:	89 ec                	mov    %ebp,%esp
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	89 1c 24             	mov    %ebx,(%esp)
  801565:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801569:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156e:	b8 12 00 00 00       	mov    $0x12,%eax
  801573:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801576:	8b 55 08             	mov    0x8(%ebp),%edx
  801579:	89 df                	mov    %ebx,%edi
  80157b:	51                   	push   %ecx
  80157c:	52                   	push   %edx
  80157d:	53                   	push   %ebx
  80157e:	54                   	push   %esp
  80157f:	55                   	push   %ebp
  801580:	56                   	push   %esi
  801581:	57                   	push   %edi
  801582:	54                   	push   %esp
  801583:	5d                   	pop    %ebp
  801584:	8d 35 8c 15 80 00    	lea    0x80158c,%esi
  80158a:	0f 34                	sysenter 
  80158c:	5f                   	pop    %edi
  80158d:	5e                   	pop    %esi
  80158e:	5d                   	pop    %ebp
  80158f:	5c                   	pop    %esp
  801590:	5b                   	pop    %ebx
  801591:	5a                   	pop    %edx
  801592:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801593:	8b 1c 24             	mov    (%esp),%ebx
  801596:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80159a:	89 ec                	mov    %ebp,%esp
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	89 1c 24             	mov    %ebx,(%esp)
  8015a7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b0:	b8 11 00 00 00       	mov    $0x11,%eax
  8015b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8015bb:	89 df                	mov    %ebx,%edi
  8015bd:	51                   	push   %ecx
  8015be:	52                   	push   %edx
  8015bf:	53                   	push   %ebx
  8015c0:	54                   	push   %esp
  8015c1:	55                   	push   %ebp
  8015c2:	56                   	push   %esi
  8015c3:	57                   	push   %edi
  8015c4:	54                   	push   %esp
  8015c5:	5d                   	pop    %ebp
  8015c6:	8d 35 ce 15 80 00    	lea    0x8015ce,%esi
  8015cc:	0f 34                	sysenter 
  8015ce:	5f                   	pop    %edi
  8015cf:	5e                   	pop    %esi
  8015d0:	5d                   	pop    %ebp
  8015d1:	5c                   	pop    %esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5a                   	pop    %edx
  8015d4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8015d5:	8b 1c 24             	mov    (%esp),%ebx
  8015d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015dc:	89 ec                	mov    %ebp,%esp
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	89 1c 24             	mov    %ebx,(%esp)
  8015e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015ed:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8015fe:	51                   	push   %ecx
  8015ff:	52                   	push   %edx
  801600:	53                   	push   %ebx
  801601:	54                   	push   %esp
  801602:	55                   	push   %ebp
  801603:	56                   	push   %esi
  801604:	57                   	push   %edi
  801605:	54                   	push   %esp
  801606:	5d                   	pop    %ebp
  801607:	8d 35 0f 16 80 00    	lea    0x80160f,%esi
  80160d:	0f 34                	sysenter 
  80160f:	5f                   	pop    %edi
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	5c                   	pop    %esp
  801613:	5b                   	pop    %ebx
  801614:	5a                   	pop    %edx
  801615:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801616:	8b 1c 24             	mov    (%esp),%ebx
  801619:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80161d:	89 ec                	mov    %ebp,%esp
  80161f:	5d                   	pop    %ebp
  801620:	c3                   	ret    

00801621 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	83 ec 28             	sub    $0x28,%esp
  801627:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80162a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80162d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801632:	b8 0f 00 00 00       	mov    $0xf,%eax
  801637:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163a:	8b 55 08             	mov    0x8(%ebp),%edx
  80163d:	89 df                	mov    %ebx,%edi
  80163f:	51                   	push   %ecx
  801640:	52                   	push   %edx
  801641:	53                   	push   %ebx
  801642:	54                   	push   %esp
  801643:	55                   	push   %ebp
  801644:	56                   	push   %esi
  801645:	57                   	push   %edi
  801646:	54                   	push   %esp
  801647:	5d                   	pop    %ebp
  801648:	8d 35 50 16 80 00    	lea    0x801650,%esi
  80164e:	0f 34                	sysenter 
  801650:	5f                   	pop    %edi
  801651:	5e                   	pop    %esi
  801652:	5d                   	pop    %ebp
  801653:	5c                   	pop    %esp
  801654:	5b                   	pop    %ebx
  801655:	5a                   	pop    %edx
  801656:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801657:	85 c0                	test   %eax,%eax
  801659:	7e 28                	jle    801683 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80165b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80165f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801666:	00 
  801667:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  80166e:	00 
  80166f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801676:	00 
  801677:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  80167e:	e8 45 f0 ff ff       	call   8006c8 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801683:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801686:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801689:	89 ec                	mov    %ebp,%esp
  80168b:	5d                   	pop    %ebp
  80168c:	c3                   	ret    

0080168d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	89 1c 24             	mov    %ebx,(%esp)
  801696:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80169a:	ba 00 00 00 00       	mov    $0x0,%edx
  80169f:	b8 15 00 00 00       	mov    $0x15,%eax
  8016a4:	89 d1                	mov    %edx,%ecx
  8016a6:	89 d3                	mov    %edx,%ebx
  8016a8:	89 d7                	mov    %edx,%edi
  8016aa:	51                   	push   %ecx
  8016ab:	52                   	push   %edx
  8016ac:	53                   	push   %ebx
  8016ad:	54                   	push   %esp
  8016ae:	55                   	push   %ebp
  8016af:	56                   	push   %esi
  8016b0:	57                   	push   %edi
  8016b1:	54                   	push   %esp
  8016b2:	5d                   	pop    %ebp
  8016b3:	8d 35 bb 16 80 00    	lea    0x8016bb,%esi
  8016b9:	0f 34                	sysenter 
  8016bb:	5f                   	pop    %edi
  8016bc:	5e                   	pop    %esi
  8016bd:	5d                   	pop    %ebp
  8016be:	5c                   	pop    %esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5a                   	pop    %edx
  8016c1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8016c2:	8b 1c 24             	mov    (%esp),%ebx
  8016c5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016c9:	89 ec                	mov    %ebp,%esp
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 08             	sub    $0x8,%esp
  8016d3:	89 1c 24             	mov    %ebx,(%esp)
  8016d6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8016da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016df:	b8 14 00 00 00       	mov    $0x14,%eax
  8016e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e7:	89 cb                	mov    %ecx,%ebx
  8016e9:	89 cf                	mov    %ecx,%edi
  8016eb:	51                   	push   %ecx
  8016ec:	52                   	push   %edx
  8016ed:	53                   	push   %ebx
  8016ee:	54                   	push   %esp
  8016ef:	55                   	push   %ebp
  8016f0:	56                   	push   %esi
  8016f1:	57                   	push   %edi
  8016f2:	54                   	push   %esp
  8016f3:	5d                   	pop    %ebp
  8016f4:	8d 35 fc 16 80 00    	lea    0x8016fc,%esi
  8016fa:	0f 34                	sysenter 
  8016fc:	5f                   	pop    %edi
  8016fd:	5e                   	pop    %esi
  8016fe:	5d                   	pop    %ebp
  8016ff:	5c                   	pop    %esp
  801700:	5b                   	pop    %ebx
  801701:	5a                   	pop    %edx
  801702:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801703:	8b 1c 24             	mov    (%esp),%ebx
  801706:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80170a:	89 ec                	mov    %ebp,%esp
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 28             	sub    $0x28,%esp
  801714:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801717:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80171a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80171f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801724:	8b 55 08             	mov    0x8(%ebp),%edx
  801727:	89 cb                	mov    %ecx,%ebx
  801729:	89 cf                	mov    %ecx,%edi
  80172b:	51                   	push   %ecx
  80172c:	52                   	push   %edx
  80172d:	53                   	push   %ebx
  80172e:	54                   	push   %esp
  80172f:	55                   	push   %ebp
  801730:	56                   	push   %esi
  801731:	57                   	push   %edi
  801732:	54                   	push   %esp
  801733:	5d                   	pop    %ebp
  801734:	8d 35 3c 17 80 00    	lea    0x80173c,%esi
  80173a:	0f 34                	sysenter 
  80173c:	5f                   	pop    %edi
  80173d:	5e                   	pop    %esi
  80173e:	5d                   	pop    %ebp
  80173f:	5c                   	pop    %esp
  801740:	5b                   	pop    %ebx
  801741:	5a                   	pop    %edx
  801742:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801743:	85 c0                	test   %eax,%eax
  801745:	7e 28                	jle    80176f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801747:	89 44 24 10          	mov    %eax,0x10(%esp)
  80174b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801752:	00 
  801753:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  80175a:	00 
  80175b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801762:	00 
  801763:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  80176a:	e8 59 ef ff ff       	call   8006c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80176f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801772:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801775:	89 ec                	mov    %ebp,%esp
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 08             	sub    $0x8,%esp
  80177f:	89 1c 24             	mov    %ebx,(%esp)
  801782:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801786:	b8 0d 00 00 00       	mov    $0xd,%eax
  80178b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80178e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801794:	8b 55 08             	mov    0x8(%ebp),%edx
  801797:	51                   	push   %ecx
  801798:	52                   	push   %edx
  801799:	53                   	push   %ebx
  80179a:	54                   	push   %esp
  80179b:	55                   	push   %ebp
  80179c:	56                   	push   %esi
  80179d:	57                   	push   %edi
  80179e:	54                   	push   %esp
  80179f:	5d                   	pop    %ebp
  8017a0:	8d 35 a8 17 80 00    	lea    0x8017a8,%esi
  8017a6:	0f 34                	sysenter 
  8017a8:	5f                   	pop    %edi
  8017a9:	5e                   	pop    %esi
  8017aa:	5d                   	pop    %ebp
  8017ab:	5c                   	pop    %esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5a                   	pop    %edx
  8017ae:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017af:	8b 1c 24             	mov    (%esp),%ebx
  8017b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017b6:	89 ec                	mov    %ebp,%esp
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	83 ec 28             	sub    $0x28,%esp
  8017c0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017c3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8017c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017cb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8017d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d6:	89 df                	mov    %ebx,%edi
  8017d8:	51                   	push   %ecx
  8017d9:	52                   	push   %edx
  8017da:	53                   	push   %ebx
  8017db:	54                   	push   %esp
  8017dc:	55                   	push   %ebp
  8017dd:	56                   	push   %esi
  8017de:	57                   	push   %edi
  8017df:	54                   	push   %esp
  8017e0:	5d                   	pop    %ebp
  8017e1:	8d 35 e9 17 80 00    	lea    0x8017e9,%esi
  8017e7:	0f 34                	sysenter 
  8017e9:	5f                   	pop    %edi
  8017ea:	5e                   	pop    %esi
  8017eb:	5d                   	pop    %ebp
  8017ec:	5c                   	pop    %esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5a                   	pop    %edx
  8017ef:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	7e 28                	jle    80181c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017f8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8017ff:	00 
  801800:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  801807:	00 
  801808:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80180f:	00 
  801810:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  801817:	e8 ac ee ff ff       	call   8006c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80181c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80181f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801822:	89 ec                	mov    %ebp,%esp
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 28             	sub    $0x28,%esp
  80182c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80182f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801832:	bb 00 00 00 00       	mov    $0x0,%ebx
  801837:	b8 0a 00 00 00       	mov    $0xa,%eax
  80183c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183f:	8b 55 08             	mov    0x8(%ebp),%edx
  801842:	89 df                	mov    %ebx,%edi
  801844:	51                   	push   %ecx
  801845:	52                   	push   %edx
  801846:	53                   	push   %ebx
  801847:	54                   	push   %esp
  801848:	55                   	push   %ebp
  801849:	56                   	push   %esi
  80184a:	57                   	push   %edi
  80184b:	54                   	push   %esp
  80184c:	5d                   	pop    %ebp
  80184d:	8d 35 55 18 80 00    	lea    0x801855,%esi
  801853:	0f 34                	sysenter 
  801855:	5f                   	pop    %edi
  801856:	5e                   	pop    %esi
  801857:	5d                   	pop    %ebp
  801858:	5c                   	pop    %esp
  801859:	5b                   	pop    %ebx
  80185a:	5a                   	pop    %edx
  80185b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80185c:	85 c0                	test   %eax,%eax
  80185e:	7e 28                	jle    801888 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801860:	89 44 24 10          	mov    %eax,0x10(%esp)
  801864:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80186b:	00 
  80186c:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  801873:	00 
  801874:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80187b:	00 
  80187c:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  801883:	e8 40 ee ff ff       	call   8006c8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801888:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80188b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80188e:	89 ec                	mov    %ebp,%esp
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	83 ec 28             	sub    $0x28,%esp
  801898:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80189b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80189e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a3:	b8 09 00 00 00       	mov    $0x9,%eax
  8018a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ae:	89 df                	mov    %ebx,%edi
  8018b0:	51                   	push   %ecx
  8018b1:	52                   	push   %edx
  8018b2:	53                   	push   %ebx
  8018b3:	54                   	push   %esp
  8018b4:	55                   	push   %ebp
  8018b5:	56                   	push   %esi
  8018b6:	57                   	push   %edi
  8018b7:	54                   	push   %esp
  8018b8:	5d                   	pop    %ebp
  8018b9:	8d 35 c1 18 80 00    	lea    0x8018c1,%esi
  8018bf:	0f 34                	sysenter 
  8018c1:	5f                   	pop    %edi
  8018c2:	5e                   	pop    %esi
  8018c3:	5d                   	pop    %ebp
  8018c4:	5c                   	pop    %esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5a                   	pop    %edx
  8018c7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	7e 28                	jle    8018f4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018d0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8018d7:	00 
  8018d8:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  8018df:	00 
  8018e0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8018e7:	00 
  8018e8:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  8018ef:	e8 d4 ed ff ff       	call   8006c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8018f4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018f7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018fa:	89 ec                	mov    %ebp,%esp
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 28             	sub    $0x28,%esp
  801904:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801907:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80190a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80190f:	b8 07 00 00 00       	mov    $0x7,%eax
  801914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801917:	8b 55 08             	mov    0x8(%ebp),%edx
  80191a:	89 df                	mov    %ebx,%edi
  80191c:	51                   	push   %ecx
  80191d:	52                   	push   %edx
  80191e:	53                   	push   %ebx
  80191f:	54                   	push   %esp
  801920:	55                   	push   %ebp
  801921:	56                   	push   %esi
  801922:	57                   	push   %edi
  801923:	54                   	push   %esp
  801924:	5d                   	pop    %ebp
  801925:	8d 35 2d 19 80 00    	lea    0x80192d,%esi
  80192b:	0f 34                	sysenter 
  80192d:	5f                   	pop    %edi
  80192e:	5e                   	pop    %esi
  80192f:	5d                   	pop    %ebp
  801930:	5c                   	pop    %esp
  801931:	5b                   	pop    %ebx
  801932:	5a                   	pop    %edx
  801933:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801934:	85 c0                	test   %eax,%eax
  801936:	7e 28                	jle    801960 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801938:	89 44 24 10          	mov    %eax,0x10(%esp)
  80193c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801943:	00 
  801944:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  80194b:	00 
  80194c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801953:	00 
  801954:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  80195b:	e8 68 ed ff ff       	call   8006c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801960:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801963:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801966:	89 ec                	mov    %ebp,%esp
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 28             	sub    $0x28,%esp
  801970:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801973:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801976:	8b 7d 18             	mov    0x18(%ebp),%edi
  801979:	0b 7d 14             	or     0x14(%ebp),%edi
  80197c:	b8 06 00 00 00       	mov    $0x6,%eax
  801981:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801984:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801987:	8b 55 08             	mov    0x8(%ebp),%edx
  80198a:	51                   	push   %ecx
  80198b:	52                   	push   %edx
  80198c:	53                   	push   %ebx
  80198d:	54                   	push   %esp
  80198e:	55                   	push   %ebp
  80198f:	56                   	push   %esi
  801990:	57                   	push   %edi
  801991:	54                   	push   %esp
  801992:	5d                   	pop    %ebp
  801993:	8d 35 9b 19 80 00    	lea    0x80199b,%esi
  801999:	0f 34                	sysenter 
  80199b:	5f                   	pop    %edi
  80199c:	5e                   	pop    %esi
  80199d:	5d                   	pop    %ebp
  80199e:	5c                   	pop    %esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5a                   	pop    %edx
  8019a1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	7e 28                	jle    8019ce <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8019a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019aa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8019b1:	00 
  8019b2:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  8019b9:	00 
  8019ba:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8019c1:	00 
  8019c2:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  8019c9:	e8 fa ec ff ff       	call   8006c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8019ce:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019d4:	89 ec                	mov    %ebp,%esp
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 28             	sub    $0x28,%esp
  8019de:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019e1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8019e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8019ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8019f7:	51                   	push   %ecx
  8019f8:	52                   	push   %edx
  8019f9:	53                   	push   %ebx
  8019fa:	54                   	push   %esp
  8019fb:	55                   	push   %ebp
  8019fc:	56                   	push   %esi
  8019fd:	57                   	push   %edi
  8019fe:	54                   	push   %esp
  8019ff:	5d                   	pop    %ebp
  801a00:	8d 35 08 1a 80 00    	lea    0x801a08,%esi
  801a06:	0f 34                	sysenter 
  801a08:	5f                   	pop    %edi
  801a09:	5e                   	pop    %esi
  801a0a:	5d                   	pop    %ebp
  801a0b:	5c                   	pop    %esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5a                   	pop    %edx
  801a0e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	7e 28                	jle    801a3b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801a13:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a17:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801a1e:	00 
  801a1f:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  801a26:	00 
  801a27:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801a2e:	00 
  801a2f:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  801a36:	e8 8d ec ff ff       	call   8006c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801a3b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a41:	89 ec                	mov    %ebp,%esp
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
  801a4b:	89 1c 24             	mov    %ebx,(%esp)
  801a4e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801a52:	ba 00 00 00 00       	mov    $0x0,%edx
  801a57:	b8 0c 00 00 00       	mov    $0xc,%eax
  801a5c:	89 d1                	mov    %edx,%ecx
  801a5e:	89 d3                	mov    %edx,%ebx
  801a60:	89 d7                	mov    %edx,%edi
  801a62:	51                   	push   %ecx
  801a63:	52                   	push   %edx
  801a64:	53                   	push   %ebx
  801a65:	54                   	push   %esp
  801a66:	55                   	push   %ebp
  801a67:	56                   	push   %esi
  801a68:	57                   	push   %edi
  801a69:	54                   	push   %esp
  801a6a:	5d                   	pop    %ebp
  801a6b:	8d 35 73 1a 80 00    	lea    0x801a73,%esi
  801a71:	0f 34                	sysenter 
  801a73:	5f                   	pop    %edi
  801a74:	5e                   	pop    %esi
  801a75:	5d                   	pop    %ebp
  801a76:	5c                   	pop    %esp
  801a77:	5b                   	pop    %ebx
  801a78:	5a                   	pop    %edx
  801a79:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801a7a:	8b 1c 24             	mov    (%esp),%ebx
  801a7d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a81:	89 ec                	mov    %ebp,%esp
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	83 ec 08             	sub    $0x8,%esp
  801a8b:	89 1c 24             	mov    %ebx,(%esp)
  801a8e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801a92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a97:	b8 04 00 00 00       	mov    $0x4,%eax
  801a9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa2:	89 df                	mov    %ebx,%edi
  801aa4:	51                   	push   %ecx
  801aa5:	52                   	push   %edx
  801aa6:	53                   	push   %ebx
  801aa7:	54                   	push   %esp
  801aa8:	55                   	push   %ebp
  801aa9:	56                   	push   %esi
  801aaa:	57                   	push   %edi
  801aab:	54                   	push   %esp
  801aac:	5d                   	pop    %ebp
  801aad:	8d 35 b5 1a 80 00    	lea    0x801ab5,%esi
  801ab3:	0f 34                	sysenter 
  801ab5:	5f                   	pop    %edi
  801ab6:	5e                   	pop    %esi
  801ab7:	5d                   	pop    %ebp
  801ab8:	5c                   	pop    %esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5a                   	pop    %edx
  801abb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801abc:	8b 1c 24             	mov    (%esp),%ebx
  801abf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ac3:	89 ec                	mov    %ebp,%esp
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    

00801ac7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	83 ec 08             	sub    $0x8,%esp
  801acd:	89 1c 24             	mov    %ebx,(%esp)
  801ad0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad9:	b8 02 00 00 00       	mov    $0x2,%eax
  801ade:	89 d1                	mov    %edx,%ecx
  801ae0:	89 d3                	mov    %edx,%ebx
  801ae2:	89 d7                	mov    %edx,%edi
  801ae4:	51                   	push   %ecx
  801ae5:	52                   	push   %edx
  801ae6:	53                   	push   %ebx
  801ae7:	54                   	push   %esp
  801ae8:	55                   	push   %ebp
  801ae9:	56                   	push   %esi
  801aea:	57                   	push   %edi
  801aeb:	54                   	push   %esp
  801aec:	5d                   	pop    %ebp
  801aed:	8d 35 f5 1a 80 00    	lea    0x801af5,%esi
  801af3:	0f 34                	sysenter 
  801af5:	5f                   	pop    %edi
  801af6:	5e                   	pop    %esi
  801af7:	5d                   	pop    %ebp
  801af8:	5c                   	pop    %esp
  801af9:	5b                   	pop    %ebx
  801afa:	5a                   	pop    %edx
  801afb:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801afc:	8b 1c 24             	mov    (%esp),%ebx
  801aff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b03:	89 ec                	mov    %ebp,%esp
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 28             	sub    $0x28,%esp
  801b0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b10:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801b13:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b18:	b8 03 00 00 00       	mov    $0x3,%eax
  801b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b20:	89 cb                	mov    %ecx,%ebx
  801b22:	89 cf                	mov    %ecx,%edi
  801b24:	51                   	push   %ecx
  801b25:	52                   	push   %edx
  801b26:	53                   	push   %ebx
  801b27:	54                   	push   %esp
  801b28:	55                   	push   %ebp
  801b29:	56                   	push   %esi
  801b2a:	57                   	push   %edi
  801b2b:	54                   	push   %esp
  801b2c:	5d                   	pop    %ebp
  801b2d:	8d 35 35 1b 80 00    	lea    0x801b35,%esi
  801b33:	0f 34                	sysenter 
  801b35:	5f                   	pop    %edi
  801b36:	5e                   	pop    %esi
  801b37:	5d                   	pop    %ebp
  801b38:	5c                   	pop    %esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5a                   	pop    %edx
  801b3b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	7e 28                	jle    801b68 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801b40:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b44:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801b4b:	00 
  801b4c:	c7 44 24 08 c0 39 80 	movl   $0x8039c0,0x8(%esp)
  801b53:	00 
  801b54:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801b5b:	00 
  801b5c:	c7 04 24 dd 39 80 00 	movl   $0x8039dd,(%esp)
  801b63:	e8 60 eb ff ff       	call   8006c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801b68:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b6b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b6e:	89 ec                	mov    %ebp,%esp
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    
	...

00801b74 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801b7a:	c7 44 24 08 eb 39 80 	movl   $0x8039eb,0x8(%esp)
  801b81:	00 
  801b82:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801b89:	00 
  801b8a:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801b91:	e8 32 eb ff ff       	call   8006c8 <_panic>

00801b96 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  801b9f:	c7 04 24 eb 1d 80 00 	movl   $0x801deb,(%esp)
  801ba6:	e8 89 12 00 00       	call   802e34 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801bab:	ba 08 00 00 00       	mov    $0x8,%edx
  801bb0:	89 d0                	mov    %edx,%eax
  801bb2:	cd 30                	int    $0x30
  801bb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	79 20                	jns    801bdb <fork+0x45>
		panic("sys_exofork: %e", envid);
  801bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbf:	c7 44 24 08 0c 3a 80 	movl   $0x803a0c,0x8(%esp)
  801bc6:	00 
  801bc7:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  801bce:	00 
  801bcf:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801bd6:	e8 ed ea ff ff       	call   8006c8 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801bdb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801be0:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801be5:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801bea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801bee:	75 20                	jne    801c10 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801bf0:	e8 d2 fe ff ff       	call   801ac7 <sys_getenvid>
  801bf5:	25 ff 03 00 00       	and    $0x3ff,%eax
  801bfa:	89 c2                	mov    %eax,%edx
  801bfc:	c1 e2 07             	shl    $0x7,%edx
  801bff:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801c06:	a3 24 50 80 00       	mov    %eax,0x805024
		return 0;
  801c0b:	e9 d0 01 00 00       	jmp    801de0 <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801c10:	89 d8                	mov    %ebx,%eax
  801c12:	c1 e8 16             	shr    $0x16,%eax
  801c15:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801c18:	a8 01                	test   $0x1,%al
  801c1a:	0f 84 0d 01 00 00    	je     801d2d <fork+0x197>
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	c1 e8 0c             	shr    $0xc,%eax
  801c25:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801c28:	f6 c2 01             	test   $0x1,%dl
  801c2b:	0f 84 fc 00 00 00    	je     801d2d <fork+0x197>
  801c31:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801c34:	f6 c2 04             	test   $0x4,%dl
  801c37:	0f 84 f0 00 00 00    	je     801d2d <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  801c3d:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	c1 ea 0c             	shr    $0xc,%edx
  801c45:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801c48:	f6 c2 01             	test   $0x1,%dl
  801c4b:	0f 84 dc 00 00 00    	je     801d2d <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  801c51:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801c57:	0f 84 8d 00 00 00    	je     801cea <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  801c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c60:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801c67:	00 
  801c68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7e:	e8 e7 fc ff ff       	call   80196a <sys_page_map>
               if(r<0)
  801c83:	85 c0                	test   %eax,%eax
  801c85:	79 1c                	jns    801ca3 <fork+0x10d>
                 panic("map failed");
  801c87:	c7 44 24 08 1c 3a 80 	movl   $0x803a1c,0x8(%esp)
  801c8e:	00 
  801c8f:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801c96:	00 
  801c97:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801c9e:	e8 25 ea ff ff       	call   8006c8 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  801ca3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801caa:	00 
  801cab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cb2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cb9:	00 
  801cba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc5:	e8 a0 fc ff ff       	call   80196a <sys_page_map>
               if(r<0)
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	79 5f                	jns    801d2d <fork+0x197>
                 panic("map failed");
  801cce:	c7 44 24 08 1c 3a 80 	movl   $0x803a1c,0x8(%esp)
  801cd5:	00 
  801cd6:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801cdd:	00 
  801cde:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801ce5:	e8 de e9 ff ff       	call   8006c8 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801cea:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801cf1:	00 
  801cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cf6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cf9:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d08:	e8 5d fc ff ff       	call   80196a <sys_page_map>
               if(r<0)
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	79 1c                	jns    801d2d <fork+0x197>
                 panic("map failed");
  801d11:	c7 44 24 08 1c 3a 80 	movl   $0x803a1c,0x8(%esp)
  801d18:	00 
  801d19:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801d20:	00 
  801d21:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801d28:	e8 9b e9 ff ff       	call   8006c8 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801d2d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d33:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801d39:	0f 85 d1 fe ff ff    	jne    801c10 <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801d3f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d46:	00 
  801d47:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801d4e:	ee 
  801d4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d52:	89 04 24             	mov    %eax,(%esp)
  801d55:	e8 7e fc ff ff       	call   8019d8 <sys_page_alloc>
        if(r < 0)
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	79 1c                	jns    801d7a <fork+0x1e4>
            panic("alloc failed");
  801d5e:	c7 44 24 08 27 3a 80 	movl   $0x803a27,0x8(%esp)
  801d65:	00 
  801d66:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801d6d:	00 
  801d6e:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801d75:	e8 4e e9 ff ff       	call   8006c8 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801d7a:	c7 44 24 04 80 2e 80 	movl   $0x802e80,0x4(%esp)
  801d81:	00 
  801d82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d85:	89 14 24             	mov    %edx,(%esp)
  801d88:	e8 2d fa ff ff       	call   8017ba <sys_env_set_pgfault_upcall>
        if(r < 0)
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	79 1c                	jns    801dad <fork+0x217>
            panic("set pgfault upcall failed");
  801d91:	c7 44 24 08 34 3a 80 	movl   $0x803a34,0x8(%esp)
  801d98:	00 
  801d99:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801da0:	00 
  801da1:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801da8:	e8 1b e9 ff ff       	call   8006c8 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801dad:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801db4:	00 
  801db5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db8:	89 04 24             	mov    %eax,(%esp)
  801dbb:	e8 d2 fa ff ff       	call   801892 <sys_env_set_status>
        if(r < 0)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	79 1c                	jns    801de0 <fork+0x24a>
            panic("set status failed");
  801dc4:	c7 44 24 08 4e 3a 80 	movl   $0x803a4e,0x8(%esp)
  801dcb:	00 
  801dcc:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801dd3:	00 
  801dd4:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801ddb:	e8 e8 e8 ff ff       	call   8006c8 <_panic>
        return envid;
	//panic("fork not implemented");
}
  801de0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801de3:	83 c4 3c             	add    $0x3c,%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	53                   	push   %ebx
  801def:	83 ec 24             	sub    $0x24,%esp
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801df5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801df7:	89 da                	mov    %ebx,%edx
  801df9:	c1 ea 0c             	shr    $0xc,%edx
  801dfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  801e03:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801e07:	74 08                	je     801e11 <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801e09:	f7 c2 05 08 00 00    	test   $0x805,%edx
  801e0f:	75 1c                	jne    801e2d <pgfault+0x42>
           panic("pgfault error");
  801e11:	c7 44 24 08 60 3a 80 	movl   $0x803a60,0x8(%esp)
  801e18:	00 
  801e19:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801e20:	00 
  801e21:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801e28:	e8 9b e8 ff ff       	call   8006c8 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e2d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e34:	00 
  801e35:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801e3c:	00 
  801e3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e44:	e8 8f fb ff ff       	call   8019d8 <sys_page_alloc>
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	79 20                	jns    801e6d <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  801e4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e51:	c7 44 24 08 6e 3a 80 	movl   $0x803a6e,0x8(%esp)
  801e58:	00 
  801e59:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801e60:	00 
  801e61:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801e68:	e8 5b e8 ff ff       	call   8006c8 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  801e6d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801e73:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801e7a:	00 
  801e7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e7f:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801e86:	e8 0a f4 ff ff       	call   801295 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801e8b:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801e92:	00 
  801e93:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e9e:	00 
  801e9f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801ea6:	00 
  801ea7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eae:	e8 b7 fa ff ff       	call   80196a <sys_page_map>
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	79 20                	jns    801ed7 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801eb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebb:	c7 44 24 08 d8 34 80 	movl   $0x8034d8,0x8(%esp)
  801ec2:	00 
  801ec3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801eca:	00 
  801ecb:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801ed2:	e8 f1 e7 ff ff       	call   8006c8 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801ed7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801ede:	00 
  801edf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee6:	e8 13 fa ff ff       	call   8018fe <sys_page_unmap>
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	79 20                	jns    801f0f <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  801eef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ef3:	c7 44 24 08 81 3a 80 	movl   $0x803a81,0x8(%esp)
  801efa:	00 
  801efb:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801f02:	00 
  801f03:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  801f0a:	e8 b9 e7 ff ff       	call   8006c8 <_panic>
	//panic("pgfault not implemented");
}
  801f0f:	83 c4 24             	add    $0x24,%esp
  801f12:	5b                   	pop    %ebx
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    
	...

00801f20 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f26:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801f2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f31:	39 ca                	cmp    %ecx,%edx
  801f33:	75 04                	jne    801f39 <ipc_find_env+0x19>
  801f35:	b0 00                	mov    $0x0,%al
  801f37:	eb 12                	jmp    801f4b <ipc_find_env+0x2b>
  801f39:	89 c2                	mov    %eax,%edx
  801f3b:	c1 e2 07             	shl    $0x7,%edx
  801f3e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801f45:	8b 12                	mov    (%edx),%edx
  801f47:	39 ca                	cmp    %ecx,%edx
  801f49:	75 10                	jne    801f5b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801f4b:	89 c2                	mov    %eax,%edx
  801f4d:	c1 e2 07             	shl    $0x7,%edx
  801f50:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801f57:	8b 00                	mov    (%eax),%eax
  801f59:	eb 0e                	jmp    801f69 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f5b:	83 c0 01             	add    $0x1,%eax
  801f5e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f63:	75 d4                	jne    801f39 <ipc_find_env+0x19>
  801f65:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    

00801f6b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	57                   	push   %edi
  801f6f:	56                   	push   %esi
  801f70:	53                   	push   %ebx
  801f71:	83 ec 1c             	sub    $0x1c,%esp
  801f74:	8b 75 08             	mov    0x8(%ebp),%esi
  801f77:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801f7d:	85 db                	test   %ebx,%ebx
  801f7f:	74 19                	je     801f9a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801f81:	8b 45 14             	mov    0x14(%ebp),%eax
  801f84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f90:	89 34 24             	mov    %esi,(%esp)
  801f93:	e8 e1 f7 ff ff       	call   801779 <sys_ipc_try_send>
  801f98:	eb 1b                	jmp    801fb5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801f9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fa1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801fa8:	ee 
  801fa9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fad:	89 34 24             	mov    %esi,(%esp)
  801fb0:	e8 c4 f7 ff ff       	call   801779 <sys_ipc_try_send>
           if(ret == 0)
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	74 28                	je     801fe1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801fb9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fbc:	74 1c                	je     801fda <ipc_send+0x6f>
              panic("ipc send error");
  801fbe:	c7 44 24 08 94 3a 80 	movl   $0x803a94,0x8(%esp)
  801fc5:	00 
  801fc6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801fcd:	00 
  801fce:	c7 04 24 a3 3a 80 00 	movl   $0x803aa3,(%esp)
  801fd5:	e8 ee e6 ff ff       	call   8006c8 <_panic>
           sys_yield();
  801fda:	e8 66 fa ff ff       	call   801a45 <sys_yield>
        }
  801fdf:	eb 9c                	jmp    801f7d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801fe1:	83 c4 1c             	add    $0x1c,%esp
  801fe4:	5b                   	pop    %ebx
  801fe5:	5e                   	pop    %esi
  801fe6:	5f                   	pop    %edi
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    

00801fe9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	56                   	push   %esi
  801fed:	53                   	push   %ebx
  801fee:	83 ec 10             	sub    $0x10,%esp
  801ff1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	75 0e                	jne    80200c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801ffe:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802005:	e8 04 f7 ff ff       	call   80170e <sys_ipc_recv>
  80200a:	eb 08                	jmp    802014 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80200c:	89 04 24             	mov    %eax,(%esp)
  80200f:	e8 fa f6 ff ff       	call   80170e <sys_ipc_recv>
        if(ret == 0){
  802014:	85 c0                	test   %eax,%eax
  802016:	75 26                	jne    80203e <ipc_recv+0x55>
           if(from_env_store)
  802018:	85 f6                	test   %esi,%esi
  80201a:	74 0a                	je     802026 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80201c:	a1 24 50 80 00       	mov    0x805024,%eax
  802021:	8b 40 78             	mov    0x78(%eax),%eax
  802024:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802026:	85 db                	test   %ebx,%ebx
  802028:	74 0a                	je     802034 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80202a:	a1 24 50 80 00       	mov    0x805024,%eax
  80202f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802032:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802034:	a1 24 50 80 00       	mov    0x805024,%eax
  802039:	8b 40 74             	mov    0x74(%eax),%eax
  80203c:	eb 14                	jmp    802052 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80203e:	85 f6                	test   %esi,%esi
  802040:	74 06                	je     802048 <ipc_recv+0x5f>
              *from_env_store = 0;
  802042:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802048:	85 db                	test   %ebx,%ebx
  80204a:	74 06                	je     802052 <ipc_recv+0x69>
              *perm_store = 0;
  80204c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    
  802059:	00 00                	add    %al,(%eax)
  80205b:	00 00                	add    %al,(%eax)
  80205d:	00 00                	add    %al,(%eax)
	...

00802060 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
  802066:	05 00 00 00 30       	add    $0x30000000,%eax
  80206b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    

00802070 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802076:	8b 45 08             	mov    0x8(%ebp),%eax
  802079:	89 04 24             	mov    %eax,(%esp)
  80207c:	e8 df ff ff ff       	call   802060 <fd2num>
  802081:	05 20 00 0d 00       	add    $0xd0020,%eax
  802086:	c1 e0 0c             	shl    $0xc,%eax
}
  802089:	c9                   	leave  
  80208a:	c3                   	ret    

0080208b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	57                   	push   %edi
  80208f:	56                   	push   %esi
  802090:	53                   	push   %ebx
  802091:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  802094:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  802099:	a8 01                	test   $0x1,%al
  80209b:	74 36                	je     8020d3 <fd_alloc+0x48>
  80209d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8020a2:	a8 01                	test   $0x1,%al
  8020a4:	74 2d                	je     8020d3 <fd_alloc+0x48>
  8020a6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8020ab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8020b0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8020b5:	89 c3                	mov    %eax,%ebx
  8020b7:	89 c2                	mov    %eax,%edx
  8020b9:	c1 ea 16             	shr    $0x16,%edx
  8020bc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8020bf:	f6 c2 01             	test   $0x1,%dl
  8020c2:	74 14                	je     8020d8 <fd_alloc+0x4d>
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	c1 ea 0c             	shr    $0xc,%edx
  8020c9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8020cc:	f6 c2 01             	test   $0x1,%dl
  8020cf:	75 10                	jne    8020e1 <fd_alloc+0x56>
  8020d1:	eb 05                	jmp    8020d8 <fd_alloc+0x4d>
  8020d3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8020d8:	89 1f                	mov    %ebx,(%edi)
  8020da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8020df:	eb 17                	jmp    8020f8 <fd_alloc+0x6d>
  8020e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8020e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8020eb:	75 c8                	jne    8020b5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8020ed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8020f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8020f8:	5b                   	pop    %ebx
  8020f9:	5e                   	pop    %esi
  8020fa:	5f                   	pop    %edi
  8020fb:	5d                   	pop    %ebp
  8020fc:	c3                   	ret    

008020fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8020fd:	55                   	push   %ebp
  8020fe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802100:	8b 45 08             	mov    0x8(%ebp),%eax
  802103:	83 f8 1f             	cmp    $0x1f,%eax
  802106:	77 36                	ja     80213e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802108:	05 00 00 0d 00       	add    $0xd0000,%eax
  80210d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  802110:	89 c2                	mov    %eax,%edx
  802112:	c1 ea 16             	shr    $0x16,%edx
  802115:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80211c:	f6 c2 01             	test   $0x1,%dl
  80211f:	74 1d                	je     80213e <fd_lookup+0x41>
  802121:	89 c2                	mov    %eax,%edx
  802123:	c1 ea 0c             	shr    $0xc,%edx
  802126:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80212d:	f6 c2 01             	test   $0x1,%dl
  802130:	74 0c                	je     80213e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  802132:	8b 55 0c             	mov    0xc(%ebp),%edx
  802135:	89 02                	mov    %eax,(%edx)
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80213c:	eb 05                	jmp    802143 <fd_lookup+0x46>
  80213e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80214e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802152:	8b 45 08             	mov    0x8(%ebp),%eax
  802155:	89 04 24             	mov    %eax,(%esp)
  802158:	e8 a0 ff ff ff       	call   8020fd <fd_lookup>
  80215d:	85 c0                	test   %eax,%eax
  80215f:	78 0e                	js     80216f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802161:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802164:	8b 55 0c             	mov    0xc(%ebp),%edx
  802167:	89 50 04             	mov    %edx,0x4(%eax)
  80216a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80216f:	c9                   	leave  
  802170:	c3                   	ret    

00802171 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	56                   	push   %esi
  802175:	53                   	push   %ebx
  802176:	83 ec 10             	sub    $0x10,%esp
  802179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80217c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80217f:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  802184:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802189:	be 30 3b 80 00       	mov    $0x803b30,%esi
		if (devtab[i]->dev_id == dev_id) {
  80218e:	39 08                	cmp    %ecx,(%eax)
  802190:	75 10                	jne    8021a2 <dev_lookup+0x31>
  802192:	eb 04                	jmp    802198 <dev_lookup+0x27>
  802194:	39 08                	cmp    %ecx,(%eax)
  802196:	75 0a                	jne    8021a2 <dev_lookup+0x31>
			*dev = devtab[i];
  802198:	89 03                	mov    %eax,(%ebx)
  80219a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80219f:	90                   	nop
  8021a0:	eb 31                	jmp    8021d3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8021a2:	83 c2 01             	add    $0x1,%edx
  8021a5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	75 e8                	jne    802194 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8021ac:	a1 24 50 80 00       	mov    0x805024,%eax
  8021b1:	8b 40 48             	mov    0x48(%eax),%eax
  8021b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021bc:	c7 04 24 b0 3a 80 00 	movl   $0x803ab0,(%esp)
  8021c3:	e8 b9 e5 ff ff       	call   800781 <cprintf>
	*dev = 0;
  8021c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8021d3:	83 c4 10             	add    $0x10,%esp
  8021d6:	5b                   	pop    %ebx
  8021d7:	5e                   	pop    %esi
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    

008021da <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8021da:	55                   	push   %ebp
  8021db:	89 e5                	mov    %esp,%ebp
  8021dd:	53                   	push   %ebx
  8021de:	83 ec 24             	sub    $0x24,%esp
  8021e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ee:	89 04 24             	mov    %eax,(%esp)
  8021f1:	e8 07 ff ff ff       	call   8020fd <fd_lookup>
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	78 53                	js     80224d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802201:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802204:	8b 00                	mov    (%eax),%eax
  802206:	89 04 24             	mov    %eax,(%esp)
  802209:	e8 63 ff ff ff       	call   802171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80220e:	85 c0                	test   %eax,%eax
  802210:	78 3b                	js     80224d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  802212:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802217:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80221a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80221e:	74 2d                	je     80224d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802220:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802223:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80222a:	00 00 00 
	stat->st_isdir = 0;
  80222d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802234:	00 00 00 
	stat->st_dev = dev;
  802237:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802240:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802244:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802247:	89 14 24             	mov    %edx,(%esp)
  80224a:	ff 50 14             	call   *0x14(%eax)
}
  80224d:	83 c4 24             	add    $0x24,%esp
  802250:	5b                   	pop    %ebx
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    

00802253 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	53                   	push   %ebx
  802257:	83 ec 24             	sub    $0x24,%esp
  80225a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80225d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802260:	89 44 24 04          	mov    %eax,0x4(%esp)
  802264:	89 1c 24             	mov    %ebx,(%esp)
  802267:	e8 91 fe ff ff       	call   8020fd <fd_lookup>
  80226c:	85 c0                	test   %eax,%eax
  80226e:	78 5f                	js     8022cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802273:	89 44 24 04          	mov    %eax,0x4(%esp)
  802277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80227a:	8b 00                	mov    (%eax),%eax
  80227c:	89 04 24             	mov    %eax,(%esp)
  80227f:	e8 ed fe ff ff       	call   802171 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802284:	85 c0                	test   %eax,%eax
  802286:	78 47                	js     8022cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802288:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80228b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80228f:	75 23                	jne    8022b4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802291:	a1 24 50 80 00       	mov    0x805024,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802296:	8b 40 48             	mov    0x48(%eax),%eax
  802299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80229d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a1:	c7 04 24 d0 3a 80 00 	movl   $0x803ad0,(%esp)
  8022a8:	e8 d4 e4 ff ff       	call   800781 <cprintf>
  8022ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8022b2:	eb 1b                	jmp    8022cf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8022b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b7:	8b 48 18             	mov    0x18(%eax),%ecx
  8022ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8022bf:	85 c9                	test   %ecx,%ecx
  8022c1:	74 0c                	je     8022cf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8022c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	ff d1                	call   *%ecx
}
  8022cf:	83 c4 24             	add    $0x24,%esp
  8022d2:	5b                   	pop    %ebx
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    

008022d5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	53                   	push   %ebx
  8022d9:	83 ec 24             	sub    $0x24,%esp
  8022dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e6:	89 1c 24             	mov    %ebx,(%esp)
  8022e9:	e8 0f fe ff ff       	call   8020fd <fd_lookup>
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	78 66                	js     802358 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022fc:	8b 00                	mov    (%eax),%eax
  8022fe:	89 04 24             	mov    %eax,(%esp)
  802301:	e8 6b fe ff ff       	call   802171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802306:	85 c0                	test   %eax,%eax
  802308:	78 4e                	js     802358 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80230a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80230d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  802311:	75 23                	jne    802336 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802313:	a1 24 50 80 00       	mov    0x805024,%eax
  802318:	8b 40 48             	mov    0x48(%eax),%eax
  80231b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802323:	c7 04 24 f4 3a 80 00 	movl   $0x803af4,(%esp)
  80232a:	e8 52 e4 ff ff       	call   800781 <cprintf>
  80232f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  802334:	eb 22                	jmp    802358 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802336:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802339:	8b 48 0c             	mov    0xc(%eax),%ecx
  80233c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802341:	85 c9                	test   %ecx,%ecx
  802343:	74 13                	je     802358 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802345:	8b 45 10             	mov    0x10(%ebp),%eax
  802348:	89 44 24 08          	mov    %eax,0x8(%esp)
  80234c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802353:	89 14 24             	mov    %edx,(%esp)
  802356:	ff d1                	call   *%ecx
}
  802358:	83 c4 24             	add    $0x24,%esp
  80235b:	5b                   	pop    %ebx
  80235c:	5d                   	pop    %ebp
  80235d:	c3                   	ret    

0080235e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	53                   	push   %ebx
  802362:	83 ec 24             	sub    $0x24,%esp
  802365:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802368:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80236b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236f:	89 1c 24             	mov    %ebx,(%esp)
  802372:	e8 86 fd ff ff       	call   8020fd <fd_lookup>
  802377:	85 c0                	test   %eax,%eax
  802379:	78 6b                	js     8023e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80237b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80237e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802382:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802385:	8b 00                	mov    (%eax),%eax
  802387:	89 04 24             	mov    %eax,(%esp)
  80238a:	e8 e2 fd ff ff       	call   802171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80238f:	85 c0                	test   %eax,%eax
  802391:	78 53                	js     8023e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802393:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802396:	8b 42 08             	mov    0x8(%edx),%eax
  802399:	83 e0 03             	and    $0x3,%eax
  80239c:	83 f8 01             	cmp    $0x1,%eax
  80239f:	75 23                	jne    8023c4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8023a1:	a1 24 50 80 00       	mov    0x805024,%eax
  8023a6:	8b 40 48             	mov    0x48(%eax),%eax
  8023a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b1:	c7 04 24 11 3b 80 00 	movl   $0x803b11,(%esp)
  8023b8:	e8 c4 e3 ff ff       	call   800781 <cprintf>
  8023bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8023c2:	eb 22                	jmp    8023e6 <read+0x88>
	}
	if (!dev->dev_read)
  8023c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c7:	8b 48 08             	mov    0x8(%eax),%ecx
  8023ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8023cf:	85 c9                	test   %ecx,%ecx
  8023d1:	74 13                	je     8023e6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8023d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8023d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e1:	89 14 24             	mov    %edx,(%esp)
  8023e4:	ff d1                	call   *%ecx
}
  8023e6:	83 c4 24             	add    $0x24,%esp
  8023e9:	5b                   	pop    %ebx
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    

008023ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	57                   	push   %edi
  8023f0:	56                   	push   %esi
  8023f1:	53                   	push   %ebx
  8023f2:	83 ec 1c             	sub    $0x1c,%esp
  8023f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8023fb:	ba 00 00 00 00       	mov    $0x0,%edx
  802400:	bb 00 00 00 00       	mov    $0x0,%ebx
  802405:	b8 00 00 00 00       	mov    $0x0,%eax
  80240a:	85 f6                	test   %esi,%esi
  80240c:	74 29                	je     802437 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80240e:	89 f0                	mov    %esi,%eax
  802410:	29 d0                	sub    %edx,%eax
  802412:	89 44 24 08          	mov    %eax,0x8(%esp)
  802416:	03 55 0c             	add    0xc(%ebp),%edx
  802419:	89 54 24 04          	mov    %edx,0x4(%esp)
  80241d:	89 3c 24             	mov    %edi,(%esp)
  802420:	e8 39 ff ff ff       	call   80235e <read>
		if (m < 0)
  802425:	85 c0                	test   %eax,%eax
  802427:	78 0e                	js     802437 <readn+0x4b>
			return m;
		if (m == 0)
  802429:	85 c0                	test   %eax,%eax
  80242b:	74 08                	je     802435 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80242d:	01 c3                	add    %eax,%ebx
  80242f:	89 da                	mov    %ebx,%edx
  802431:	39 f3                	cmp    %esi,%ebx
  802433:	72 d9                	jb     80240e <readn+0x22>
  802435:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802437:	83 c4 1c             	add    $0x1c,%esp
  80243a:	5b                   	pop    %ebx
  80243b:	5e                   	pop    %esi
  80243c:	5f                   	pop    %edi
  80243d:	5d                   	pop    %ebp
  80243e:	c3                   	ret    

0080243f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80243f:	55                   	push   %ebp
  802440:	89 e5                	mov    %esp,%ebp
  802442:	56                   	push   %esi
  802443:	53                   	push   %ebx
  802444:	83 ec 20             	sub    $0x20,%esp
  802447:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80244a:	89 34 24             	mov    %esi,(%esp)
  80244d:	e8 0e fc ff ff       	call   802060 <fd2num>
  802452:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802455:	89 54 24 04          	mov    %edx,0x4(%esp)
  802459:	89 04 24             	mov    %eax,(%esp)
  80245c:	e8 9c fc ff ff       	call   8020fd <fd_lookup>
  802461:	89 c3                	mov    %eax,%ebx
  802463:	85 c0                	test   %eax,%eax
  802465:	78 05                	js     80246c <fd_close+0x2d>
  802467:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80246a:	74 0c                	je     802478 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80246c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  802470:	19 c0                	sbb    %eax,%eax
  802472:	f7 d0                	not    %eax
  802474:	21 c3                	and    %eax,%ebx
  802476:	eb 3d                	jmp    8024b5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80247b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80247f:	8b 06                	mov    (%esi),%eax
  802481:	89 04 24             	mov    %eax,(%esp)
  802484:	e8 e8 fc ff ff       	call   802171 <dev_lookup>
  802489:	89 c3                	mov    %eax,%ebx
  80248b:	85 c0                	test   %eax,%eax
  80248d:	78 16                	js     8024a5 <fd_close+0x66>
		if (dev->dev_close)
  80248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802492:	8b 40 10             	mov    0x10(%eax),%eax
  802495:	bb 00 00 00 00       	mov    $0x0,%ebx
  80249a:	85 c0                	test   %eax,%eax
  80249c:	74 07                	je     8024a5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80249e:	89 34 24             	mov    %esi,(%esp)
  8024a1:	ff d0                	call   *%eax
  8024a3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8024a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b0:	e8 49 f4 ff ff       	call   8018fe <sys_page_unmap>
	return r;
}
  8024b5:	89 d8                	mov    %ebx,%eax
  8024b7:	83 c4 20             	add    $0x20,%esp
  8024ba:	5b                   	pop    %ebx
  8024bb:	5e                   	pop    %esi
  8024bc:	5d                   	pop    %ebp
  8024bd:	c3                   	ret    

008024be <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ce:	89 04 24             	mov    %eax,(%esp)
  8024d1:	e8 27 fc ff ff       	call   8020fd <fd_lookup>
  8024d6:	85 c0                	test   %eax,%eax
  8024d8:	78 13                	js     8024ed <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8024da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8024e1:	00 
  8024e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e5:	89 04 24             	mov    %eax,(%esp)
  8024e8:	e8 52 ff ff ff       	call   80243f <fd_close>
}
  8024ed:	c9                   	leave  
  8024ee:	c3                   	ret    

008024ef <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8024ef:	55                   	push   %ebp
  8024f0:	89 e5                	mov    %esp,%ebp
  8024f2:	83 ec 18             	sub    $0x18,%esp
  8024f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8024f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8024fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802502:	00 
  802503:	8b 45 08             	mov    0x8(%ebp),%eax
  802506:	89 04 24             	mov    %eax,(%esp)
  802509:	e8 79 03 00 00       	call   802887 <open>
  80250e:	89 c3                	mov    %eax,%ebx
  802510:	85 c0                	test   %eax,%eax
  802512:	78 1b                	js     80252f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802514:	8b 45 0c             	mov    0xc(%ebp),%eax
  802517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80251b:	89 1c 24             	mov    %ebx,(%esp)
  80251e:	e8 b7 fc ff ff       	call   8021da <fstat>
  802523:	89 c6                	mov    %eax,%esi
	close(fd);
  802525:	89 1c 24             	mov    %ebx,(%esp)
  802528:	e8 91 ff ff ff       	call   8024be <close>
  80252d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80252f:	89 d8                	mov    %ebx,%eax
  802531:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802534:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802537:	89 ec                	mov    %ebp,%esp
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    

0080253b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80253b:	55                   	push   %ebp
  80253c:	89 e5                	mov    %esp,%ebp
  80253e:	53                   	push   %ebx
  80253f:	83 ec 14             	sub    $0x14,%esp
  802542:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  802547:	89 1c 24             	mov    %ebx,(%esp)
  80254a:	e8 6f ff ff ff       	call   8024be <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80254f:	83 c3 01             	add    $0x1,%ebx
  802552:	83 fb 20             	cmp    $0x20,%ebx
  802555:	75 f0                	jne    802547 <close_all+0xc>
		close(i);
}
  802557:	83 c4 14             	add    $0x14,%esp
  80255a:	5b                   	pop    %ebx
  80255b:	5d                   	pop    %ebp
  80255c:	c3                   	ret    

0080255d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80255d:	55                   	push   %ebp
  80255e:	89 e5                	mov    %esp,%ebp
  802560:	83 ec 58             	sub    $0x58,%esp
  802563:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802566:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802569:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80256c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80256f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802572:	89 44 24 04          	mov    %eax,0x4(%esp)
  802576:	8b 45 08             	mov    0x8(%ebp),%eax
  802579:	89 04 24             	mov    %eax,(%esp)
  80257c:	e8 7c fb ff ff       	call   8020fd <fd_lookup>
  802581:	89 c3                	mov    %eax,%ebx
  802583:	85 c0                	test   %eax,%eax
  802585:	0f 88 e0 00 00 00    	js     80266b <dup+0x10e>
		return r;
	close(newfdnum);
  80258b:	89 3c 24             	mov    %edi,(%esp)
  80258e:	e8 2b ff ff ff       	call   8024be <close>

	newfd = INDEX2FD(newfdnum);
  802593:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802599:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80259c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80259f:	89 04 24             	mov    %eax,(%esp)
  8025a2:	e8 c9 fa ff ff       	call   802070 <fd2data>
  8025a7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8025a9:	89 34 24             	mov    %esi,(%esp)
  8025ac:	e8 bf fa ff ff       	call   802070 <fd2data>
  8025b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8025b4:	89 da                	mov    %ebx,%edx
  8025b6:	89 d8                	mov    %ebx,%eax
  8025b8:	c1 e8 16             	shr    $0x16,%eax
  8025bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8025c2:	a8 01                	test   $0x1,%al
  8025c4:	74 43                	je     802609 <dup+0xac>
  8025c6:	c1 ea 0c             	shr    $0xc,%edx
  8025c9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8025d0:	a8 01                	test   $0x1,%al
  8025d2:	74 35                	je     802609 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8025d4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8025db:	25 07 0e 00 00       	and    $0xe07,%eax
  8025e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8025e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8025f2:	00 
  8025f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8025f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025fe:	e8 67 f3 ff ff       	call   80196a <sys_page_map>
  802603:	89 c3                	mov    %eax,%ebx
  802605:	85 c0                	test   %eax,%eax
  802607:	78 3f                	js     802648 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802609:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80260c:	89 c2                	mov    %eax,%edx
  80260e:	c1 ea 0c             	shr    $0xc,%edx
  802611:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802618:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80261e:	89 54 24 10          	mov    %edx,0x10(%esp)
  802622:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802626:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80262d:	00 
  80262e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802632:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802639:	e8 2c f3 ff ff       	call   80196a <sys_page_map>
  80263e:	89 c3                	mov    %eax,%ebx
  802640:	85 c0                	test   %eax,%eax
  802642:	78 04                	js     802648 <dup+0xeb>
  802644:	89 fb                	mov    %edi,%ebx
  802646:	eb 23                	jmp    80266b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802648:	89 74 24 04          	mov    %esi,0x4(%esp)
  80264c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802653:	e8 a6 f2 ff ff       	call   8018fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  802658:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80265b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80265f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802666:	e8 93 f2 ff ff       	call   8018fe <sys_page_unmap>
	return r;
}
  80266b:	89 d8                	mov    %ebx,%eax
  80266d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802670:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802673:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802676:	89 ec                	mov    %ebp,%esp
  802678:	5d                   	pop    %ebp
  802679:	c3                   	ret    
	...

0080267c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80267c:	55                   	push   %ebp
  80267d:	89 e5                	mov    %esp,%ebp
  80267f:	83 ec 18             	sub    $0x18,%esp
  802682:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802685:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802688:	89 c3                	mov    %eax,%ebx
  80268a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80268c:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  802693:	75 11                	jne    8026a6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802695:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80269c:	e8 7f f8 ff ff       	call   801f20 <ipc_find_env>
  8026a1:	a3 08 50 80 00       	mov    %eax,0x805008
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8026a6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8026ad:	00 
  8026ae:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8026b5:	00 
  8026b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026ba:	a1 08 50 80 00       	mov    0x805008,%eax
  8026bf:	89 04 24             	mov    %eax,(%esp)
  8026c2:	e8 a4 f8 ff ff       	call   801f6b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8026c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8026ce:	00 
  8026cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026da:	e8 0a f9 ff ff       	call   801fe9 <ipc_recv>
}
  8026df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8026e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8026e5:	89 ec                	mov    %ebp,%esp
  8026e7:	5d                   	pop    %ebp
  8026e8:	c3                   	ret    

008026e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8026e9:	55                   	push   %ebp
  8026ea:	89 e5                	mov    %esp,%ebp
  8026ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8026ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8026f5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8026fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026fd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802702:	ba 00 00 00 00       	mov    $0x0,%edx
  802707:	b8 02 00 00 00       	mov    $0x2,%eax
  80270c:	e8 6b ff ff ff       	call   80267c <fsipc>
}
  802711:	c9                   	leave  
  802712:	c3                   	ret    

00802713 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802713:	55                   	push   %ebp
  802714:	89 e5                	mov    %esp,%ebp
  802716:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802719:	8b 45 08             	mov    0x8(%ebp),%eax
  80271c:	8b 40 0c             	mov    0xc(%eax),%eax
  80271f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802724:	ba 00 00 00 00       	mov    $0x0,%edx
  802729:	b8 06 00 00 00       	mov    $0x6,%eax
  80272e:	e8 49 ff ff ff       	call   80267c <fsipc>
}
  802733:	c9                   	leave  
  802734:	c3                   	ret    

00802735 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802735:	55                   	push   %ebp
  802736:	89 e5                	mov    %esp,%ebp
  802738:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80273b:	ba 00 00 00 00       	mov    $0x0,%edx
  802740:	b8 08 00 00 00       	mov    $0x8,%eax
  802745:	e8 32 ff ff ff       	call   80267c <fsipc>
}
  80274a:	c9                   	leave  
  80274b:	c3                   	ret    

0080274c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80274c:	55                   	push   %ebp
  80274d:	89 e5                	mov    %esp,%ebp
  80274f:	53                   	push   %ebx
  802750:	83 ec 14             	sub    $0x14,%esp
  802753:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802756:	8b 45 08             	mov    0x8(%ebp),%eax
  802759:	8b 40 0c             	mov    0xc(%eax),%eax
  80275c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802761:	ba 00 00 00 00       	mov    $0x0,%edx
  802766:	b8 05 00 00 00       	mov    $0x5,%eax
  80276b:	e8 0c ff ff ff       	call   80267c <fsipc>
  802770:	85 c0                	test   %eax,%eax
  802772:	78 2b                	js     80279f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802774:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80277b:	00 
  80277c:	89 1c 24             	mov    %ebx,(%esp)
  80277f:	e8 26 e9 ff ff       	call   8010aa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802784:	a1 80 60 80 00       	mov    0x806080,%eax
  802789:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80278f:	a1 84 60 80 00       	mov    0x806084,%eax
  802794:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80279a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80279f:	83 c4 14             	add    $0x14,%esp
  8027a2:	5b                   	pop    %ebx
  8027a3:	5d                   	pop    %ebp
  8027a4:	c3                   	ret    

008027a5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8027a5:	55                   	push   %ebp
  8027a6:	89 e5                	mov    %esp,%ebp
  8027a8:	83 ec 18             	sub    $0x18,%esp
  8027ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8027ae:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8027b3:	76 05                	jbe    8027ba <devfile_write+0x15>
  8027b5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  8027ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8027bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8027c0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  8027c6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  8027cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027d6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8027dd:	e8 b3 ea ff ff       	call   801295 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  8027e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8027e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8027ec:	e8 8b fe ff ff       	call   80267c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  8027f1:	c9                   	leave  
  8027f2:	c3                   	ret    

008027f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8027f3:	55                   	push   %ebp
  8027f4:	89 e5                	mov    %esp,%ebp
  8027f6:	53                   	push   %ebx
  8027f7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  8027fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fd:	8b 40 0c             	mov    0xc(%eax),%eax
  802800:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  802805:	8b 45 10             	mov    0x10(%ebp),%eax
  802808:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  80280d:	ba 00 00 00 00       	mov    $0x0,%edx
  802812:	b8 03 00 00 00       	mov    $0x3,%eax
  802817:	e8 60 fe ff ff       	call   80267c <fsipc>
  80281c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80281e:	85 c0                	test   %eax,%eax
  802820:	78 17                	js     802839 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802822:	89 44 24 08          	mov    %eax,0x8(%esp)
  802826:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80282d:	00 
  80282e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802831:	89 04 24             	mov    %eax,(%esp)
  802834:	e8 5c ea ff ff       	call   801295 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802839:	89 d8                	mov    %ebx,%eax
  80283b:	83 c4 14             	add    $0x14,%esp
  80283e:	5b                   	pop    %ebx
  80283f:	5d                   	pop    %ebp
  802840:	c3                   	ret    

00802841 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802841:	55                   	push   %ebp
  802842:	89 e5                	mov    %esp,%ebp
  802844:	53                   	push   %ebx
  802845:	83 ec 14             	sub    $0x14,%esp
  802848:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80284b:	89 1c 24             	mov    %ebx,(%esp)
  80284e:	e8 0d e8 ff ff       	call   801060 <strlen>
  802853:	89 c2                	mov    %eax,%edx
  802855:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80285a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802860:	7f 1f                	jg     802881 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802862:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802866:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80286d:	e8 38 e8 ff ff       	call   8010aa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802872:	ba 00 00 00 00       	mov    $0x0,%edx
  802877:	b8 07 00 00 00       	mov    $0x7,%eax
  80287c:	e8 fb fd ff ff       	call   80267c <fsipc>
}
  802881:	83 c4 14             	add    $0x14,%esp
  802884:	5b                   	pop    %ebx
  802885:	5d                   	pop    %ebp
  802886:	c3                   	ret    

00802887 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802887:	55                   	push   %ebp
  802888:	89 e5                	mov    %esp,%ebp
  80288a:	83 ec 28             	sub    $0x28,%esp
  80288d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802890:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802893:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802896:	89 34 24             	mov    %esi,(%esp)
  802899:	e8 c2 e7 ff ff       	call   801060 <strlen>
  80289e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8028a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028a8:	7f 6d                	jg     802917 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8028aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028ad:	89 04 24             	mov    %eax,(%esp)
  8028b0:	e8 d6 f7 ff ff       	call   80208b <fd_alloc>
  8028b5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8028b7:	85 c0                	test   %eax,%eax
  8028b9:	78 5c                	js     802917 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8028bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028be:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8028c3:	89 34 24             	mov    %esi,(%esp)
  8028c6:	e8 95 e7 ff ff       	call   801060 <strlen>
  8028cb:	83 c0 01             	add    $0x1,%eax
  8028ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028d6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8028dd:	e8 b3 e9 ff ff       	call   801295 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8028e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8028ea:	e8 8d fd ff ff       	call   80267c <fsipc>
  8028ef:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  8028f1:	85 c0                	test   %eax,%eax
  8028f3:	79 15                	jns    80290a <open+0x83>
             fd_close(fd,0);
  8028f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8028fc:	00 
  8028fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802900:	89 04 24             	mov    %eax,(%esp)
  802903:	e8 37 fb ff ff       	call   80243f <fd_close>
             return r;
  802908:	eb 0d                	jmp    802917 <open+0x90>
        }
        return fd2num(fd);
  80290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80290d:	89 04 24             	mov    %eax,(%esp)
  802910:	e8 4b f7 ff ff       	call   802060 <fd2num>
  802915:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802917:	89 d8                	mov    %ebx,%eax
  802919:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80291c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80291f:	89 ec                	mov    %ebp,%esp
  802921:	5d                   	pop    %ebp
  802922:	c3                   	ret    
	...

00802930 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802930:	55                   	push   %ebp
  802931:	89 e5                	mov    %esp,%ebp
  802933:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802936:	c7 44 24 04 3c 3b 80 	movl   $0x803b3c,0x4(%esp)
  80293d:	00 
  80293e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802941:	89 04 24             	mov    %eax,(%esp)
  802944:	e8 61 e7 ff ff       	call   8010aa <strcpy>
	return 0;
}
  802949:	b8 00 00 00 00       	mov    $0x0,%eax
  80294e:	c9                   	leave  
  80294f:	c3                   	ret    

00802950 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802950:	55                   	push   %ebp
  802951:	89 e5                	mov    %esp,%ebp
  802953:	53                   	push   %ebx
  802954:	83 ec 14             	sub    $0x14,%esp
  802957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80295a:	89 1c 24             	mov    %ebx,(%esp)
  80295d:	e8 46 05 00 00       	call   802ea8 <pageref>
  802962:	89 c2                	mov    %eax,%edx
  802964:	b8 00 00 00 00       	mov    $0x0,%eax
  802969:	83 fa 01             	cmp    $0x1,%edx
  80296c:	75 0b                	jne    802979 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80296e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802971:	89 04 24             	mov    %eax,(%esp)
  802974:	e8 b9 02 00 00       	call   802c32 <nsipc_close>
	else
		return 0;
}
  802979:	83 c4 14             	add    $0x14,%esp
  80297c:	5b                   	pop    %ebx
  80297d:	5d                   	pop    %ebp
  80297e:	c3                   	ret    

0080297f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80297f:	55                   	push   %ebp
  802980:	89 e5                	mov    %esp,%ebp
  802982:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802985:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80298c:	00 
  80298d:	8b 45 10             	mov    0x10(%ebp),%eax
  802990:	89 44 24 08          	mov    %eax,0x8(%esp)
  802994:	8b 45 0c             	mov    0xc(%ebp),%eax
  802997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80299b:	8b 45 08             	mov    0x8(%ebp),%eax
  80299e:	8b 40 0c             	mov    0xc(%eax),%eax
  8029a1:	89 04 24             	mov    %eax,(%esp)
  8029a4:	e8 c5 02 00 00       	call   802c6e <nsipc_send>
}
  8029a9:	c9                   	leave  
  8029aa:	c3                   	ret    

008029ab <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8029ab:	55                   	push   %ebp
  8029ac:	89 e5                	mov    %esp,%ebp
  8029ae:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8029b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8029b8:	00 
  8029b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8029bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8029ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8029cd:	89 04 24             	mov    %eax,(%esp)
  8029d0:	e8 0c 03 00 00       	call   802ce1 <nsipc_recv>
}
  8029d5:	c9                   	leave  
  8029d6:	c3                   	ret    

008029d7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8029d7:	55                   	push   %ebp
  8029d8:	89 e5                	mov    %esp,%ebp
  8029da:	56                   	push   %esi
  8029db:	53                   	push   %ebx
  8029dc:	83 ec 20             	sub    $0x20,%esp
  8029df:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8029e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029e4:	89 04 24             	mov    %eax,(%esp)
  8029e7:	e8 9f f6 ff ff       	call   80208b <fd_alloc>
  8029ec:	89 c3                	mov    %eax,%ebx
  8029ee:	85 c0                	test   %eax,%eax
  8029f0:	78 21                	js     802a13 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8029f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8029f9:	00 
  8029fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a08:	e8 cb ef ff ff       	call   8019d8 <sys_page_alloc>
  802a0d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802a0f:	85 c0                	test   %eax,%eax
  802a11:	79 0a                	jns    802a1d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802a13:	89 34 24             	mov    %esi,(%esp)
  802a16:	e8 17 02 00 00       	call   802c32 <nsipc_close>
		return r;
  802a1b:	eb 28                	jmp    802a45 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802a1d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a26:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a2b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a35:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a3b:	89 04 24             	mov    %eax,(%esp)
  802a3e:	e8 1d f6 ff ff       	call   802060 <fd2num>
  802a43:	89 c3                	mov    %eax,%ebx
}
  802a45:	89 d8                	mov    %ebx,%eax
  802a47:	83 c4 20             	add    $0x20,%esp
  802a4a:	5b                   	pop    %ebx
  802a4b:	5e                   	pop    %esi
  802a4c:	5d                   	pop    %ebp
  802a4d:	c3                   	ret    

00802a4e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802a4e:	55                   	push   %ebp
  802a4f:	89 e5                	mov    %esp,%ebp
  802a51:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802a54:	8b 45 10             	mov    0x10(%ebp),%eax
  802a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a62:	8b 45 08             	mov    0x8(%ebp),%eax
  802a65:	89 04 24             	mov    %eax,(%esp)
  802a68:	e8 79 01 00 00       	call   802be6 <nsipc_socket>
  802a6d:	85 c0                	test   %eax,%eax
  802a6f:	78 05                	js     802a76 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802a71:	e8 61 ff ff ff       	call   8029d7 <alloc_sockfd>
}
  802a76:	c9                   	leave  
  802a77:	c3                   	ret    

00802a78 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802a78:	55                   	push   %ebp
  802a79:	89 e5                	mov    %esp,%ebp
  802a7b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802a7e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802a81:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a85:	89 04 24             	mov    %eax,(%esp)
  802a88:	e8 70 f6 ff ff       	call   8020fd <fd_lookup>
  802a8d:	85 c0                	test   %eax,%eax
  802a8f:	78 15                	js     802aa6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802a91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802a94:	8b 0a                	mov    (%edx),%ecx
  802a96:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802a9b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802aa1:	75 03                	jne    802aa6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802aa3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802aa6:	c9                   	leave  
  802aa7:	c3                   	ret    

00802aa8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802aa8:	55                   	push   %ebp
  802aa9:	89 e5                	mov    %esp,%ebp
  802aab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802aae:	8b 45 08             	mov    0x8(%ebp),%eax
  802ab1:	e8 c2 ff ff ff       	call   802a78 <fd2sockid>
  802ab6:	85 c0                	test   %eax,%eax
  802ab8:	78 0f                	js     802ac9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802aba:	8b 55 0c             	mov    0xc(%ebp),%edx
  802abd:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ac1:	89 04 24             	mov    %eax,(%esp)
  802ac4:	e8 47 01 00 00       	call   802c10 <nsipc_listen>
}
  802ac9:	c9                   	leave  
  802aca:	c3                   	ret    

00802acb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802acb:	55                   	push   %ebp
  802acc:	89 e5                	mov    %esp,%ebp
  802ace:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  802ad4:	e8 9f ff ff ff       	call   802a78 <fd2sockid>
  802ad9:	85 c0                	test   %eax,%eax
  802adb:	78 16                	js     802af3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802add:	8b 55 10             	mov    0x10(%ebp),%edx
  802ae0:	89 54 24 08          	mov    %edx,0x8(%esp)
  802ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
  802ae7:	89 54 24 04          	mov    %edx,0x4(%esp)
  802aeb:	89 04 24             	mov    %eax,(%esp)
  802aee:	e8 6e 02 00 00       	call   802d61 <nsipc_connect>
}
  802af3:	c9                   	leave  
  802af4:	c3                   	ret    

00802af5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802af5:	55                   	push   %ebp
  802af6:	89 e5                	mov    %esp,%ebp
  802af8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802afb:	8b 45 08             	mov    0x8(%ebp),%eax
  802afe:	e8 75 ff ff ff       	call   802a78 <fd2sockid>
  802b03:	85 c0                	test   %eax,%eax
  802b05:	78 0f                	js     802b16 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802b07:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b0a:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b0e:	89 04 24             	mov    %eax,(%esp)
  802b11:	e8 36 01 00 00       	call   802c4c <nsipc_shutdown>
}
  802b16:	c9                   	leave  
  802b17:	c3                   	ret    

00802b18 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802b18:	55                   	push   %ebp
  802b19:	89 e5                	mov    %esp,%ebp
  802b1b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  802b21:	e8 52 ff ff ff       	call   802a78 <fd2sockid>
  802b26:	85 c0                	test   %eax,%eax
  802b28:	78 16                	js     802b40 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802b2a:	8b 55 10             	mov    0x10(%ebp),%edx
  802b2d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802b31:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b34:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b38:	89 04 24             	mov    %eax,(%esp)
  802b3b:	e8 60 02 00 00       	call   802da0 <nsipc_bind>
}
  802b40:	c9                   	leave  
  802b41:	c3                   	ret    

00802b42 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802b42:	55                   	push   %ebp
  802b43:	89 e5                	mov    %esp,%ebp
  802b45:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802b48:	8b 45 08             	mov    0x8(%ebp),%eax
  802b4b:	e8 28 ff ff ff       	call   802a78 <fd2sockid>
  802b50:	85 c0                	test   %eax,%eax
  802b52:	78 1f                	js     802b73 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802b54:	8b 55 10             	mov    0x10(%ebp),%edx
  802b57:	89 54 24 08          	mov    %edx,0x8(%esp)
  802b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b62:	89 04 24             	mov    %eax,(%esp)
  802b65:	e8 75 02 00 00       	call   802ddf <nsipc_accept>
  802b6a:	85 c0                	test   %eax,%eax
  802b6c:	78 05                	js     802b73 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802b6e:	e8 64 fe ff ff       	call   8029d7 <alloc_sockfd>
}
  802b73:	c9                   	leave  
  802b74:	c3                   	ret    
	...

00802b80 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802b80:	55                   	push   %ebp
  802b81:	89 e5                	mov    %esp,%ebp
  802b83:	53                   	push   %ebx
  802b84:	83 ec 14             	sub    $0x14,%esp
  802b87:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802b89:	83 3d 0c 50 80 00 00 	cmpl   $0x0,0x80500c
  802b90:	75 11                	jne    802ba3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802b92:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802b99:	e8 82 f3 ff ff       	call   801f20 <ipc_find_env>
  802b9e:	a3 0c 50 80 00       	mov    %eax,0x80500c
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802ba3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802baa:	00 
  802bab:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802bb2:	00 
  802bb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802bb7:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802bbc:	89 04 24             	mov    %eax,(%esp)
  802bbf:	e8 a7 f3 ff ff       	call   801f6b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802bc4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802bcb:	00 
  802bcc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802bd3:	00 
  802bd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bdb:	e8 09 f4 ff ff       	call   801fe9 <ipc_recv>
}
  802be0:	83 c4 14             	add    $0x14,%esp
  802be3:	5b                   	pop    %ebx
  802be4:	5d                   	pop    %ebp
  802be5:	c3                   	ret    

00802be6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802be6:	55                   	push   %ebp
  802be7:	89 e5                	mov    %esp,%ebp
  802be9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802bec:	8b 45 08             	mov    0x8(%ebp),%eax
  802bef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bf7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802bfc:	8b 45 10             	mov    0x10(%ebp),%eax
  802bff:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802c04:	b8 09 00 00 00       	mov    $0x9,%eax
  802c09:	e8 72 ff ff ff       	call   802b80 <nsipc>
}
  802c0e:	c9                   	leave  
  802c0f:	c3                   	ret    

00802c10 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802c10:	55                   	push   %ebp
  802c11:	89 e5                	mov    %esp,%ebp
  802c13:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802c16:	8b 45 08             	mov    0x8(%ebp),%eax
  802c19:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c21:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802c26:	b8 06 00 00 00       	mov    $0x6,%eax
  802c2b:	e8 50 ff ff ff       	call   802b80 <nsipc>
}
  802c30:	c9                   	leave  
  802c31:	c3                   	ret    

00802c32 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802c32:	55                   	push   %ebp
  802c33:	89 e5                	mov    %esp,%ebp
  802c35:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802c38:	8b 45 08             	mov    0x8(%ebp),%eax
  802c3b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802c40:	b8 04 00 00 00       	mov    $0x4,%eax
  802c45:	e8 36 ff ff ff       	call   802b80 <nsipc>
}
  802c4a:	c9                   	leave  
  802c4b:	c3                   	ret    

00802c4c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  802c4c:	55                   	push   %ebp
  802c4d:	89 e5                	mov    %esp,%ebp
  802c4f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802c52:	8b 45 08             	mov    0x8(%ebp),%eax
  802c55:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c5d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802c62:	b8 03 00 00 00       	mov    $0x3,%eax
  802c67:	e8 14 ff ff ff       	call   802b80 <nsipc>
}
  802c6c:	c9                   	leave  
  802c6d:	c3                   	ret    

00802c6e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802c6e:	55                   	push   %ebp
  802c6f:	89 e5                	mov    %esp,%ebp
  802c71:	53                   	push   %ebx
  802c72:	83 ec 14             	sub    $0x14,%esp
  802c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802c78:	8b 45 08             	mov    0x8(%ebp),%eax
  802c7b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802c80:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802c86:	7e 24                	jle    802cac <nsipc_send+0x3e>
  802c88:	c7 44 24 0c 48 3b 80 	movl   $0x803b48,0xc(%esp)
  802c8f:	00 
  802c90:	c7 44 24 08 54 3b 80 	movl   $0x803b54,0x8(%esp)
  802c97:	00 
  802c98:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  802c9f:	00 
  802ca0:	c7 04 24 69 3b 80 00 	movl   $0x803b69,(%esp)
  802ca7:	e8 1c da ff ff       	call   8006c8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802cac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cb7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802cbe:	e8 d2 e5 ff ff       	call   801295 <memmove>
	nsipcbuf.send.req_size = size;
  802cc3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802cc9:	8b 45 14             	mov    0x14(%ebp),%eax
  802ccc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802cd1:	b8 08 00 00 00       	mov    $0x8,%eax
  802cd6:	e8 a5 fe ff ff       	call   802b80 <nsipc>
}
  802cdb:	83 c4 14             	add    $0x14,%esp
  802cde:	5b                   	pop    %ebx
  802cdf:	5d                   	pop    %ebp
  802ce0:	c3                   	ret    

00802ce1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802ce1:	55                   	push   %ebp
  802ce2:	89 e5                	mov    %esp,%ebp
  802ce4:	56                   	push   %esi
  802ce5:	53                   	push   %ebx
  802ce6:	83 ec 10             	sub    $0x10,%esp
  802ce9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802cec:	8b 45 08             	mov    0x8(%ebp),%eax
  802cef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802cf4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802cfa:	8b 45 14             	mov    0x14(%ebp),%eax
  802cfd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802d02:	b8 07 00 00 00       	mov    $0x7,%eax
  802d07:	e8 74 fe ff ff       	call   802b80 <nsipc>
  802d0c:	89 c3                	mov    %eax,%ebx
  802d0e:	85 c0                	test   %eax,%eax
  802d10:	78 46                	js     802d58 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802d12:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802d17:	7f 04                	jg     802d1d <nsipc_recv+0x3c>
  802d19:	39 c6                	cmp    %eax,%esi
  802d1b:	7d 24                	jge    802d41 <nsipc_recv+0x60>
  802d1d:	c7 44 24 0c 75 3b 80 	movl   $0x803b75,0xc(%esp)
  802d24:	00 
  802d25:	c7 44 24 08 54 3b 80 	movl   $0x803b54,0x8(%esp)
  802d2c:	00 
  802d2d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802d34:	00 
  802d35:	c7 04 24 69 3b 80 00 	movl   $0x803b69,(%esp)
  802d3c:	e8 87 d9 ff ff       	call   8006c8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802d41:	89 44 24 08          	mov    %eax,0x8(%esp)
  802d45:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802d4c:	00 
  802d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d50:	89 04 24             	mov    %eax,(%esp)
  802d53:	e8 3d e5 ff ff       	call   801295 <memmove>
	}

	return r;
}
  802d58:	89 d8                	mov    %ebx,%eax
  802d5a:	83 c4 10             	add    $0x10,%esp
  802d5d:	5b                   	pop    %ebx
  802d5e:	5e                   	pop    %esi
  802d5f:	5d                   	pop    %ebp
  802d60:	c3                   	ret    

00802d61 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802d61:	55                   	push   %ebp
  802d62:	89 e5                	mov    %esp,%ebp
  802d64:	53                   	push   %ebx
  802d65:	83 ec 14             	sub    $0x14,%esp
  802d68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  802d6e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802d73:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d7e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802d85:	e8 0b e5 ff ff       	call   801295 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802d8a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802d90:	b8 05 00 00 00       	mov    $0x5,%eax
  802d95:	e8 e6 fd ff ff       	call   802b80 <nsipc>
}
  802d9a:	83 c4 14             	add    $0x14,%esp
  802d9d:	5b                   	pop    %ebx
  802d9e:	5d                   	pop    %ebp
  802d9f:	c3                   	ret    

00802da0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802da0:	55                   	push   %ebp
  802da1:	89 e5                	mov    %esp,%ebp
  802da3:	53                   	push   %ebx
  802da4:	83 ec 14             	sub    $0x14,%esp
  802da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802daa:	8b 45 08             	mov    0x8(%ebp),%eax
  802dad:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802db2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  802db9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dbd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802dc4:	e8 cc e4 ff ff       	call   801295 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802dc9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802dcf:	b8 02 00 00 00       	mov    $0x2,%eax
  802dd4:	e8 a7 fd ff ff       	call   802b80 <nsipc>
}
  802dd9:	83 c4 14             	add    $0x14,%esp
  802ddc:	5b                   	pop    %ebx
  802ddd:	5d                   	pop    %ebp
  802dde:	c3                   	ret    

00802ddf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802ddf:	55                   	push   %ebp
  802de0:	89 e5                	mov    %esp,%ebp
  802de2:	83 ec 18             	sub    $0x18,%esp
  802de5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802de8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  802deb:	8b 45 08             	mov    0x8(%ebp),%eax
  802dee:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802df3:	b8 01 00 00 00       	mov    $0x1,%eax
  802df8:	e8 83 fd ff ff       	call   802b80 <nsipc>
  802dfd:	89 c3                	mov    %eax,%ebx
  802dff:	85 c0                	test   %eax,%eax
  802e01:	78 25                	js     802e28 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802e03:	be 10 70 80 00       	mov    $0x807010,%esi
  802e08:	8b 06                	mov    (%esi),%eax
  802e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e0e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802e15:	00 
  802e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e19:	89 04 24             	mov    %eax,(%esp)
  802e1c:	e8 74 e4 ff ff       	call   801295 <memmove>
		*addrlen = ret->ret_addrlen;
  802e21:	8b 16                	mov    (%esi),%edx
  802e23:	8b 45 10             	mov    0x10(%ebp),%eax
  802e26:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802e28:	89 d8                	mov    %ebx,%eax
  802e2a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802e2d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802e30:	89 ec                	mov    %ebp,%esp
  802e32:	5d                   	pop    %ebp
  802e33:	c3                   	ret    

00802e34 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e34:	55                   	push   %ebp
  802e35:	89 e5                	mov    %esp,%ebp
  802e37:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802e3a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802e41:	75 30                	jne    802e73 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  802e43:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802e4a:	00 
  802e4b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802e52:	ee 
  802e53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e5a:	e8 79 eb ff ff       	call   8019d8 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802e5f:	c7 44 24 04 80 2e 80 	movl   $0x802e80,0x4(%esp)
  802e66:	00 
  802e67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e6e:	e8 47 e9 ff ff       	call   8017ba <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e73:	8b 45 08             	mov    0x8(%ebp),%eax
  802e76:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802e7b:	c9                   	leave  
  802e7c:	c3                   	ret    
  802e7d:	00 00                	add    %al,(%eax)
	...

00802e80 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802e80:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802e81:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802e86:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802e88:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  802e8b:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  802e8f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  802e93:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  802e96:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802e98:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  802e9c:	83 c4 08             	add    $0x8,%esp
        popal
  802e9f:	61                   	popa   
        addl $0x4,%esp
  802ea0:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  802ea3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802ea4:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802ea5:	c3                   	ret    
	...

00802ea8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ea8:	55                   	push   %ebp
  802ea9:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802eab:	8b 45 08             	mov    0x8(%ebp),%eax
  802eae:	89 c2                	mov    %eax,%edx
  802eb0:	c1 ea 16             	shr    $0x16,%edx
  802eb3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802eba:	f6 c2 01             	test   $0x1,%dl
  802ebd:	74 20                	je     802edf <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802ebf:	c1 e8 0c             	shr    $0xc,%eax
  802ec2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802ec9:	a8 01                	test   $0x1,%al
  802ecb:	74 12                	je     802edf <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ecd:	c1 e8 0c             	shr    $0xc,%eax
  802ed0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802ed5:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802eda:	0f b7 c0             	movzwl %ax,%eax
  802edd:	eb 05                	jmp    802ee4 <pageref+0x3c>
  802edf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ee4:	5d                   	pop    %ebp
  802ee5:	c3                   	ret    
	...

00802ef0 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802ef0:	55                   	push   %ebp
  802ef1:	89 e5                	mov    %esp,%ebp
  802ef3:	57                   	push   %edi
  802ef4:	56                   	push   %esi
  802ef5:	53                   	push   %ebx
  802ef6:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  802efc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  802eff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f02:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802f05:	8d 45 f3             	lea    -0xd(%ebp),%eax
  802f08:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802f0b:	b9 10 50 80 00       	mov    $0x805010,%ecx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802f10:	ba cd ff ff ff       	mov    $0xffffffcd,%edx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802f15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f18:	0f b6 18             	movzbl (%eax),%ebx
  802f1b:	be 00 00 00 00       	mov    $0x0,%esi
  802f20:	89 f0                	mov    %esi,%eax
  802f22:	89 ce                	mov    %ecx,%esi
  802f24:	89 c1                	mov    %eax,%ecx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802f26:	89 d8                	mov    %ebx,%eax
  802f28:	f6 e2                	mul    %dl
  802f2a:	66 c1 e8 08          	shr    $0x8,%ax
  802f2e:	c0 e8 03             	shr    $0x3,%al
  802f31:	89 c7                	mov    %eax,%edi
  802f33:	8d 04 80             	lea    (%eax,%eax,4),%eax
  802f36:	01 c0                	add    %eax,%eax
  802f38:	28 c3                	sub    %al,%bl
  802f3a:	89 d8                	mov    %ebx,%eax
      *ap /= (u8_t)10;
  802f3c:	89 fb                	mov    %edi,%ebx
      inv[i++] = '0' + rem;
  802f3e:	0f b6 f9             	movzbl %cl,%edi
  802f41:	83 c0 30             	add    $0x30,%eax
  802f44:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
  802f48:	83 c1 01             	add    $0x1,%ecx
    } while(*ap);
  802f4b:	84 db                	test   %bl,%bl
  802f4d:	75 d7                	jne    802f26 <inet_ntoa+0x36>
  802f4f:	89 c8                	mov    %ecx,%eax
  802f51:	89 f1                	mov    %esi,%ecx
  802f53:	89 c6                	mov    %eax,%esi
  802f55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f58:	88 18                	mov    %bl,(%eax)
    while(i--)
  802f5a:	89 f0                	mov    %esi,%eax
  802f5c:	84 c0                	test   %al,%al
  802f5e:	74 2c                	je     802f8c <inet_ntoa+0x9c>
  802f60:	8d 5e ff             	lea    -0x1(%esi),%ebx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802f63:	0f b6 c3             	movzbl %bl,%eax
  802f66:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802f69:	8d 7c 01 01          	lea    0x1(%ecx,%eax,1),%edi
  802f6d:	89 c8                	mov    %ecx,%eax
  802f6f:	89 ce                	mov    %ecx,%esi
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  802f71:	0f b6 cb             	movzbl %bl,%ecx
  802f74:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  802f79:	88 08                	mov    %cl,(%eax)
  802f7b:	83 c0 01             	add    $0x1,%eax
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  802f7e:	83 eb 01             	sub    $0x1,%ebx
  802f81:	39 f8                	cmp    %edi,%eax
  802f83:	75 ec                	jne    802f71 <inet_ntoa+0x81>
  802f85:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802f88:	8d 4c 06 01          	lea    0x1(%esi,%eax,1),%ecx
      *rp++ = inv[i];
    *rp++ = '.';
  802f8c:	c6 01 2e             	movb   $0x2e,(%ecx)
  802f8f:	83 c1 01             	add    $0x1,%ecx
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802f92:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802f95:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802f98:	74 09                	je     802fa3 <inet_ntoa+0xb3>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  802f9a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  802f9e:	e9 72 ff ff ff       	jmp    802f15 <inet_ntoa+0x25>
  }
  *--rp = 0;
  802fa3:	c6 41 ff 00          	movb   $0x0,-0x1(%ecx)
  return str;
}
  802fa7:	b8 10 50 80 00       	mov    $0x805010,%eax
  802fac:	83 c4 1c             	add    $0x1c,%esp
  802faf:	5b                   	pop    %ebx
  802fb0:	5e                   	pop    %esi
  802fb1:	5f                   	pop    %edi
  802fb2:	5d                   	pop    %ebp
  802fb3:	c3                   	ret    

00802fb4 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  802fb4:	55                   	push   %ebp
  802fb5:	89 e5                	mov    %esp,%ebp
  802fb7:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802fbb:	66 c1 c0 08          	rol    $0x8,%ax
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}
  802fbf:	5d                   	pop    %ebp
  802fc0:	c3                   	ret    

00802fc1 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802fc1:	55                   	push   %ebp
  802fc2:	89 e5                	mov    %esp,%ebp
  802fc4:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  802fc7:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802fcb:	89 04 24             	mov    %eax,(%esp)
  802fce:	e8 e1 ff ff ff       	call   802fb4 <htons>
}
  802fd3:	c9                   	leave  
  802fd4:	c3                   	ret    

00802fd5 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  802fd5:	55                   	push   %ebp
  802fd6:	89 e5                	mov    %esp,%ebp
  802fd8:	8b 55 08             	mov    0x8(%ebp),%edx
  802fdb:	89 d1                	mov    %edx,%ecx
  802fdd:	c1 e9 18             	shr    $0x18,%ecx
  802fe0:	89 d0                	mov    %edx,%eax
  802fe2:	c1 e0 18             	shl    $0x18,%eax
  802fe5:	09 c8                	or     %ecx,%eax
  802fe7:	89 d1                	mov    %edx,%ecx
  802fe9:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  802fef:	c1 e1 08             	shl    $0x8,%ecx
  802ff2:	09 c8                	or     %ecx,%eax
  802ff4:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  802ffa:	c1 ea 08             	shr    $0x8,%edx
  802ffd:	09 d0                	or     %edx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802fff:	5d                   	pop    %ebp
  803000:	c3                   	ret    

00803001 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  803001:	55                   	push   %ebp
  803002:	89 e5                	mov    %esp,%ebp
  803004:	57                   	push   %edi
  803005:	56                   	push   %esi
  803006:	53                   	push   %ebx
  803007:	83 ec 28             	sub    $0x28,%esp
  80300a:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  80300d:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  803010:	8d 4a d0             	lea    -0x30(%edx),%ecx
  803013:	80 f9 09             	cmp    $0x9,%cl
  803016:	0f 87 af 01 00 00    	ja     8031cb <inet_aton+0x1ca>
  80301c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80301f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  803022:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  803025:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  803028:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  80302f:	83 fa 30             	cmp    $0x30,%edx
  803032:	75 24                	jne    803058 <inet_aton+0x57>
      c = *++cp;
  803034:	83 c0 01             	add    $0x1,%eax
  803037:	0f be 10             	movsbl (%eax),%edx
      if (c == 'x' || c == 'X') {
  80303a:	83 fa 78             	cmp    $0x78,%edx
  80303d:	74 0c                	je     80304b <inet_aton+0x4a>
  80303f:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  803046:	83 fa 58             	cmp    $0x58,%edx
  803049:	75 0d                	jne    803058 <inet_aton+0x57>
        base = 16;
        c = *++cp;
  80304b:	83 c0 01             	add    $0x1,%eax
  80304e:	0f be 10             	movsbl (%eax),%edx
  803051:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  803058:	83 c0 01             	add    $0x1,%eax
  80305b:	be 00 00 00 00       	mov    $0x0,%esi
  803060:	eb 03                	jmp    803065 <inet_aton+0x64>
  803062:	83 c0 01             	add    $0x1,%eax
  803065:	8d 78 ff             	lea    -0x1(%eax),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  803068:	89 d1                	mov    %edx,%ecx
  80306a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80306d:	80 fb 09             	cmp    $0x9,%bl
  803070:	77 0d                	ja     80307f <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  803072:	0f af 75 e0          	imul   -0x20(%ebp),%esi
  803076:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  80307a:	0f be 10             	movsbl (%eax),%edx
  80307d:	eb e3                	jmp    803062 <inet_aton+0x61>
      } else if (base == 16 && isxdigit(c)) {
  80307f:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  803083:	75 2b                	jne    8030b0 <inet_aton+0xaf>
  803085:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  803088:	88 5d d3             	mov    %bl,-0x2d(%ebp)
  80308b:	80 fb 05             	cmp    $0x5,%bl
  80308e:	76 08                	jbe    803098 <inet_aton+0x97>
  803090:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  803093:	80 fb 05             	cmp    $0x5,%bl
  803096:	77 18                	ja     8030b0 <inet_aton+0xaf>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  803098:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80309c:	19 c9                	sbb    %ecx,%ecx
  80309e:	83 e1 20             	and    $0x20,%ecx
  8030a1:	c1 e6 04             	shl    $0x4,%esi
  8030a4:	29 ca                	sub    %ecx,%edx
  8030a6:	8d 52 c9             	lea    -0x37(%edx),%edx
  8030a9:	09 d6                	or     %edx,%esi
        c = *++cp;
  8030ab:	0f be 10             	movsbl (%eax),%edx
  8030ae:	eb b2                	jmp    803062 <inet_aton+0x61>
      } else
        break;
    }
    if (c == '.') {
  8030b0:	83 fa 2e             	cmp    $0x2e,%edx
  8030b3:	75 2c                	jne    8030e1 <inet_aton+0xe0>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8030b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8030b8:	39 55 d8             	cmp    %edx,-0x28(%ebp)
  8030bb:	0f 83 0a 01 00 00    	jae    8031cb <inet_aton+0x1ca>
        return (0);
      *pp++ = val;
  8030c1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8030c4:	89 31                	mov    %esi,(%ecx)
      c = *++cp;
  8030c6:	8d 47 01             	lea    0x1(%edi),%eax
  8030c9:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8030cc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8030cf:	80 f9 09             	cmp    $0x9,%cl
  8030d2:	0f 87 f3 00 00 00    	ja     8031cb <inet_aton+0x1ca>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  8030d8:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  8030dc:	e9 47 ff ff ff       	jmp    803028 <inet_aton+0x27>
  8030e1:	89 f3                	mov    %esi,%ebx
  8030e3:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8030e5:	85 d2                	test   %edx,%edx
  8030e7:	74 37                	je     803120 <inet_aton+0x11f>
  8030e9:	80 f9 1f             	cmp    $0x1f,%cl
  8030ec:	0f 86 d9 00 00 00    	jbe    8031cb <inet_aton+0x1ca>
  8030f2:	84 d2                	test   %dl,%dl
  8030f4:	0f 88 d1 00 00 00    	js     8031cb <inet_aton+0x1ca>
  8030fa:	83 fa 20             	cmp    $0x20,%edx
  8030fd:	8d 76 00             	lea    0x0(%esi),%esi
  803100:	74 1e                	je     803120 <inet_aton+0x11f>
  803102:	83 fa 0c             	cmp    $0xc,%edx
  803105:	74 19                	je     803120 <inet_aton+0x11f>
  803107:	83 fa 0a             	cmp    $0xa,%edx
  80310a:	74 14                	je     803120 <inet_aton+0x11f>
  80310c:	83 fa 0d             	cmp    $0xd,%edx
  80310f:	90                   	nop
  803110:	74 0e                	je     803120 <inet_aton+0x11f>
  803112:	83 fa 09             	cmp    $0x9,%edx
  803115:	74 09                	je     803120 <inet_aton+0x11f>
  803117:	83 fa 0b             	cmp    $0xb,%edx
  80311a:	0f 85 ab 00 00 00    	jne    8031cb <inet_aton+0x1ca>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  803120:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  803123:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  803126:	29 d1                	sub    %edx,%ecx
  803128:	89 ca                	mov    %ecx,%edx
  80312a:	c1 fa 02             	sar    $0x2,%edx
  80312d:	83 c2 01             	add    $0x1,%edx
  803130:	83 fa 02             	cmp    $0x2,%edx
  803133:	74 2d                	je     803162 <inet_aton+0x161>
  803135:	83 fa 02             	cmp    $0x2,%edx
  803138:	7f 10                	jg     80314a <inet_aton+0x149>
  80313a:	85 d2                	test   %edx,%edx
  80313c:	0f 84 89 00 00 00    	je     8031cb <inet_aton+0x1ca>
  803142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803148:	eb 62                	jmp    8031ac <inet_aton+0x1ab>
  80314a:	83 fa 03             	cmp    $0x3,%edx
  80314d:	8d 76 00             	lea    0x0(%esi),%esi
  803150:	74 22                	je     803174 <inet_aton+0x173>
  803152:	83 fa 04             	cmp    $0x4,%edx
  803155:	8d 76 00             	lea    0x0(%esi),%esi
  803158:	75 52                	jne    8031ac <inet_aton+0x1ab>
  80315a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803160:	eb 2b                	jmp    80318d <inet_aton+0x18c>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  803162:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  803167:	90                   	nop
  803168:	77 61                	ja     8031cb <inet_aton+0x1ca>
      return (0);
    val |= parts[0] << 24;
  80316a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80316d:	c1 e3 18             	shl    $0x18,%ebx
  803170:	09 c3                	or     %eax,%ebx
    break;
  803172:	eb 38                	jmp    8031ac <inet_aton+0x1ab>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  803174:	3d ff ff 00 00       	cmp    $0xffff,%eax
  803179:	77 50                	ja     8031cb <inet_aton+0x1ca>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80317b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  80317e:	c1 e3 10             	shl    $0x10,%ebx
  803181:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803184:	c1 e2 18             	shl    $0x18,%edx
  803187:	09 d3                	or     %edx,%ebx
  803189:	09 c3                	or     %eax,%ebx
    break;
  80318b:	eb 1f                	jmp    8031ac <inet_aton+0x1ab>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80318d:	3d ff 00 00 00       	cmp    $0xff,%eax
  803192:	77 37                	ja     8031cb <inet_aton+0x1ca>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  803194:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  803197:	c1 e3 10             	shl    $0x10,%ebx
  80319a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80319d:	c1 e2 18             	shl    $0x18,%edx
  8031a0:	09 d3                	or     %edx,%ebx
  8031a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8031a5:	c1 e2 08             	shl    $0x8,%edx
  8031a8:	09 d3                	or     %edx,%ebx
  8031aa:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  8031ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8031b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8031b5:	74 19                	je     8031d0 <inet_aton+0x1cf>
    addr->s_addr = htonl(val);
  8031b7:	89 1c 24             	mov    %ebx,(%esp)
  8031ba:	e8 16 fe ff ff       	call   802fd5 <htonl>
  8031bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8031c2:	89 03                	mov    %eax,(%ebx)
  8031c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8031c9:	eb 05                	jmp    8031d0 <inet_aton+0x1cf>
  8031cb:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  8031d0:	83 c4 28             	add    $0x28,%esp
  8031d3:	5b                   	pop    %ebx
  8031d4:	5e                   	pop    %esi
  8031d5:	5f                   	pop    %edi
  8031d6:	5d                   	pop    %ebp
  8031d7:	c3                   	ret    

008031d8 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8031d8:	55                   	push   %ebp
  8031d9:	89 e5                	mov    %esp,%ebp
  8031db:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8031de:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8031e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8031e8:	89 04 24             	mov    %eax,(%esp)
  8031eb:	e8 11 fe ff ff       	call   803001 <inet_aton>
  8031f0:	83 f8 01             	cmp    $0x1,%eax
  8031f3:	19 c0                	sbb    %eax,%eax
  8031f5:	0b 45 fc             	or     -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  8031f8:	c9                   	leave  
  8031f9:	c3                   	ret    

008031fa <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8031fa:	55                   	push   %ebp
  8031fb:	89 e5                	mov    %esp,%ebp
  8031fd:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  803200:	8b 45 08             	mov    0x8(%ebp),%eax
  803203:	89 04 24             	mov    %eax,(%esp)
  803206:	e8 ca fd ff ff       	call   802fd5 <htonl>
}
  80320b:	c9                   	leave  
  80320c:	c3                   	ret    
  80320d:	00 00                	add    %al,(%eax)
	...

00803210 <__udivdi3>:
  803210:	55                   	push   %ebp
  803211:	89 e5                	mov    %esp,%ebp
  803213:	57                   	push   %edi
  803214:	56                   	push   %esi
  803215:	83 ec 10             	sub    $0x10,%esp
  803218:	8b 45 14             	mov    0x14(%ebp),%eax
  80321b:	8b 55 08             	mov    0x8(%ebp),%edx
  80321e:	8b 75 10             	mov    0x10(%ebp),%esi
  803221:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803224:	85 c0                	test   %eax,%eax
  803226:	89 55 f0             	mov    %edx,-0x10(%ebp)
  803229:	75 35                	jne    803260 <__udivdi3+0x50>
  80322b:	39 fe                	cmp    %edi,%esi
  80322d:	77 61                	ja     803290 <__udivdi3+0x80>
  80322f:	85 f6                	test   %esi,%esi
  803231:	75 0b                	jne    80323e <__udivdi3+0x2e>
  803233:	b8 01 00 00 00       	mov    $0x1,%eax
  803238:	31 d2                	xor    %edx,%edx
  80323a:	f7 f6                	div    %esi
  80323c:	89 c6                	mov    %eax,%esi
  80323e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  803241:	31 d2                	xor    %edx,%edx
  803243:	89 f8                	mov    %edi,%eax
  803245:	f7 f6                	div    %esi
  803247:	89 c7                	mov    %eax,%edi
  803249:	89 c8                	mov    %ecx,%eax
  80324b:	f7 f6                	div    %esi
  80324d:	89 c1                	mov    %eax,%ecx
  80324f:	89 fa                	mov    %edi,%edx
  803251:	89 c8                	mov    %ecx,%eax
  803253:	83 c4 10             	add    $0x10,%esp
  803256:	5e                   	pop    %esi
  803257:	5f                   	pop    %edi
  803258:	5d                   	pop    %ebp
  803259:	c3                   	ret    
  80325a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803260:	39 f8                	cmp    %edi,%eax
  803262:	77 1c                	ja     803280 <__udivdi3+0x70>
  803264:	0f bd d0             	bsr    %eax,%edx
  803267:	83 f2 1f             	xor    $0x1f,%edx
  80326a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80326d:	75 39                	jne    8032a8 <__udivdi3+0x98>
  80326f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  803272:	0f 86 a0 00 00 00    	jbe    803318 <__udivdi3+0x108>
  803278:	39 f8                	cmp    %edi,%eax
  80327a:	0f 82 98 00 00 00    	jb     803318 <__udivdi3+0x108>
  803280:	31 ff                	xor    %edi,%edi
  803282:	31 c9                	xor    %ecx,%ecx
  803284:	89 c8                	mov    %ecx,%eax
  803286:	89 fa                	mov    %edi,%edx
  803288:	83 c4 10             	add    $0x10,%esp
  80328b:	5e                   	pop    %esi
  80328c:	5f                   	pop    %edi
  80328d:	5d                   	pop    %ebp
  80328e:	c3                   	ret    
  80328f:	90                   	nop
  803290:	89 d1                	mov    %edx,%ecx
  803292:	89 fa                	mov    %edi,%edx
  803294:	89 c8                	mov    %ecx,%eax
  803296:	31 ff                	xor    %edi,%edi
  803298:	f7 f6                	div    %esi
  80329a:	89 c1                	mov    %eax,%ecx
  80329c:	89 fa                	mov    %edi,%edx
  80329e:	89 c8                	mov    %ecx,%eax
  8032a0:	83 c4 10             	add    $0x10,%esp
  8032a3:	5e                   	pop    %esi
  8032a4:	5f                   	pop    %edi
  8032a5:	5d                   	pop    %ebp
  8032a6:	c3                   	ret    
  8032a7:	90                   	nop
  8032a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8032ac:	89 f2                	mov    %esi,%edx
  8032ae:	d3 e0                	shl    %cl,%eax
  8032b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8032b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8032b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8032bb:	89 c1                	mov    %eax,%ecx
  8032bd:	d3 ea                	shr    %cl,%edx
  8032bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8032c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8032c6:	d3 e6                	shl    %cl,%esi
  8032c8:	89 c1                	mov    %eax,%ecx
  8032ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8032cd:	89 fe                	mov    %edi,%esi
  8032cf:	d3 ee                	shr    %cl,%esi
  8032d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8032d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8032d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8032db:	d3 e7                	shl    %cl,%edi
  8032dd:	89 c1                	mov    %eax,%ecx
  8032df:	d3 ea                	shr    %cl,%edx
  8032e1:	09 d7                	or     %edx,%edi
  8032e3:	89 f2                	mov    %esi,%edx
  8032e5:	89 f8                	mov    %edi,%eax
  8032e7:	f7 75 ec             	divl   -0x14(%ebp)
  8032ea:	89 d6                	mov    %edx,%esi
  8032ec:	89 c7                	mov    %eax,%edi
  8032ee:	f7 65 e8             	mull   -0x18(%ebp)
  8032f1:	39 d6                	cmp    %edx,%esi
  8032f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8032f6:	72 30                	jb     803328 <__udivdi3+0x118>
  8032f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8032fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8032ff:	d3 e2                	shl    %cl,%edx
  803301:	39 c2                	cmp    %eax,%edx
  803303:	73 05                	jae    80330a <__udivdi3+0xfa>
  803305:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  803308:	74 1e                	je     803328 <__udivdi3+0x118>
  80330a:	89 f9                	mov    %edi,%ecx
  80330c:	31 ff                	xor    %edi,%edi
  80330e:	e9 71 ff ff ff       	jmp    803284 <__udivdi3+0x74>
  803313:	90                   	nop
  803314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803318:	31 ff                	xor    %edi,%edi
  80331a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80331f:	e9 60 ff ff ff       	jmp    803284 <__udivdi3+0x74>
  803324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803328:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80332b:	31 ff                	xor    %edi,%edi
  80332d:	89 c8                	mov    %ecx,%eax
  80332f:	89 fa                	mov    %edi,%edx
  803331:	83 c4 10             	add    $0x10,%esp
  803334:	5e                   	pop    %esi
  803335:	5f                   	pop    %edi
  803336:	5d                   	pop    %ebp
  803337:	c3                   	ret    
	...

00803340 <__umoddi3>:
  803340:	55                   	push   %ebp
  803341:	89 e5                	mov    %esp,%ebp
  803343:	57                   	push   %edi
  803344:	56                   	push   %esi
  803345:	83 ec 20             	sub    $0x20,%esp
  803348:	8b 55 14             	mov    0x14(%ebp),%edx
  80334b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80334e:	8b 7d 10             	mov    0x10(%ebp),%edi
  803351:	8b 75 0c             	mov    0xc(%ebp),%esi
  803354:	85 d2                	test   %edx,%edx
  803356:	89 c8                	mov    %ecx,%eax
  803358:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80335b:	75 13                	jne    803370 <__umoddi3+0x30>
  80335d:	39 f7                	cmp    %esi,%edi
  80335f:	76 3f                	jbe    8033a0 <__umoddi3+0x60>
  803361:	89 f2                	mov    %esi,%edx
  803363:	f7 f7                	div    %edi
  803365:	89 d0                	mov    %edx,%eax
  803367:	31 d2                	xor    %edx,%edx
  803369:	83 c4 20             	add    $0x20,%esp
  80336c:	5e                   	pop    %esi
  80336d:	5f                   	pop    %edi
  80336e:	5d                   	pop    %ebp
  80336f:	c3                   	ret    
  803370:	39 f2                	cmp    %esi,%edx
  803372:	77 4c                	ja     8033c0 <__umoddi3+0x80>
  803374:	0f bd ca             	bsr    %edx,%ecx
  803377:	83 f1 1f             	xor    $0x1f,%ecx
  80337a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80337d:	75 51                	jne    8033d0 <__umoddi3+0x90>
  80337f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  803382:	0f 87 e0 00 00 00    	ja     803468 <__umoddi3+0x128>
  803388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80338b:	29 f8                	sub    %edi,%eax
  80338d:	19 d6                	sbb    %edx,%esi
  80338f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803392:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803395:	89 f2                	mov    %esi,%edx
  803397:	83 c4 20             	add    $0x20,%esp
  80339a:	5e                   	pop    %esi
  80339b:	5f                   	pop    %edi
  80339c:	5d                   	pop    %ebp
  80339d:	c3                   	ret    
  80339e:	66 90                	xchg   %ax,%ax
  8033a0:	85 ff                	test   %edi,%edi
  8033a2:	75 0b                	jne    8033af <__umoddi3+0x6f>
  8033a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8033a9:	31 d2                	xor    %edx,%edx
  8033ab:	f7 f7                	div    %edi
  8033ad:	89 c7                	mov    %eax,%edi
  8033af:	89 f0                	mov    %esi,%eax
  8033b1:	31 d2                	xor    %edx,%edx
  8033b3:	f7 f7                	div    %edi
  8033b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033b8:	f7 f7                	div    %edi
  8033ba:	eb a9                	jmp    803365 <__umoddi3+0x25>
  8033bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8033c0:	89 c8                	mov    %ecx,%eax
  8033c2:	89 f2                	mov    %esi,%edx
  8033c4:	83 c4 20             	add    $0x20,%esp
  8033c7:	5e                   	pop    %esi
  8033c8:	5f                   	pop    %edi
  8033c9:	5d                   	pop    %ebp
  8033ca:	c3                   	ret    
  8033cb:	90                   	nop
  8033cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8033d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8033d4:	d3 e2                	shl    %cl,%edx
  8033d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8033d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8033de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8033e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8033e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8033e8:	89 fa                	mov    %edi,%edx
  8033ea:	d3 ea                	shr    %cl,%edx
  8033ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8033f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8033f3:	d3 e7                	shl    %cl,%edi
  8033f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8033f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8033fc:	89 f2                	mov    %esi,%edx
  8033fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  803401:	89 c7                	mov    %eax,%edi
  803403:	d3 ea                	shr    %cl,%edx
  803405:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803409:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80340c:	89 c2                	mov    %eax,%edx
  80340e:	d3 e6                	shl    %cl,%esi
  803410:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803414:	d3 ea                	shr    %cl,%edx
  803416:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80341a:	09 d6                	or     %edx,%esi
  80341c:	89 f0                	mov    %esi,%eax
  80341e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  803421:	d3 e7                	shl    %cl,%edi
  803423:	89 f2                	mov    %esi,%edx
  803425:	f7 75 f4             	divl   -0xc(%ebp)
  803428:	89 d6                	mov    %edx,%esi
  80342a:	f7 65 e8             	mull   -0x18(%ebp)
  80342d:	39 d6                	cmp    %edx,%esi
  80342f:	72 2b                	jb     80345c <__umoddi3+0x11c>
  803431:	39 c7                	cmp    %eax,%edi
  803433:	72 23                	jb     803458 <__umoddi3+0x118>
  803435:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803439:	29 c7                	sub    %eax,%edi
  80343b:	19 d6                	sbb    %edx,%esi
  80343d:	89 f0                	mov    %esi,%eax
  80343f:	89 f2                	mov    %esi,%edx
  803441:	d3 ef                	shr    %cl,%edi
  803443:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803447:	d3 e0                	shl    %cl,%eax
  803449:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80344d:	09 f8                	or     %edi,%eax
  80344f:	d3 ea                	shr    %cl,%edx
  803451:	83 c4 20             	add    $0x20,%esp
  803454:	5e                   	pop    %esi
  803455:	5f                   	pop    %edi
  803456:	5d                   	pop    %ebp
  803457:	c3                   	ret    
  803458:	39 d6                	cmp    %edx,%esi
  80345a:	75 d9                	jne    803435 <__umoddi3+0xf5>
  80345c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80345f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  803462:	eb d1                	jmp    803435 <__umoddi3+0xf5>
  803464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803468:	39 f2                	cmp    %esi,%edx
  80346a:	0f 82 18 ff ff ff    	jb     803388 <__umoddi3+0x48>
  803470:	e9 1d ff ff ff       	jmp    803392 <__umoddi3+0x52>
