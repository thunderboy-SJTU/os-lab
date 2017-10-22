
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 bb 01 00 00       	call   8001ec <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 00 2c 80 00 	movl   $0x802c00,(%esp)
  800045:	e8 73 02 00 00       	call   8002bd <cprintf>
	exit();
  80004a:	e8 f1 01 00 00       	call   800240 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <umain>:

void umain(int argc, char **argv)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 5c             	sub    $0x5c,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  80005a:	c7 04 24 04 2c 80 00 	movl   $0x802c04,(%esp)
  800061:	e8 57 02 00 00       	call   8002bd <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800066:	c7 04 24 14 2c 80 00 	movl   $0x802c14,(%esp)
  80006d:	e8 e6 28 00 00       	call   802958 <inet_addr>
  800072:	89 44 24 08          	mov    %eax,0x8(%esp)
  800076:	c7 44 24 04 14 2c 80 	movl   $0x802c14,0x4(%esp)
  80007d:	00 
  80007e:	c7 04 24 1e 2c 80 00 	movl   $0x802c1e,(%esp)
  800085:	e8 33 02 00 00       	call   8002bd <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  80008a:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800099:	00 
  80009a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8000a1:	e8 08 20 00 00       	call   8020ae <socket>
  8000a6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  8000a9:	85 c0                	test   %eax,%eax
  8000ab:	79 0a                	jns    8000b7 <umain+0x66>
		die("Failed to create socket");
  8000ad:	b8 33 2c 80 00       	mov    $0x802c33,%eax
  8000b2:	e8 7d ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  8000b7:	c7 04 24 4b 2c 80 00 	movl   $0x802c4b,(%esp)
  8000be:	e8 fa 01 00 00       	call   8002bd <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000d6:	89 1c 24             	mov    %ebx,(%esp)
  8000d9:	e8 98 0c 00 00       	call   800d76 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000de:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000e2:	c7 04 24 14 2c 80 00 	movl   $0x802c14,(%esp)
  8000e9:	e8 6a 28 00 00       	call   802958 <inet_addr>
  8000ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000f1:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000f8:	e8 37 26 00 00       	call   802734 <htons>
  8000fd:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  800101:	c7 04 24 5a 2c 80 00 	movl   $0x802c5a,(%esp)
  800108:	e8 b0 01 00 00       	call   8002bd <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  80010d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800114:	00 
  800115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800119:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 07 20 00 00       	call   80212b <connect>
  800124:	85 c0                	test   %eax,%eax
  800126:	79 0a                	jns    800132 <umain+0xe1>
		die("Failed to connect with server");
  800128:	b8 77 2c 80 00       	mov    $0x802c77,%eax
  80012d:	e8 02 ff ff ff       	call   800034 <die>

	cprintf("connected to server\n");
  800132:	c7 04 24 95 2c 80 00 	movl   $0x802c95,(%esp)
  800139:	e8 7f 01 00 00       	call   8002bd <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80013e:	a1 00 40 80 00       	mov    0x804000,%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 55 0a 00 00       	call   800ba0 <strlen>
  80014b:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80014e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800152:	a1 00 40 80 00       	mov    0x804000,%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 cf 17 00 00       	call   801935 <write>
  800166:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  800169:	74 0a                	je     800175 <umain+0x124>
		die("Mismatch in number of sent bytes");
  80016b:	b8 c4 2c 80 00       	mov    $0x802cc4,%eax
  800170:	e8 bf fe ff ff       	call   800034 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800175:	c7 04 24 aa 2c 80 00 	movl   $0x802caa,(%esp)
  80017c:	e8 3c 01 00 00       	call   8002bd <cprintf>
	while (received < echolen) {
  800181:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  800185:	74 43                	je     8001ca <umain+0x179>
  800187:	bf 00 00 00 00       	mov    $0x0,%edi
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018c:	8d 75 b8             	lea    -0x48(%ebp),%esi
  80018f:	c7 44 24 08 1f 00 00 	movl   $0x1f,0x8(%esp)
  800196:	00 
  800197:	89 74 24 04          	mov    %esi,0x4(%esp)
  80019b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80019e:	89 04 24             	mov    %eax,(%esp)
  8001a1:	e8 18 18 00 00       	call   8019be <read>
  8001a6:	89 c3                	mov    %eax,%ebx
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	7f 0a                	jg     8001b6 <umain+0x165>
			die("Failed to receive bytes from server");
  8001ac:	b8 e8 2c 80 00       	mov    $0x802ce8,%eax
  8001b1:	e8 7e fe ff ff       	call   800034 <die>
		}
		received += bytes;
  8001b6:	01 df                	add    %ebx,%edi
		buffer[bytes] = '\0';        // Assure null terminated string
  8001b8:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  8001bd:	89 34 24             	mov    %esi,(%esp)
  8001c0:	e8 f8 00 00 00       	call   8002bd <cprintf>
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  8001c5:	39 7d b0             	cmp    %edi,-0x50(%ebp)
  8001c8:	77 c5                	ja     80018f <umain+0x13e>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001ca:	c7 04 24 b4 2c 80 00 	movl   $0x802cb4,(%esp)
  8001d1:	e8 e7 00 00 00       	call   8002bd <cprintf>

	close(sock);
  8001d6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	e8 3d 19 00 00       	call   801b1e <close>
}
  8001e1:	83 c4 5c             	add    $0x5c,%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5f                   	pop    %edi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
  8001e9:	00 00                	add    %al,(%eax)
	...

008001ec <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 18             	sub    $0x18,%esp
  8001f2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001f5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8001f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001fe:	e8 04 14 00 00       	call   801607 <sys_getenvid>
  800203:	25 ff 03 00 00       	and    $0x3ff,%eax
  800208:	89 c2                	mov    %eax,%edx
  80020a:	c1 e2 07             	shl    $0x7,%edx
  80020d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800214:	a3 18 50 80 00       	mov    %eax,0x805018
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800219:	85 f6                	test   %esi,%esi
  80021b:	7e 07                	jle    800224 <libmain+0x38>
		binaryname = argv[0];
  80021d:	8b 03                	mov    (%ebx),%eax
  80021f:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800224:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800228:	89 34 24             	mov    %esi,(%esp)
  80022b:	e8 21 fe ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  800230:	e8 0b 00 00 00       	call   800240 <exit>
}
  800235:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800238:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80023b:	89 ec                	mov    %ebp,%esp
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    
	...

00800240 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800246:	e8 50 19 00 00       	call   801b9b <close_all>
	sys_env_destroy(0);
  80024b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800252:	e8 f0 13 00 00       	call   801647 <sys_env_destroy>
}
  800257:	c9                   	leave  
  800258:	c3                   	ret    
  800259:	00 00                	add    %al,(%eax)
	...

0080025c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800265:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026c:	00 00 00 
	b.cnt = 0;
  80026f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800276:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800279:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	89 44 24 08          	mov    %eax,0x8(%esp)
  800287:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800291:	c7 04 24 d7 02 80 00 	movl   $0x8002d7,(%esp)
  800298:	e8 cf 01 00 00       	call   80046c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ad:	89 04 24             	mov    %eax,(%esp)
  8002b0:	e8 67 0d 00 00       	call   80101c <sys_cputs>

	return b.cnt;
}
  8002b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002c3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	e8 87 ff ff ff       	call   80025c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	53                   	push   %ebx
  8002db:	83 ec 14             	sub    $0x14,%esp
  8002de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e1:	8b 03                	mov    (%ebx),%eax
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002ea:	83 c0 01             	add    $0x1,%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f4:	75 19                	jne    80030f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002f6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002fd:	00 
  8002fe:	8d 43 08             	lea    0x8(%ebx),%eax
  800301:	89 04 24             	mov    %eax,(%esp)
  800304:	e8 13 0d 00 00       	call   80101c <sys_cputs>
		b->idx = 0;
  800309:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80030f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800313:	83 c4 14             	add    $0x14,%esp
  800316:	5b                   	pop    %ebx
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    
  800319:	00 00                	add    %al,(%eax)
  80031b:	00 00                	add    %al,(%eax)
  80031d:	00 00                	add    %al,(%eax)
	...

00800320 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 4c             	sub    $0x4c,%esp
  800329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032c:	89 d6                	mov    %edx,%esi
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800334:	8b 55 0c             	mov    0xc(%ebp),%edx
  800337:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80033a:	8b 45 10             	mov    0x10(%ebp),%eax
  80033d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800340:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800343:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800346:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034b:	39 d1                	cmp    %edx,%ecx
  80034d:	72 07                	jb     800356 <printnum_v2+0x36>
  80034f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800352:	39 d0                	cmp    %edx,%eax
  800354:	77 5f                	ja     8003b5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800356:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80035a:	83 eb 01             	sub    $0x1,%ebx
  80035d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800361:	89 44 24 08          	mov    %eax,0x8(%esp)
  800365:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800369:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80036d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800370:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800373:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800376:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80037a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800381:	00 
  800382:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80038b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80038f:	e8 fc 25 00 00       	call   802990 <__udivdi3>
  800394:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800397:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80039a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80039e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003a2:	89 04 24             	mov    %eax,(%esp)
  8003a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003a9:	89 f2                	mov    %esi,%edx
  8003ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ae:	e8 6d ff ff ff       	call   800320 <printnum_v2>
  8003b3:	eb 1e                	jmp    8003d3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8003b5:	83 ff 2d             	cmp    $0x2d,%edi
  8003b8:	74 19                	je     8003d3 <printnum_v2+0xb3>
		while (--width > 0)
  8003ba:	83 eb 01             	sub    $0x1,%ebx
  8003bd:	85 db                	test   %ebx,%ebx
  8003bf:	90                   	nop
  8003c0:	7e 11                	jle    8003d3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8003c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c6:	89 3c 24             	mov    %edi,(%esp)
  8003c9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8003cc:	83 eb 01             	sub    $0x1,%ebx
  8003cf:	85 db                	test   %ebx,%ebx
  8003d1:	7f ef                	jg     8003c2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e9:	00 
  8003ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003ed:	89 14 24             	mov    %edx,(%esp)
  8003f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003f7:	e8 c4 26 00 00       	call   802ac0 <__umoddi3>
  8003fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800400:	0f be 80 16 2d 80 00 	movsbl 0x802d16(%eax),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80040d:	83 c4 4c             	add    $0x4c,%esp
  800410:	5b                   	pop    %ebx
  800411:	5e                   	pop    %esi
  800412:	5f                   	pop    %edi
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800418:	83 fa 01             	cmp    $0x1,%edx
  80041b:	7e 0e                	jle    80042b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80041d:	8b 10                	mov    (%eax),%edx
  80041f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800422:	89 08                	mov    %ecx,(%eax)
  800424:	8b 02                	mov    (%edx),%eax
  800426:	8b 52 04             	mov    0x4(%edx),%edx
  800429:	eb 22                	jmp    80044d <getuint+0x38>
	else if (lflag)
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 10                	je     80043f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80042f:	8b 10                	mov    (%eax),%edx
  800431:	8d 4a 04             	lea    0x4(%edx),%ecx
  800434:	89 08                	mov    %ecx,(%eax)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	ba 00 00 00 00       	mov    $0x0,%edx
  80043d:	eb 0e                	jmp    80044d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80043f:	8b 10                	mov    (%eax),%edx
  800441:	8d 4a 04             	lea    0x4(%edx),%ecx
  800444:	89 08                	mov    %ecx,(%eax)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800455:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	3b 50 04             	cmp    0x4(%eax),%edx
  80045e:	73 0a                	jae    80046a <sprintputch+0x1b>
		*b->buf++ = ch;
  800460:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800463:	88 0a                	mov    %cl,(%edx)
  800465:	83 c2 01             	add    $0x1,%edx
  800468:	89 10                	mov    %edx,(%eax)
}
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	57                   	push   %edi
  800470:	56                   	push   %esi
  800471:	53                   	push   %ebx
  800472:	83 ec 6c             	sub    $0x6c,%esp
  800475:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800478:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80047f:	eb 1a                	jmp    80049b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800481:	85 c0                	test   %eax,%eax
  800483:	0f 84 66 06 00 00    	je     800aef <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800489:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	ff 55 08             	call   *0x8(%ebp)
  800496:	eb 03                	jmp    80049b <vprintfmt+0x2f>
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80049b:	0f b6 07             	movzbl (%edi),%eax
  80049e:	83 c7 01             	add    $0x1,%edi
  8004a1:	83 f8 25             	cmp    $0x25,%eax
  8004a4:	75 db                	jne    800481 <vprintfmt+0x15>
  8004a6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8004aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004af:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8004b6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8004bb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004c2:	be 00 00 00 00       	mov    $0x0,%esi
  8004c7:	eb 06                	jmp    8004cf <vprintfmt+0x63>
  8004c9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8004cd:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	0f b6 17             	movzbl (%edi),%edx
  8004d2:	0f b6 c2             	movzbl %dl,%eax
  8004d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d8:	8d 47 01             	lea    0x1(%edi),%eax
  8004db:	83 ea 23             	sub    $0x23,%edx
  8004de:	80 fa 55             	cmp    $0x55,%dl
  8004e1:	0f 87 60 05 00 00    	ja     800a47 <vprintfmt+0x5db>
  8004e7:	0f b6 d2             	movzbl %dl,%edx
  8004ea:	ff 24 95 00 2f 80 00 	jmp    *0x802f00(,%edx,4)
  8004f1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8004f6:	eb d5                	jmp    8004cd <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004fb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8004fe:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800501:	8d 7a d0             	lea    -0x30(%edx),%edi
  800504:	83 ff 09             	cmp    $0x9,%edi
  800507:	76 08                	jbe    800511 <vprintfmt+0xa5>
  800509:	eb 40                	jmp    80054b <vprintfmt+0xdf>
  80050b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80050f:	eb bc                	jmp    8004cd <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800511:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800514:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800517:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80051b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80051e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800521:	83 ff 09             	cmp    $0x9,%edi
  800524:	76 eb                	jbe    800511 <vprintfmt+0xa5>
  800526:	eb 23                	jmp    80054b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800528:	8b 55 14             	mov    0x14(%ebp),%edx
  80052b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80052e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800531:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800533:	eb 16                	jmp    80054b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800535:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800538:	c1 fa 1f             	sar    $0x1f,%edx
  80053b:	f7 d2                	not    %edx
  80053d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800540:	eb 8b                	jmp    8004cd <vprintfmt+0x61>
  800542:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800549:	eb 82                	jmp    8004cd <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80054b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054f:	0f 89 78 ff ff ff    	jns    8004cd <vprintfmt+0x61>
  800555:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800558:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80055b:	e9 6d ff ff ff       	jmp    8004cd <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800560:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800563:	e9 65 ff ff ff       	jmp    8004cd <vprintfmt+0x61>
  800568:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 04             	lea    0x4(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 55 0c             	mov    0xc(%ebp),%edx
  800577:	89 54 24 04          	mov    %edx,0x4(%esp)
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 04 24             	mov    %eax,(%esp)
  800580:	ff 55 08             	call   *0x8(%ebp)
  800583:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800586:	e9 10 ff ff ff       	jmp    80049b <vprintfmt+0x2f>
  80058b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 c2                	mov    %eax,%edx
  80059b:	c1 fa 1f             	sar    $0x1f,%edx
  80059e:	31 d0                	xor    %edx,%eax
  8005a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a2:	83 f8 0f             	cmp    $0xf,%eax
  8005a5:	7f 0b                	jg     8005b2 <vprintfmt+0x146>
  8005a7:	8b 14 85 60 30 80 00 	mov    0x803060(,%eax,4),%edx
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	75 26                	jne    8005d8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8005b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b6:	c7 44 24 08 27 2d 80 	movl   $0x802d27,0x8(%esp)
  8005bd:	00 
  8005be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005c8:	89 1c 24             	mov    %ebx,(%esp)
  8005cb:	e8 a7 05 00 00       	call   800b77 <printfmt>
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d3:	e9 c3 fe ff ff       	jmp    80049b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005dc:	c7 44 24 08 7e 31 80 	movl   $0x80317e,0x8(%esp)
  8005e3:	00 
  8005e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ee:	89 14 24             	mov    %edx,(%esp)
  8005f1:	e8 81 05 00 00       	call   800b77 <printfmt>
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f9:	e9 9d fe ff ff       	jmp    80049b <vprintfmt+0x2f>
  8005fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800601:	89 c7                	mov    %eax,%edi
  800603:	89 d9                	mov    %ebx,%ecx
  800605:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800608:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 30                	mov    (%eax),%esi
  800616:	85 f6                	test   %esi,%esi
  800618:	75 05                	jne    80061f <vprintfmt+0x1b3>
  80061a:	be 30 2d 80 00       	mov    $0x802d30,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80061f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800623:	7e 06                	jle    80062b <vprintfmt+0x1bf>
  800625:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800629:	75 10                	jne    80063b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062b:	0f be 06             	movsbl (%esi),%eax
  80062e:	85 c0                	test   %eax,%eax
  800630:	0f 85 a2 00 00 00    	jne    8006d8 <vprintfmt+0x26c>
  800636:	e9 92 00 00 00       	jmp    8006cd <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80063f:	89 34 24             	mov    %esi,(%esp)
  800642:	e8 74 05 00 00       	call   800bbb <strnlen>
  800647:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80064a:	29 c2                	sub    %eax,%edx
  80064c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80064f:	85 d2                	test   %edx,%edx
  800651:	7e d8                	jle    80062b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800653:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800657:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80065a:	89 d3                	mov    %edx,%ebx
  80065c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80065f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800662:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800665:	89 ce                	mov    %ecx,%esi
  800667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066b:	89 34 24             	mov    %esi,(%esp)
  80066e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 eb 01             	sub    $0x1,%ebx
  800674:	85 db                	test   %ebx,%ebx
  800676:	7f ef                	jg     800667 <vprintfmt+0x1fb>
  800678:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80067b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80067e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800681:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800688:	eb a1                	jmp    80062b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80068a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80068e:	74 1b                	je     8006ab <vprintfmt+0x23f>
  800690:	8d 50 e0             	lea    -0x20(%eax),%edx
  800693:	83 fa 5e             	cmp    $0x5e,%edx
  800696:	76 13                	jbe    8006ab <vprintfmt+0x23f>
					putch('?', putdat);
  800698:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006a9:	eb 0d                	jmp    8006b8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b2:	89 04 24             	mov    %eax,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b8:	83 ef 01             	sub    $0x1,%edi
  8006bb:	0f be 06             	movsbl (%esi),%eax
  8006be:	85 c0                	test   %eax,%eax
  8006c0:	74 05                	je     8006c7 <vprintfmt+0x25b>
  8006c2:	83 c6 01             	add    $0x1,%esi
  8006c5:	eb 1a                	jmp    8006e1 <vprintfmt+0x275>
  8006c7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006ca:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d1:	7f 1f                	jg     8006f2 <vprintfmt+0x286>
  8006d3:	e9 c0 fd ff ff       	jmp    800498 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d8:	83 c6 01             	add    $0x1,%esi
  8006db:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006de:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006e1:	85 db                	test   %ebx,%ebx
  8006e3:	78 a5                	js     80068a <vprintfmt+0x21e>
  8006e5:	83 eb 01             	sub    $0x1,%ebx
  8006e8:	79 a0                	jns    80068a <vprintfmt+0x21e>
  8006ea:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006ed:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006f0:	eb db                	jmp    8006cd <vprintfmt+0x261>
  8006f2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006f8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006fb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800702:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800709:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80070b:	83 eb 01             	sub    $0x1,%ebx
  80070e:	85 db                	test   %ebx,%ebx
  800710:	7f ec                	jg     8006fe <vprintfmt+0x292>
  800712:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800715:	e9 81 fd ff ff       	jmp    80049b <vprintfmt+0x2f>
  80071a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80071d:	83 fe 01             	cmp    $0x1,%esi
  800720:	7e 10                	jle    800732 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 50 08             	lea    0x8(%eax),%edx
  800728:	89 55 14             	mov    %edx,0x14(%ebp)
  80072b:	8b 18                	mov    (%eax),%ebx
  80072d:	8b 70 04             	mov    0x4(%eax),%esi
  800730:	eb 26                	jmp    800758 <vprintfmt+0x2ec>
	else if (lflag)
  800732:	85 f6                	test   %esi,%esi
  800734:	74 12                	je     800748 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 50 04             	lea    0x4(%eax),%edx
  80073c:	89 55 14             	mov    %edx,0x14(%ebp)
  80073f:	8b 18                	mov    (%eax),%ebx
  800741:	89 de                	mov    %ebx,%esi
  800743:	c1 fe 1f             	sar    $0x1f,%esi
  800746:	eb 10                	jmp    800758 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8d 50 04             	lea    0x4(%eax),%edx
  80074e:	89 55 14             	mov    %edx,0x14(%ebp)
  800751:	8b 18                	mov    (%eax),%ebx
  800753:	89 de                	mov    %ebx,%esi
  800755:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800758:	83 f9 01             	cmp    $0x1,%ecx
  80075b:	75 1e                	jne    80077b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80075d:	85 f6                	test   %esi,%esi
  80075f:	78 1a                	js     80077b <vprintfmt+0x30f>
  800761:	85 f6                	test   %esi,%esi
  800763:	7f 05                	jg     80076a <vprintfmt+0x2fe>
  800765:	83 fb 00             	cmp    $0x0,%ebx
  800768:	76 11                	jbe    80077b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80076a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800771:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800778:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80077b:	85 f6                	test   %esi,%esi
  80077d:	78 13                	js     800792 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80077f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800782:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800788:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078d:	e9 da 00 00 00       	jmp    80086c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800792:	8b 45 0c             	mov    0xc(%ebp),%eax
  800795:	89 44 24 04          	mov    %eax,0x4(%esp)
  800799:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a3:	89 da                	mov    %ebx,%edx
  8007a5:	89 f1                	mov    %esi,%ecx
  8007a7:	f7 da                	neg    %edx
  8007a9:	83 d1 00             	adc    $0x0,%ecx
  8007ac:	f7 d9                	neg    %ecx
  8007ae:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007b1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007bc:	e9 ab 00 00 00       	jmp    80086c <vprintfmt+0x400>
  8007c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c4:	89 f2                	mov    %esi,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 47 fc ff ff       	call   800415 <getuint>
  8007ce:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007d1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8007dc:	e9 8b 00 00 00       	jmp    80086c <vprintfmt+0x400>
  8007e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007eb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007f2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8007f5:	89 f2                	mov    %esi,%edx
  8007f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fa:	e8 16 fc ff ff       	call   800415 <getuint>
  8007ff:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800802:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800805:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800808:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80080d:	eb 5d                	jmp    80086c <vprintfmt+0x400>
  80080f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800815:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800819:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800820:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800823:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800827:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80082e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8d 50 04             	lea    0x4(%eax),%edx
  800837:	89 55 14             	mov    %edx,0x14(%ebp)
  80083a:	8b 10                	mov    (%eax),%edx
  80083c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800841:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800844:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80084a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80084f:	eb 1b                	jmp    80086c <vprintfmt+0x400>
  800851:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800854:	89 f2                	mov    %esi,%edx
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
  800859:	e8 b7 fb ff ff       	call   800415 <getuint>
  80085e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800861:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800864:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800867:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80086c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800870:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800873:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800876:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80087a:	77 09                	ja     800885 <vprintfmt+0x419>
  80087c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80087f:	0f 82 ac 00 00 00    	jb     800931 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800885:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800888:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80088c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80088f:	83 ea 01             	sub    $0x1,%edx
  800892:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800896:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80089e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8008a2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8008a5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8008a8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008b6:	00 
  8008b7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008ba:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008bd:	89 0c 24             	mov    %ecx,(%esp)
  8008c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c4:	e8 c7 20 00 00       	call   802990 <__udivdi3>
  8008c9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8008cc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8008cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008d7:	89 04 24             	mov    %eax,(%esp)
  8008da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	e8 37 fa ff ff       	call   800320 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008f4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800902:	00 
  800903:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800906:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800909:	89 14 24             	mov    %edx,(%esp)
  80090c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800910:	e8 ab 21 00 00       	call   802ac0 <__umoddi3>
  800915:	89 74 24 04          	mov    %esi,0x4(%esp)
  800919:	0f be 80 16 2d 80 00 	movsbl 0x802d16(%eax),%eax
  800920:	89 04 24             	mov    %eax,(%esp)
  800923:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800926:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80092a:	74 54                	je     800980 <vprintfmt+0x514>
  80092c:	e9 67 fb ff ff       	jmp    800498 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800931:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800935:	8d 76 00             	lea    0x0(%esi),%esi
  800938:	0f 84 2a 01 00 00    	je     800a68 <vprintfmt+0x5fc>
		while (--width > 0)
  80093e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800941:	83 ef 01             	sub    $0x1,%edi
  800944:	85 ff                	test   %edi,%edi
  800946:	0f 8e 5e 01 00 00    	jle    800aaa <vprintfmt+0x63e>
  80094c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80094f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800952:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800955:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800958:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80095b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80095e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800962:	89 1c 24             	mov    %ebx,(%esp)
  800965:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800968:	83 ef 01             	sub    $0x1,%edi
  80096b:	85 ff                	test   %edi,%edi
  80096d:	7f ef                	jg     80095e <vprintfmt+0x4f2>
  80096f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800972:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800975:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800978:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80097b:	e9 2a 01 00 00       	jmp    800aaa <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800980:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800983:	83 eb 01             	sub    $0x1,%ebx
  800986:	85 db                	test   %ebx,%ebx
  800988:	0f 8e 0a fb ff ff    	jle    800498 <vprintfmt+0x2c>
  80098e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800991:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800994:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800997:	89 74 24 04          	mov    %esi,0x4(%esp)
  80099b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8009a4:	83 eb 01             	sub    $0x1,%ebx
  8009a7:	85 db                	test   %ebx,%ebx
  8009a9:	7f ec                	jg     800997 <vprintfmt+0x52b>
  8009ab:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8009ae:	e9 e8 fa ff ff       	jmp    80049b <vprintfmt+0x2f>
  8009b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8009b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b9:	8d 50 04             	lea    0x4(%eax),%edx
  8009bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bf:	8b 00                	mov    (%eax),%eax
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	75 2a                	jne    8009ef <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8009c5:	c7 44 24 0c 4c 2e 80 	movl   $0x802e4c,0xc(%esp)
  8009cc:	00 
  8009cd:	c7 44 24 08 7e 31 80 	movl   $0x80317e,0x8(%esp)
  8009d4:	00 
  8009d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009df:	89 0c 24             	mov    %ecx,(%esp)
  8009e2:	e8 90 01 00 00       	call   800b77 <printfmt>
  8009e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ea:	e9 ac fa ff ff       	jmp    80049b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8009ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f2:	8b 13                	mov    (%ebx),%edx
  8009f4:	83 fa 7f             	cmp    $0x7f,%edx
  8009f7:	7e 29                	jle    800a22 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8009f9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8009fb:	c7 44 24 0c 84 2e 80 	movl   $0x802e84,0xc(%esp)
  800a02:	00 
  800a03:	c7 44 24 08 7e 31 80 	movl   $0x80317e,0x8(%esp)
  800a0a:	00 
  800a0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 5d 01 00 00       	call   800b77 <printfmt>
  800a1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a1d:	e9 79 fa ff ff       	jmp    80049b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800a22:	88 10                	mov    %dl,(%eax)
  800a24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a27:	e9 6f fa ff ff       	jmp    80049b <vprintfmt+0x2f>
  800a2c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a35:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a39:	89 14 24             	mov    %edx,(%esp)
  800a3c:	ff 55 08             	call   *0x8(%ebp)
  800a3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800a42:	e9 54 fa ff ff       	jmp    80049b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a4e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a55:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a58:	8d 47 ff             	lea    -0x1(%edi),%eax
  800a5b:	80 38 25             	cmpb   $0x25,(%eax)
  800a5e:	0f 84 37 fa ff ff    	je     80049b <vprintfmt+0x2f>
  800a64:	89 c7                	mov    %eax,%edi
  800a66:	eb f0                	jmp    800a58 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a73:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a76:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a7a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a81:	00 
  800a82:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a85:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a88:	89 04 24             	mov    %eax,(%esp)
  800a8b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8f:	e8 2c 20 00 00       	call   802ac0 <__umoddi3>
  800a94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a98:	0f be 80 16 2d 80 00 	movsbl 0x802d16(%eax),%eax
  800a9f:	89 04 24             	mov    %eax,(%esp)
  800aa2:	ff 55 08             	call   *0x8(%ebp)
  800aa5:	e9 d6 fe ff ff       	jmp    800980 <vprintfmt+0x514>
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aad:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ab5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ab8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800abc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ac3:	00 
  800ac4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800ac7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800aca:	89 04 24             	mov    %eax,(%esp)
  800acd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad1:	e8 ea 1f 00 00       	call   802ac0 <__umoddi3>
  800ad6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ada:	0f be 80 16 2d 80 00 	movsbl 0x802d16(%eax),%eax
  800ae1:	89 04 24             	mov    %eax,(%esp)
  800ae4:	ff 55 08             	call   *0x8(%ebp)
  800ae7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aea:	e9 ac f9 ff ff       	jmp    80049b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800aef:	83 c4 6c             	add    $0x6c,%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	83 ec 28             	sub    $0x28,%esp
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	74 04                	je     800b0b <vsnprintf+0x14>
  800b07:	85 d2                	test   %edx,%edx
  800b09:	7f 07                	jg     800b12 <vsnprintf+0x1b>
  800b0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b10:	eb 3b                	jmp    800b4d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b15:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800b19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b23:	8b 45 14             	mov    0x14(%ebp),%eax
  800b26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b31:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b38:	c7 04 24 4f 04 80 00 	movl   $0x80044f,(%esp)
  800b3f:	e8 28 f9 ff ff       	call   80046c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b47:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b55:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6d:	89 04 24             	mov    %eax,(%esp)
  800b70:	e8 82 ff ff ff       	call   800af7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b7d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b84:	8b 45 10             	mov    0x10(%ebp),%eax
  800b87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	89 04 24             	mov    %eax,(%esp)
  800b98:	e8 cf f8 ff ff       	call   80046c <vprintfmt>
	va_end(ap);
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    
	...

00800ba0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	80 3a 00             	cmpb   $0x0,(%edx)
  800bae:	74 09                	je     800bb9 <strlen+0x19>
		n++;
  800bb0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bb7:	75 f7                	jne    800bb0 <strlen+0x10>
		n++;
	return n;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bc5:	85 c9                	test   %ecx,%ecx
  800bc7:	74 19                	je     800be2 <strnlen+0x27>
  800bc9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bcc:	74 14                	je     800be2 <strnlen+0x27>
  800bce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bd3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd6:	39 c8                	cmp    %ecx,%eax
  800bd8:	74 0d                	je     800be7 <strnlen+0x2c>
  800bda:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bde:	75 f3                	jne    800bd3 <strnlen+0x18>
  800be0:	eb 05                	jmp    800be7 <strnlen+0x2c>
  800be2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800be7:	5b                   	pop    %ebx
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	53                   	push   %ebx
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bf9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bfd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c00:	83 c2 01             	add    $0x1,%edx
  800c03:	84 c9                	test   %cl,%cl
  800c05:	75 f2                	jne    800bf9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 08             	sub    $0x8,%esp
  800c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c14:	89 1c 24             	mov    %ebx,(%esp)
  800c17:	e8 84 ff ff ff       	call   800ba0 <strlen>
	strcpy(dst + len, src);
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c23:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c26:	89 04 24             	mov    %eax,(%esp)
  800c29:	e8 bc ff ff ff       	call   800bea <strcpy>
	return dst;
}
  800c2e:	89 d8                	mov    %ebx,%eax
  800c30:	83 c4 08             	add    $0x8,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c44:	85 f6                	test   %esi,%esi
  800c46:	74 18                	je     800c60 <strncpy+0x2a>
  800c48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c4d:	0f b6 1a             	movzbl (%edx),%ebx
  800c50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c53:	80 3a 01             	cmpb   $0x1,(%edx)
  800c56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	39 ce                	cmp    %ecx,%esi
  800c5e:	77 ed                	ja     800c4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	8b 75 08             	mov    0x8(%ebp),%esi
  800c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c72:	89 f0                	mov    %esi,%eax
  800c74:	85 c9                	test   %ecx,%ecx
  800c76:	74 27                	je     800c9f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c78:	83 e9 01             	sub    $0x1,%ecx
  800c7b:	74 1d                	je     800c9a <strlcpy+0x36>
  800c7d:	0f b6 1a             	movzbl (%edx),%ebx
  800c80:	84 db                	test   %bl,%bl
  800c82:	74 16                	je     800c9a <strlcpy+0x36>
			*dst++ = *src++;
  800c84:	88 18                	mov    %bl,(%eax)
  800c86:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c89:	83 e9 01             	sub    $0x1,%ecx
  800c8c:	74 0e                	je     800c9c <strlcpy+0x38>
			*dst++ = *src++;
  800c8e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c91:	0f b6 1a             	movzbl (%edx),%ebx
  800c94:	84 db                	test   %bl,%bl
  800c96:	75 ec                	jne    800c84 <strlcpy+0x20>
  800c98:	eb 02                	jmp    800c9c <strlcpy+0x38>
  800c9a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c9c:	c6 00 00             	movb   $0x0,(%eax)
  800c9f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cae:	0f b6 01             	movzbl (%ecx),%eax
  800cb1:	84 c0                	test   %al,%al
  800cb3:	74 15                	je     800cca <strcmp+0x25>
  800cb5:	3a 02                	cmp    (%edx),%al
  800cb7:	75 11                	jne    800cca <strcmp+0x25>
		p++, q++;
  800cb9:	83 c1 01             	add    $0x1,%ecx
  800cbc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cbf:	0f b6 01             	movzbl (%ecx),%eax
  800cc2:	84 c0                	test   %al,%al
  800cc4:	74 04                	je     800cca <strcmp+0x25>
  800cc6:	3a 02                	cmp    (%edx),%al
  800cc8:	74 ef                	je     800cb9 <strcmp+0x14>
  800cca:	0f b6 c0             	movzbl %al,%eax
  800ccd:	0f b6 12             	movzbl (%edx),%edx
  800cd0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	53                   	push   %ebx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	74 23                	je     800d08 <strncmp+0x34>
  800ce5:	0f b6 1a             	movzbl (%edx),%ebx
  800ce8:	84 db                	test   %bl,%bl
  800cea:	74 25                	je     800d11 <strncmp+0x3d>
  800cec:	3a 19                	cmp    (%ecx),%bl
  800cee:	75 21                	jne    800d11 <strncmp+0x3d>
  800cf0:	83 e8 01             	sub    $0x1,%eax
  800cf3:	74 13                	je     800d08 <strncmp+0x34>
		n--, p++, q++;
  800cf5:	83 c2 01             	add    $0x1,%edx
  800cf8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cfb:	0f b6 1a             	movzbl (%edx),%ebx
  800cfe:	84 db                	test   %bl,%bl
  800d00:	74 0f                	je     800d11 <strncmp+0x3d>
  800d02:	3a 19                	cmp    (%ecx),%bl
  800d04:	74 ea                	je     800cf0 <strncmp+0x1c>
  800d06:	eb 09                	jmp    800d11 <strncmp+0x3d>
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5d                   	pop    %ebp
  800d0f:	90                   	nop
  800d10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d11:	0f b6 02             	movzbl (%edx),%eax
  800d14:	0f b6 11             	movzbl (%ecx),%edx
  800d17:	29 d0                	sub    %edx,%eax
  800d19:	eb f2                	jmp    800d0d <strncmp+0x39>

00800d1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d25:	0f b6 10             	movzbl (%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	74 18                	je     800d44 <strchr+0x29>
		if (*s == c)
  800d2c:	38 ca                	cmp    %cl,%dl
  800d2e:	75 0a                	jne    800d3a <strchr+0x1f>
  800d30:	eb 17                	jmp    800d49 <strchr+0x2e>
  800d32:	38 ca                	cmp    %cl,%dl
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	74 0f                	je     800d49 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d3a:	83 c0 01             	add    $0x1,%eax
  800d3d:	0f b6 10             	movzbl (%eax),%edx
  800d40:	84 d2                	test   %dl,%dl
  800d42:	75 ee                	jne    800d32 <strchr+0x17>
  800d44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d55:	0f b6 10             	movzbl (%eax),%edx
  800d58:	84 d2                	test   %dl,%dl
  800d5a:	74 18                	je     800d74 <strfind+0x29>
		if (*s == c)
  800d5c:	38 ca                	cmp    %cl,%dl
  800d5e:	75 0a                	jne    800d6a <strfind+0x1f>
  800d60:	eb 12                	jmp    800d74 <strfind+0x29>
  800d62:	38 ca                	cmp    %cl,%dl
  800d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d68:	74 0a                	je     800d74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d6a:	83 c0 01             	add    $0x1,%eax
  800d6d:	0f b6 10             	movzbl (%eax),%edx
  800d70:	84 d2                	test   %dl,%dl
  800d72:	75 ee                	jne    800d62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	89 1c 24             	mov    %ebx,(%esp)
  800d7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d90:	85 c9                	test   %ecx,%ecx
  800d92:	74 30                	je     800dc4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d9a:	75 25                	jne    800dc1 <memset+0x4b>
  800d9c:	f6 c1 03             	test   $0x3,%cl
  800d9f:	75 20                	jne    800dc1 <memset+0x4b>
		c &= 0xFF;
  800da1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800da4:	89 d3                	mov    %edx,%ebx
  800da6:	c1 e3 08             	shl    $0x8,%ebx
  800da9:	89 d6                	mov    %edx,%esi
  800dab:	c1 e6 18             	shl    $0x18,%esi
  800dae:	89 d0                	mov    %edx,%eax
  800db0:	c1 e0 10             	shl    $0x10,%eax
  800db3:	09 f0                	or     %esi,%eax
  800db5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800db7:	09 d8                	or     %ebx,%eax
  800db9:	c1 e9 02             	shr    $0x2,%ecx
  800dbc:	fc                   	cld    
  800dbd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dbf:	eb 03                	jmp    800dc4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dc1:	fc                   	cld    
  800dc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dc4:	89 f8                	mov    %edi,%eax
  800dc6:	8b 1c 24             	mov    (%esp),%ebx
  800dc9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dcd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dd1:	89 ec                	mov    %ebp,%esp
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	89 34 24             	mov    %esi,(%esp)
  800dde:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800de8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800deb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ded:	39 c6                	cmp    %eax,%esi
  800def:	73 35                	jae    800e26 <memmove+0x51>
  800df1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df4:	39 d0                	cmp    %edx,%eax
  800df6:	73 2e                	jae    800e26 <memmove+0x51>
		s += n;
		d += n;
  800df8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfa:	f6 c2 03             	test   $0x3,%dl
  800dfd:	75 1b                	jne    800e1a <memmove+0x45>
  800dff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e05:	75 13                	jne    800e1a <memmove+0x45>
  800e07:	f6 c1 03             	test   $0x3,%cl
  800e0a:	75 0e                	jne    800e1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800e0c:	83 ef 04             	sub    $0x4,%edi
  800e0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e12:	c1 e9 02             	shr    $0x2,%ecx
  800e15:	fd                   	std    
  800e16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e18:	eb 09                	jmp    800e23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e1a:	83 ef 01             	sub    $0x1,%edi
  800e1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e20:	fd                   	std    
  800e21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e23:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e24:	eb 20                	jmp    800e46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e2c:	75 15                	jne    800e43 <memmove+0x6e>
  800e2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e34:	75 0d                	jne    800e43 <memmove+0x6e>
  800e36:	f6 c1 03             	test   $0x3,%cl
  800e39:	75 08                	jne    800e43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e3b:	c1 e9 02             	shr    $0x2,%ecx
  800e3e:	fc                   	cld    
  800e3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e41:	eb 03                	jmp    800e46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e43:	fc                   	cld    
  800e44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e46:	8b 34 24             	mov    (%esp),%esi
  800e49:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e4d:	89 ec                	mov    %ebp,%esp
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e57:	8b 45 10             	mov    0x10(%ebp),%eax
  800e5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
  800e68:	89 04 24             	mov    %eax,(%esp)
  800e6b:	e8 65 ff ff ff       	call   800dd5 <memmove>
}
  800e70:	c9                   	leave  
  800e71:	c3                   	ret    

00800e72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e81:	85 c9                	test   %ecx,%ecx
  800e83:	74 36                	je     800ebb <memcmp+0x49>
		if (*s1 != *s2)
  800e85:	0f b6 06             	movzbl (%esi),%eax
  800e88:	0f b6 1f             	movzbl (%edi),%ebx
  800e8b:	38 d8                	cmp    %bl,%al
  800e8d:	74 20                	je     800eaf <memcmp+0x3d>
  800e8f:	eb 14                	jmp    800ea5 <memcmp+0x33>
  800e91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e9b:	83 c2 01             	add    $0x1,%edx
  800e9e:	83 e9 01             	sub    $0x1,%ecx
  800ea1:	38 d8                	cmp    %bl,%al
  800ea3:	74 12                	je     800eb7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ea5:	0f b6 c0             	movzbl %al,%eax
  800ea8:	0f b6 db             	movzbl %bl,%ebx
  800eab:	29 d8                	sub    %ebx,%eax
  800ead:	eb 11                	jmp    800ec0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eaf:	83 e9 01             	sub    $0x1,%ecx
  800eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb7:	85 c9                	test   %ecx,%ecx
  800eb9:	75 d6                	jne    800e91 <memcmp+0x1f>
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ed0:	39 d0                	cmp    %edx,%eax
  800ed2:	73 15                	jae    800ee9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ed8:	38 08                	cmp    %cl,(%eax)
  800eda:	75 06                	jne    800ee2 <memfind+0x1d>
  800edc:	eb 0b                	jmp    800ee9 <memfind+0x24>
  800ede:	38 08                	cmp    %cl,(%eax)
  800ee0:	74 07                	je     800ee9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ee2:	83 c0 01             	add    $0x1,%eax
  800ee5:	39 c2                	cmp    %eax,%edx
  800ee7:	77 f5                	ja     800ede <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 04             	sub    $0x4,%esp
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800efa:	0f b6 02             	movzbl (%edx),%eax
  800efd:	3c 20                	cmp    $0x20,%al
  800eff:	74 04                	je     800f05 <strtol+0x1a>
  800f01:	3c 09                	cmp    $0x9,%al
  800f03:	75 0e                	jne    800f13 <strtol+0x28>
		s++;
  800f05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f08:	0f b6 02             	movzbl (%edx),%eax
  800f0b:	3c 20                	cmp    $0x20,%al
  800f0d:	74 f6                	je     800f05 <strtol+0x1a>
  800f0f:	3c 09                	cmp    $0x9,%al
  800f11:	74 f2                	je     800f05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f13:	3c 2b                	cmp    $0x2b,%al
  800f15:	75 0c                	jne    800f23 <strtol+0x38>
		s++;
  800f17:	83 c2 01             	add    $0x1,%edx
  800f1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f21:	eb 15                	jmp    800f38 <strtol+0x4d>
	else if (*s == '-')
  800f23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f2a:	3c 2d                	cmp    $0x2d,%al
  800f2c:	75 0a                	jne    800f38 <strtol+0x4d>
		s++, neg = 1;
  800f2e:	83 c2 01             	add    $0x1,%edx
  800f31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f38:	85 db                	test   %ebx,%ebx
  800f3a:	0f 94 c0             	sete   %al
  800f3d:	74 05                	je     800f44 <strtol+0x59>
  800f3f:	83 fb 10             	cmp    $0x10,%ebx
  800f42:	75 18                	jne    800f5c <strtol+0x71>
  800f44:	80 3a 30             	cmpb   $0x30,(%edx)
  800f47:	75 13                	jne    800f5c <strtol+0x71>
  800f49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
  800f50:	75 0a                	jne    800f5c <strtol+0x71>
		s += 2, base = 16;
  800f52:	83 c2 02             	add    $0x2,%edx
  800f55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f5a:	eb 15                	jmp    800f71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f5c:	84 c0                	test   %al,%al
  800f5e:	66 90                	xchg   %ax,%ax
  800f60:	74 0f                	je     800f71 <strtol+0x86>
  800f62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f67:	80 3a 30             	cmpb   $0x30,(%edx)
  800f6a:	75 05                	jne    800f71 <strtol+0x86>
		s++, base = 8;
  800f6c:	83 c2 01             	add    $0x1,%edx
  800f6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f78:	0f b6 0a             	movzbl (%edx),%ecx
  800f7b:	89 cf                	mov    %ecx,%edi
  800f7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f80:	80 fb 09             	cmp    $0x9,%bl
  800f83:	77 08                	ja     800f8d <strtol+0xa2>
			dig = *s - '0';
  800f85:	0f be c9             	movsbl %cl,%ecx
  800f88:	83 e9 30             	sub    $0x30,%ecx
  800f8b:	eb 1e                	jmp    800fab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f90:	80 fb 19             	cmp    $0x19,%bl
  800f93:	77 08                	ja     800f9d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f95:	0f be c9             	movsbl %cl,%ecx
  800f98:	83 e9 57             	sub    $0x57,%ecx
  800f9b:	eb 0e                	jmp    800fab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800fa0:	80 fb 19             	cmp    $0x19,%bl
  800fa3:	77 15                	ja     800fba <strtol+0xcf>
			dig = *s - 'A' + 10;
  800fa5:	0f be c9             	movsbl %cl,%ecx
  800fa8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fab:	39 f1                	cmp    %esi,%ecx
  800fad:	7d 0b                	jge    800fba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800faf:	83 c2 01             	add    $0x1,%edx
  800fb2:	0f af c6             	imul   %esi,%eax
  800fb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800fb8:	eb be                	jmp    800f78 <strtol+0x8d>
  800fba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800fbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fc0:	74 05                	je     800fc7 <strtol+0xdc>
		*endptr = (char *) s;
  800fc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fc5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800fcb:	74 04                	je     800fd1 <strtol+0xe6>
  800fcd:	89 c8                	mov    %ecx,%eax
  800fcf:	f7 d8                	neg    %eax
}
  800fd1:	83 c4 04             	add    $0x4,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    
  800fd9:	00 00                	add    %al,(%eax)
	...

00800fdc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	89 1c 24             	mov    %ebx,(%esp)
  800fe5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fee:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff3:	89 d1                	mov    %edx,%ecx
  800ff5:	89 d3                	mov    %edx,%ebx
  800ff7:	89 d7                	mov    %edx,%edi
  800ff9:	51                   	push   %ecx
  800ffa:	52                   	push   %edx
  800ffb:	53                   	push   %ebx
  800ffc:	54                   	push   %esp
  800ffd:	55                   	push   %ebp
  800ffe:	56                   	push   %esi
  800fff:	57                   	push   %edi
  801000:	54                   	push   %esp
  801001:	5d                   	pop    %ebp
  801002:	8d 35 0a 10 80 00    	lea    0x80100a,%esi
  801008:	0f 34                	sysenter 
  80100a:	5f                   	pop    %edi
  80100b:	5e                   	pop    %esi
  80100c:	5d                   	pop    %ebp
  80100d:	5c                   	pop    %esp
  80100e:	5b                   	pop    %ebx
  80100f:	5a                   	pop    %edx
  801010:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801011:	8b 1c 24             	mov    (%esp),%ebx
  801014:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801018:	89 ec                	mov    %ebp,%esp
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	89 1c 24             	mov    %ebx,(%esp)
  801025:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801029:	b8 00 00 00 00       	mov    $0x0,%eax
  80102e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801031:	8b 55 08             	mov    0x8(%ebp),%edx
  801034:	89 c3                	mov    %eax,%ebx
  801036:	89 c7                	mov    %eax,%edi
  801038:	51                   	push   %ecx
  801039:	52                   	push   %edx
  80103a:	53                   	push   %ebx
  80103b:	54                   	push   %esp
  80103c:	55                   	push   %ebp
  80103d:	56                   	push   %esi
  80103e:	57                   	push   %edi
  80103f:	54                   	push   %esp
  801040:	5d                   	pop    %ebp
  801041:	8d 35 49 10 80 00    	lea    0x801049,%esi
  801047:	0f 34                	sysenter 
  801049:	5f                   	pop    %edi
  80104a:	5e                   	pop    %esi
  80104b:	5d                   	pop    %ebp
  80104c:	5c                   	pop    %esp
  80104d:	5b                   	pop    %ebx
  80104e:	5a                   	pop    %edx
  80104f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801050:	8b 1c 24             	mov    (%esp),%ebx
  801053:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801057:	89 ec                	mov    %ebp,%esp
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	89 1c 24             	mov    %ebx,(%esp)
  801064:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801068:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106d:	b8 13 00 00 00       	mov    $0x13,%eax
  801072:	8b 55 08             	mov    0x8(%ebp),%edx
  801075:	89 cb                	mov    %ecx,%ebx
  801077:	89 cf                	mov    %ecx,%edi
  801079:	51                   	push   %ecx
  80107a:	52                   	push   %edx
  80107b:	53                   	push   %ebx
  80107c:	54                   	push   %esp
  80107d:	55                   	push   %ebp
  80107e:	56                   	push   %esi
  80107f:	57                   	push   %edi
  801080:	54                   	push   %esp
  801081:	5d                   	pop    %ebp
  801082:	8d 35 8a 10 80 00    	lea    0x80108a,%esi
  801088:	0f 34                	sysenter 
  80108a:	5f                   	pop    %edi
  80108b:	5e                   	pop    %esi
  80108c:	5d                   	pop    %ebp
  80108d:	5c                   	pop    %esp
  80108e:	5b                   	pop    %ebx
  80108f:	5a                   	pop    %edx
  801090:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801091:	8b 1c 24             	mov    (%esp),%ebx
  801094:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801098:	89 ec                	mov    %ebp,%esp
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	89 1c 24             	mov    %ebx,(%esp)
  8010a5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ae:	b8 12 00 00 00       	mov    $0x12,%eax
  8010b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b9:	89 df                	mov    %ebx,%edi
  8010bb:	51                   	push   %ecx
  8010bc:	52                   	push   %edx
  8010bd:	53                   	push   %ebx
  8010be:	54                   	push   %esp
  8010bf:	55                   	push   %ebp
  8010c0:	56                   	push   %esi
  8010c1:	57                   	push   %edi
  8010c2:	54                   	push   %esp
  8010c3:	5d                   	pop    %ebp
  8010c4:	8d 35 cc 10 80 00    	lea    0x8010cc,%esi
  8010ca:	0f 34                	sysenter 
  8010cc:	5f                   	pop    %edi
  8010cd:	5e                   	pop    %esi
  8010ce:	5d                   	pop    %ebp
  8010cf:	5c                   	pop    %esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5a                   	pop    %edx
  8010d2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8010d3:	8b 1c 24             	mov    (%esp),%ebx
  8010d6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010da:	89 ec                	mov    %ebp,%esp
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 08             	sub    $0x8,%esp
  8010e4:	89 1c 24             	mov    %ebx,(%esp)
  8010e7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f0:	b8 11 00 00 00       	mov    $0x11,%eax
  8010f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fb:	89 df                	mov    %ebx,%edi
  8010fd:	51                   	push   %ecx
  8010fe:	52                   	push   %edx
  8010ff:	53                   	push   %ebx
  801100:	54                   	push   %esp
  801101:	55                   	push   %ebp
  801102:	56                   	push   %esi
  801103:	57                   	push   %edi
  801104:	54                   	push   %esp
  801105:	5d                   	pop    %ebp
  801106:	8d 35 0e 11 80 00    	lea    0x80110e,%esi
  80110c:	0f 34                	sysenter 
  80110e:	5f                   	pop    %edi
  80110f:	5e                   	pop    %esi
  801110:	5d                   	pop    %ebp
  801111:	5c                   	pop    %esp
  801112:	5b                   	pop    %ebx
  801113:	5a                   	pop    %edx
  801114:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801115:	8b 1c 24             	mov    (%esp),%ebx
  801118:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80111c:	89 ec                	mov    %ebp,%esp
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	89 1c 24             	mov    %ebx,(%esp)
  801129:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80112d:	b8 10 00 00 00       	mov    $0x10,%eax
  801132:	8b 7d 14             	mov    0x14(%ebp),%edi
  801135:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801138:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113b:	8b 55 08             	mov    0x8(%ebp),%edx
  80113e:	51                   	push   %ecx
  80113f:	52                   	push   %edx
  801140:	53                   	push   %ebx
  801141:	54                   	push   %esp
  801142:	55                   	push   %ebp
  801143:	56                   	push   %esi
  801144:	57                   	push   %edi
  801145:	54                   	push   %esp
  801146:	5d                   	pop    %ebp
  801147:	8d 35 4f 11 80 00    	lea    0x80114f,%esi
  80114d:	0f 34                	sysenter 
  80114f:	5f                   	pop    %edi
  801150:	5e                   	pop    %esi
  801151:	5d                   	pop    %ebp
  801152:	5c                   	pop    %esp
  801153:	5b                   	pop    %ebx
  801154:	5a                   	pop    %edx
  801155:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801156:	8b 1c 24             	mov    (%esp),%ebx
  801159:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80115d:	89 ec                	mov    %ebp,%esp
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	83 ec 28             	sub    $0x28,%esp
  801167:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80116a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80116d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801172:	b8 0f 00 00 00       	mov    $0xf,%eax
  801177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117a:	8b 55 08             	mov    0x8(%ebp),%edx
  80117d:	89 df                	mov    %ebx,%edi
  80117f:	51                   	push   %ecx
  801180:	52                   	push   %edx
  801181:	53                   	push   %ebx
  801182:	54                   	push   %esp
  801183:	55                   	push   %ebp
  801184:	56                   	push   %esi
  801185:	57                   	push   %edi
  801186:	54                   	push   %esp
  801187:	5d                   	pop    %ebp
  801188:	8d 35 90 11 80 00    	lea    0x801190,%esi
  80118e:	0f 34                	sysenter 
  801190:	5f                   	pop    %edi
  801191:	5e                   	pop    %esi
  801192:	5d                   	pop    %ebp
  801193:	5c                   	pop    %esp
  801194:	5b                   	pop    %ebx
  801195:	5a                   	pop    %edx
  801196:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801197:	85 c0                	test   %eax,%eax
  801199:	7e 28                	jle    8011c3 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  8011ae:	00 
  8011af:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011b6:	00 
  8011b7:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  8011be:	e8 d1 12 00 00       	call   802494 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8011c3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011c6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011c9:	89 ec                	mov    %ebp,%esp
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	89 1c 24             	mov    %ebx,(%esp)
  8011d6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011da:	ba 00 00 00 00       	mov    $0x0,%edx
  8011df:	b8 15 00 00 00       	mov    $0x15,%eax
  8011e4:	89 d1                	mov    %edx,%ecx
  8011e6:	89 d3                	mov    %edx,%ebx
  8011e8:	89 d7                	mov    %edx,%edi
  8011ea:	51                   	push   %ecx
  8011eb:	52                   	push   %edx
  8011ec:	53                   	push   %ebx
  8011ed:	54                   	push   %esp
  8011ee:	55                   	push   %ebp
  8011ef:	56                   	push   %esi
  8011f0:	57                   	push   %edi
  8011f1:	54                   	push   %esp
  8011f2:	5d                   	pop    %ebp
  8011f3:	8d 35 fb 11 80 00    	lea    0x8011fb,%esi
  8011f9:	0f 34                	sysenter 
  8011fb:	5f                   	pop    %edi
  8011fc:	5e                   	pop    %esi
  8011fd:	5d                   	pop    %ebp
  8011fe:	5c                   	pop    %esp
  8011ff:	5b                   	pop    %ebx
  801200:	5a                   	pop    %edx
  801201:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801202:	8b 1c 24             	mov    (%esp),%ebx
  801205:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801209:	89 ec                	mov    %ebp,%esp
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	89 1c 24             	mov    %ebx,(%esp)
  801216:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80121a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121f:	b8 14 00 00 00       	mov    $0x14,%eax
  801224:	8b 55 08             	mov    0x8(%ebp),%edx
  801227:	89 cb                	mov    %ecx,%ebx
  801229:	89 cf                	mov    %ecx,%edi
  80122b:	51                   	push   %ecx
  80122c:	52                   	push   %edx
  80122d:	53                   	push   %ebx
  80122e:	54                   	push   %esp
  80122f:	55                   	push   %ebp
  801230:	56                   	push   %esi
  801231:	57                   	push   %edi
  801232:	54                   	push   %esp
  801233:	5d                   	pop    %ebp
  801234:	8d 35 3c 12 80 00    	lea    0x80123c,%esi
  80123a:	0f 34                	sysenter 
  80123c:	5f                   	pop    %edi
  80123d:	5e                   	pop    %esi
  80123e:	5d                   	pop    %ebp
  80123f:	5c                   	pop    %esp
  801240:	5b                   	pop    %ebx
  801241:	5a                   	pop    %edx
  801242:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801243:	8b 1c 24             	mov    (%esp),%ebx
  801246:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80124a:	89 ec                	mov    %ebp,%esp
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	83 ec 28             	sub    $0x28,%esp
  801254:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801257:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80125a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801264:	8b 55 08             	mov    0x8(%ebp),%edx
  801267:	89 cb                	mov    %ecx,%ebx
  801269:	89 cf                	mov    %ecx,%edi
  80126b:	51                   	push   %ecx
  80126c:	52                   	push   %edx
  80126d:	53                   	push   %ebx
  80126e:	54                   	push   %esp
  80126f:	55                   	push   %ebp
  801270:	56                   	push   %esi
  801271:	57                   	push   %edi
  801272:	54                   	push   %esp
  801273:	5d                   	pop    %ebp
  801274:	8d 35 7c 12 80 00    	lea    0x80127c,%esi
  80127a:	0f 34                	sysenter 
  80127c:	5f                   	pop    %edi
  80127d:	5e                   	pop    %esi
  80127e:	5d                   	pop    %ebp
  80127f:	5c                   	pop    %esp
  801280:	5b                   	pop    %ebx
  801281:	5a                   	pop    %edx
  801282:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801283:	85 c0                	test   %eax,%eax
  801285:	7e 28                	jle    8012af <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801287:	89 44 24 10          	mov    %eax,0x10(%esp)
  80128b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801292:	00 
  801293:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  80129a:	00 
  80129b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012a2:	00 
  8012a3:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  8012aa:	e8 e5 11 00 00       	call   802494 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012af:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012b2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012b5:	89 ec                	mov    %ebp,%esp
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	83 ec 08             	sub    $0x8,%esp
  8012bf:	89 1c 24             	mov    %ebx,(%esp)
  8012c2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012c6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d7:	51                   	push   %ecx
  8012d8:	52                   	push   %edx
  8012d9:	53                   	push   %ebx
  8012da:	54                   	push   %esp
  8012db:	55                   	push   %ebp
  8012dc:	56                   	push   %esi
  8012dd:	57                   	push   %edi
  8012de:	54                   	push   %esp
  8012df:	5d                   	pop    %ebp
  8012e0:	8d 35 e8 12 80 00    	lea    0x8012e8,%esi
  8012e6:	0f 34                	sysenter 
  8012e8:	5f                   	pop    %edi
  8012e9:	5e                   	pop    %esi
  8012ea:	5d                   	pop    %ebp
  8012eb:	5c                   	pop    %esp
  8012ec:	5b                   	pop    %ebx
  8012ed:	5a                   	pop    %edx
  8012ee:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012ef:	8b 1c 24             	mov    (%esp),%ebx
  8012f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012f6:	89 ec                	mov    %ebp,%esp
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	83 ec 28             	sub    $0x28,%esp
  801300:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801303:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801313:	8b 55 08             	mov    0x8(%ebp),%edx
  801316:	89 df                	mov    %ebx,%edi
  801318:	51                   	push   %ecx
  801319:	52                   	push   %edx
  80131a:	53                   	push   %ebx
  80131b:	54                   	push   %esp
  80131c:	55                   	push   %ebp
  80131d:	56                   	push   %esi
  80131e:	57                   	push   %edi
  80131f:	54                   	push   %esp
  801320:	5d                   	pop    %ebp
  801321:	8d 35 29 13 80 00    	lea    0x801329,%esi
  801327:	0f 34                	sysenter 
  801329:	5f                   	pop    %edi
  80132a:	5e                   	pop    %esi
  80132b:	5d                   	pop    %ebp
  80132c:	5c                   	pop    %esp
  80132d:	5b                   	pop    %ebx
  80132e:	5a                   	pop    %edx
  80132f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801330:	85 c0                	test   %eax,%eax
  801332:	7e 28                	jle    80135c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801334:	89 44 24 10          	mov    %eax,0x10(%esp)
  801338:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80133f:	00 
  801340:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  801347:	00 
  801348:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80134f:	00 
  801350:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  801357:	e8 38 11 00 00       	call   802494 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80135c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80135f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801362:	89 ec                	mov    %ebp,%esp
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	83 ec 28             	sub    $0x28,%esp
  80136c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80136f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801372:	bb 00 00 00 00       	mov    $0x0,%ebx
  801377:	b8 0a 00 00 00       	mov    $0xa,%eax
  80137c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137f:	8b 55 08             	mov    0x8(%ebp),%edx
  801382:	89 df                	mov    %ebx,%edi
  801384:	51                   	push   %ecx
  801385:	52                   	push   %edx
  801386:	53                   	push   %ebx
  801387:	54                   	push   %esp
  801388:	55                   	push   %ebp
  801389:	56                   	push   %esi
  80138a:	57                   	push   %edi
  80138b:	54                   	push   %esp
  80138c:	5d                   	pop    %ebp
  80138d:	8d 35 95 13 80 00    	lea    0x801395,%esi
  801393:	0f 34                	sysenter 
  801395:	5f                   	pop    %edi
  801396:	5e                   	pop    %esi
  801397:	5d                   	pop    %ebp
  801398:	5c                   	pop    %esp
  801399:	5b                   	pop    %ebx
  80139a:	5a                   	pop    %edx
  80139b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80139c:	85 c0                	test   %eax,%eax
  80139e:	7e 28                	jle    8013c8 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8013ab:	00 
  8013ac:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  8013b3:	00 
  8013b4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013bb:	00 
  8013bc:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  8013c3:	e8 cc 10 00 00       	call   802494 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8013c8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ce:	89 ec                	mov    %ebp,%esp
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 28             	sub    $0x28,%esp
  8013d8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013db:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e3:	b8 09 00 00 00       	mov    $0x9,%eax
  8013e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ee:	89 df                	mov    %ebx,%edi
  8013f0:	51                   	push   %ecx
  8013f1:	52                   	push   %edx
  8013f2:	53                   	push   %ebx
  8013f3:	54                   	push   %esp
  8013f4:	55                   	push   %ebp
  8013f5:	56                   	push   %esi
  8013f6:	57                   	push   %edi
  8013f7:	54                   	push   %esp
  8013f8:	5d                   	pop    %ebp
  8013f9:	8d 35 01 14 80 00    	lea    0x801401,%esi
  8013ff:	0f 34                	sysenter 
  801401:	5f                   	pop    %edi
  801402:	5e                   	pop    %esi
  801403:	5d                   	pop    %ebp
  801404:	5c                   	pop    %esp
  801405:	5b                   	pop    %ebx
  801406:	5a                   	pop    %edx
  801407:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801408:	85 c0                	test   %eax,%eax
  80140a:	7e 28                	jle    801434 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80140c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801410:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801417:	00 
  801418:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  80141f:	00 
  801420:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801427:	00 
  801428:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  80142f:	e8 60 10 00 00       	call   802494 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801434:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801437:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80143a:	89 ec                	mov    %ebp,%esp
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	83 ec 28             	sub    $0x28,%esp
  801444:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801447:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80144a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144f:	b8 07 00 00 00       	mov    $0x7,%eax
  801454:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801457:	8b 55 08             	mov    0x8(%ebp),%edx
  80145a:	89 df                	mov    %ebx,%edi
  80145c:	51                   	push   %ecx
  80145d:	52                   	push   %edx
  80145e:	53                   	push   %ebx
  80145f:	54                   	push   %esp
  801460:	55                   	push   %ebp
  801461:	56                   	push   %esi
  801462:	57                   	push   %edi
  801463:	54                   	push   %esp
  801464:	5d                   	pop    %ebp
  801465:	8d 35 6d 14 80 00    	lea    0x80146d,%esi
  80146b:	0f 34                	sysenter 
  80146d:	5f                   	pop    %edi
  80146e:	5e                   	pop    %esi
  80146f:	5d                   	pop    %ebp
  801470:	5c                   	pop    %esp
  801471:	5b                   	pop    %ebx
  801472:	5a                   	pop    %edx
  801473:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801474:	85 c0                	test   %eax,%eax
  801476:	7e 28                	jle    8014a0 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801478:	89 44 24 10          	mov    %eax,0x10(%esp)
  80147c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801483:	00 
  801484:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  80148b:	00 
  80148c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801493:	00 
  801494:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  80149b:	e8 f4 0f 00 00       	call   802494 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8014a0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014a3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014a6:	89 ec                	mov    %ebp,%esp
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 28             	sub    $0x28,%esp
  8014b0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014b3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b6:	8b 7d 18             	mov    0x18(%ebp),%edi
  8014b9:	0b 7d 14             	or     0x14(%ebp),%edi
  8014bc:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ca:	51                   	push   %ecx
  8014cb:	52                   	push   %edx
  8014cc:	53                   	push   %ebx
  8014cd:	54                   	push   %esp
  8014ce:	55                   	push   %ebp
  8014cf:	56                   	push   %esi
  8014d0:	57                   	push   %edi
  8014d1:	54                   	push   %esp
  8014d2:	5d                   	pop    %ebp
  8014d3:	8d 35 db 14 80 00    	lea    0x8014db,%esi
  8014d9:	0f 34                	sysenter 
  8014db:	5f                   	pop    %edi
  8014dc:	5e                   	pop    %esi
  8014dd:	5d                   	pop    %ebp
  8014de:	5c                   	pop    %esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5a                   	pop    %edx
  8014e1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	7e 28                	jle    80150e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ea:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8014f1:	00 
  8014f2:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801501:	00 
  801502:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  801509:	e8 86 0f 00 00       	call   802494 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80150e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801511:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801514:	89 ec                	mov    %ebp,%esp
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	83 ec 28             	sub    $0x28,%esp
  80151e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801521:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801524:	bf 00 00 00 00       	mov    $0x0,%edi
  801529:	b8 05 00 00 00       	mov    $0x5,%eax
  80152e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801531:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801534:	8b 55 08             	mov    0x8(%ebp),%edx
  801537:	51                   	push   %ecx
  801538:	52                   	push   %edx
  801539:	53                   	push   %ebx
  80153a:	54                   	push   %esp
  80153b:	55                   	push   %ebp
  80153c:	56                   	push   %esi
  80153d:	57                   	push   %edi
  80153e:	54                   	push   %esp
  80153f:	5d                   	pop    %ebp
  801540:	8d 35 48 15 80 00    	lea    0x801548,%esi
  801546:	0f 34                	sysenter 
  801548:	5f                   	pop    %edi
  801549:	5e                   	pop    %esi
  80154a:	5d                   	pop    %ebp
  80154b:	5c                   	pop    %esp
  80154c:	5b                   	pop    %ebx
  80154d:	5a                   	pop    %edx
  80154e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80154f:	85 c0                	test   %eax,%eax
  801551:	7e 28                	jle    80157b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801553:	89 44 24 10          	mov    %eax,0x10(%esp)
  801557:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80155e:	00 
  80155f:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  801566:	00 
  801567:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80156e:	00 
  80156f:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  801576:	e8 19 0f 00 00       	call   802494 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80157b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80157e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801581:	89 ec                	mov    %ebp,%esp
  801583:	5d                   	pop    %ebp
  801584:	c3                   	ret    

00801585 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	89 1c 24             	mov    %ebx,(%esp)
  80158e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801592:	ba 00 00 00 00       	mov    $0x0,%edx
  801597:	b8 0c 00 00 00       	mov    $0xc,%eax
  80159c:	89 d1                	mov    %edx,%ecx
  80159e:	89 d3                	mov    %edx,%ebx
  8015a0:	89 d7                	mov    %edx,%edi
  8015a2:	51                   	push   %ecx
  8015a3:	52                   	push   %edx
  8015a4:	53                   	push   %ebx
  8015a5:	54                   	push   %esp
  8015a6:	55                   	push   %ebp
  8015a7:	56                   	push   %esi
  8015a8:	57                   	push   %edi
  8015a9:	54                   	push   %esp
  8015aa:	5d                   	pop    %ebp
  8015ab:	8d 35 b3 15 80 00    	lea    0x8015b3,%esi
  8015b1:	0f 34                	sysenter 
  8015b3:	5f                   	pop    %edi
  8015b4:	5e                   	pop    %esi
  8015b5:	5d                   	pop    %ebp
  8015b6:	5c                   	pop    %esp
  8015b7:	5b                   	pop    %ebx
  8015b8:	5a                   	pop    %edx
  8015b9:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015ba:	8b 1c 24             	mov    (%esp),%ebx
  8015bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015c1:	89 ec                	mov    %ebp,%esp
  8015c3:	5d                   	pop    %ebp
  8015c4:	c3                   	ret    

008015c5 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	89 1c 24             	mov    %ebx,(%esp)
  8015ce:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8015dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015df:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e2:	89 df                	mov    %ebx,%edi
  8015e4:	51                   	push   %ecx
  8015e5:	52                   	push   %edx
  8015e6:	53                   	push   %ebx
  8015e7:	54                   	push   %esp
  8015e8:	55                   	push   %ebp
  8015e9:	56                   	push   %esi
  8015ea:	57                   	push   %edi
  8015eb:	54                   	push   %esp
  8015ec:	5d                   	pop    %ebp
  8015ed:	8d 35 f5 15 80 00    	lea    0x8015f5,%esi
  8015f3:	0f 34                	sysenter 
  8015f5:	5f                   	pop    %edi
  8015f6:	5e                   	pop    %esi
  8015f7:	5d                   	pop    %ebp
  8015f8:	5c                   	pop    %esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5a                   	pop    %edx
  8015fb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8015fc:	8b 1c 24             	mov    (%esp),%ebx
  8015ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801603:	89 ec                	mov    %ebp,%esp
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	89 1c 24             	mov    %ebx,(%esp)
  801610:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801614:	ba 00 00 00 00       	mov    $0x0,%edx
  801619:	b8 02 00 00 00       	mov    $0x2,%eax
  80161e:	89 d1                	mov    %edx,%ecx
  801620:	89 d3                	mov    %edx,%ebx
  801622:	89 d7                	mov    %edx,%edi
  801624:	51                   	push   %ecx
  801625:	52                   	push   %edx
  801626:	53                   	push   %ebx
  801627:	54                   	push   %esp
  801628:	55                   	push   %ebp
  801629:	56                   	push   %esi
  80162a:	57                   	push   %edi
  80162b:	54                   	push   %esp
  80162c:	5d                   	pop    %ebp
  80162d:	8d 35 35 16 80 00    	lea    0x801635,%esi
  801633:	0f 34                	sysenter 
  801635:	5f                   	pop    %edi
  801636:	5e                   	pop    %esi
  801637:	5d                   	pop    %ebp
  801638:	5c                   	pop    %esp
  801639:	5b                   	pop    %ebx
  80163a:	5a                   	pop    %edx
  80163b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80163c:	8b 1c 24             	mov    (%esp),%ebx
  80163f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801643:	89 ec                	mov    %ebp,%esp
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 28             	sub    $0x28,%esp
  80164d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801650:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801653:	b9 00 00 00 00       	mov    $0x0,%ecx
  801658:	b8 03 00 00 00       	mov    $0x3,%eax
  80165d:	8b 55 08             	mov    0x8(%ebp),%edx
  801660:	89 cb                	mov    %ecx,%ebx
  801662:	89 cf                	mov    %ecx,%edi
  801664:	51                   	push   %ecx
  801665:	52                   	push   %edx
  801666:	53                   	push   %ebx
  801667:	54                   	push   %esp
  801668:	55                   	push   %ebp
  801669:	56                   	push   %esi
  80166a:	57                   	push   %edi
  80166b:	54                   	push   %esp
  80166c:	5d                   	pop    %ebp
  80166d:	8d 35 75 16 80 00    	lea    0x801675,%esi
  801673:	0f 34                	sysenter 
  801675:	5f                   	pop    %edi
  801676:	5e                   	pop    %esi
  801677:	5d                   	pop    %ebp
  801678:	5c                   	pop    %esp
  801679:	5b                   	pop    %ebx
  80167a:	5a                   	pop    %edx
  80167b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80167c:	85 c0                	test   %eax,%eax
  80167e:	7e 28                	jle    8016a8 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801680:	89 44 24 10          	mov    %eax,0x10(%esp)
  801684:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80168b:	00 
  80168c:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  801693:	00 
  801694:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80169b:	00 
  80169c:	c7 04 24 bd 30 80 00 	movl   $0x8030bd,(%esp)
  8016a3:	e8 ec 0d 00 00       	call   802494 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8016a8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016ab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016ae:	89 ec                	mov    %ebp,%esp
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    
	...

008016c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d9:	89 04 24             	mov    %eax,(%esp)
  8016dc:	e8 df ff ff ff       	call   8016c0 <fd2num>
  8016e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	57                   	push   %edi
  8016ef:	56                   	push   %esi
  8016f0:	53                   	push   %ebx
  8016f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8016f4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016f9:	a8 01                	test   $0x1,%al
  8016fb:	74 36                	je     801733 <fd_alloc+0x48>
  8016fd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801702:	a8 01                	test   $0x1,%al
  801704:	74 2d                	je     801733 <fd_alloc+0x48>
  801706:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80170b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801710:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801715:	89 c3                	mov    %eax,%ebx
  801717:	89 c2                	mov    %eax,%edx
  801719:	c1 ea 16             	shr    $0x16,%edx
  80171c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80171f:	f6 c2 01             	test   $0x1,%dl
  801722:	74 14                	je     801738 <fd_alloc+0x4d>
  801724:	89 c2                	mov    %eax,%edx
  801726:	c1 ea 0c             	shr    $0xc,%edx
  801729:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80172c:	f6 c2 01             	test   $0x1,%dl
  80172f:	75 10                	jne    801741 <fd_alloc+0x56>
  801731:	eb 05                	jmp    801738 <fd_alloc+0x4d>
  801733:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801738:	89 1f                	mov    %ebx,(%edi)
  80173a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80173f:	eb 17                	jmp    801758 <fd_alloc+0x6d>
  801741:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801746:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80174b:	75 c8                	jne    801715 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80174d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801753:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801758:	5b                   	pop    %ebx
  801759:	5e                   	pop    %esi
  80175a:	5f                   	pop    %edi
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	83 f8 1f             	cmp    $0x1f,%eax
  801766:	77 36                	ja     80179e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801768:	05 00 00 0d 00       	add    $0xd0000,%eax
  80176d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801770:	89 c2                	mov    %eax,%edx
  801772:	c1 ea 16             	shr    $0x16,%edx
  801775:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80177c:	f6 c2 01             	test   $0x1,%dl
  80177f:	74 1d                	je     80179e <fd_lookup+0x41>
  801781:	89 c2                	mov    %eax,%edx
  801783:	c1 ea 0c             	shr    $0xc,%edx
  801786:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80178d:	f6 c2 01             	test   $0x1,%dl
  801790:	74 0c                	je     80179e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801792:	8b 55 0c             	mov    0xc(%ebp),%edx
  801795:	89 02                	mov    %eax,(%edx)
  801797:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80179c:	eb 05                	jmp    8017a3 <fd_lookup+0x46>
  80179e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	89 04 24             	mov    %eax,(%esp)
  8017b8:	e8 a0 ff ff ff       	call   80175d <fd_lookup>
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	78 0e                	js     8017cf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c7:	89 50 04             	mov    %edx,0x4(%eax)
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	56                   	push   %esi
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 10             	sub    $0x10,%esp
  8017d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8017df:	b8 08 40 80 00       	mov    $0x804008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8017e4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017e9:	be 48 31 80 00       	mov    $0x803148,%esi
		if (devtab[i]->dev_id == dev_id) {
  8017ee:	39 08                	cmp    %ecx,(%eax)
  8017f0:	75 10                	jne    801802 <dev_lookup+0x31>
  8017f2:	eb 04                	jmp    8017f8 <dev_lookup+0x27>
  8017f4:	39 08                	cmp    %ecx,(%eax)
  8017f6:	75 0a                	jne    801802 <dev_lookup+0x31>
			*dev = devtab[i];
  8017f8:	89 03                	mov    %eax,(%ebx)
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017ff:	90                   	nop
  801800:	eb 31                	jmp    801833 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801802:	83 c2 01             	add    $0x1,%edx
  801805:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801808:	85 c0                	test   %eax,%eax
  80180a:	75 e8                	jne    8017f4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80180c:	a1 18 50 80 00       	mov    0x805018,%eax
  801811:	8b 40 48             	mov    0x48(%eax),%eax
  801814:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181c:	c7 04 24 cc 30 80 00 	movl   $0x8030cc,(%esp)
  801823:	e8 95 ea ff ff       	call   8002bd <cprintf>
	*dev = 0;
  801828:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80182e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	53                   	push   %ebx
  80183e:	83 ec 24             	sub    $0x24,%esp
  801841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	89 04 24             	mov    %eax,(%esp)
  801851:	e8 07 ff ff ff       	call   80175d <fd_lookup>
  801856:	85 c0                	test   %eax,%eax
  801858:	78 53                	js     8018ad <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80185a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801864:	8b 00                	mov    (%eax),%eax
  801866:	89 04 24             	mov    %eax,(%esp)
  801869:	e8 63 ff ff ff       	call   8017d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 3b                	js     8018ad <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801872:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801877:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80187e:	74 2d                	je     8018ad <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801880:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801883:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80188a:	00 00 00 
	stat->st_isdir = 0;
  80188d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801894:	00 00 00 
	stat->st_dev = dev;
  801897:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018a7:	89 14 24             	mov    %edx,(%esp)
  8018aa:	ff 50 14             	call   *0x14(%eax)
}
  8018ad:	83 c4 24             	add    $0x24,%esp
  8018b0:	5b                   	pop    %ebx
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 24             	sub    $0x24,%esp
  8018ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c4:	89 1c 24             	mov    %ebx,(%esp)
  8018c7:	e8 91 fe ff ff       	call   80175d <fd_lookup>
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 5f                	js     80192f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018da:	8b 00                	mov    (%eax),%eax
  8018dc:	89 04 24             	mov    %eax,(%esp)
  8018df:	e8 ed fe ff ff       	call   8017d1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 47                	js     80192f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018eb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018ef:	75 23                	jne    801914 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018f1:	a1 18 50 80 00       	mov    0x805018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018f6:	8b 40 48             	mov    0x48(%eax),%eax
  8018f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801901:	c7 04 24 ec 30 80 00 	movl   $0x8030ec,(%esp)
  801908:	e8 b0 e9 ff ff       	call   8002bd <cprintf>
  80190d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801912:	eb 1b                	jmp    80192f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801914:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801917:	8b 48 18             	mov    0x18(%eax),%ecx
  80191a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80191f:	85 c9                	test   %ecx,%ecx
  801921:	74 0c                	je     80192f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801923:	8b 45 0c             	mov    0xc(%ebp),%eax
  801926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192a:	89 14 24             	mov    %edx,(%esp)
  80192d:	ff d1                	call   *%ecx
}
  80192f:	83 c4 24             	add    $0x24,%esp
  801932:	5b                   	pop    %ebx
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	53                   	push   %ebx
  801939:	83 ec 24             	sub    $0x24,%esp
  80193c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801942:	89 44 24 04          	mov    %eax,0x4(%esp)
  801946:	89 1c 24             	mov    %ebx,(%esp)
  801949:	e8 0f fe ff ff       	call   80175d <fd_lookup>
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 66                	js     8019b8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801952:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801955:	89 44 24 04          	mov    %eax,0x4(%esp)
  801959:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195c:	8b 00                	mov    (%eax),%eax
  80195e:	89 04 24             	mov    %eax,(%esp)
  801961:	e8 6b fe ff ff       	call   8017d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801966:	85 c0                	test   %eax,%eax
  801968:	78 4e                	js     8019b8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80196a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80196d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801971:	75 23                	jne    801996 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801973:	a1 18 50 80 00       	mov    0x805018,%eax
  801978:	8b 40 48             	mov    0x48(%eax),%eax
  80197b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80197f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801983:	c7 04 24 0d 31 80 00 	movl   $0x80310d,(%esp)
  80198a:	e8 2e e9 ff ff       	call   8002bd <cprintf>
  80198f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801994:	eb 22                	jmp    8019b8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801996:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801999:	8b 48 0c             	mov    0xc(%eax),%ecx
  80199c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a1:	85 c9                	test   %ecx,%ecx
  8019a3:	74 13                	je     8019b8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b3:	89 14 24             	mov    %edx,(%esp)
  8019b6:	ff d1                	call   *%ecx
}
  8019b8:	83 c4 24             	add    $0x24,%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	53                   	push   %ebx
  8019c2:	83 ec 24             	sub    $0x24,%esp
  8019c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cf:	89 1c 24             	mov    %ebx,(%esp)
  8019d2:	e8 86 fd ff ff       	call   80175d <fd_lookup>
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 6b                	js     801a46 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e5:	8b 00                	mov    (%eax),%eax
  8019e7:	89 04 24             	mov    %eax,(%esp)
  8019ea:	e8 e2 fd ff ff       	call   8017d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	78 53                	js     801a46 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019f6:	8b 42 08             	mov    0x8(%edx),%eax
  8019f9:	83 e0 03             	and    $0x3,%eax
  8019fc:	83 f8 01             	cmp    $0x1,%eax
  8019ff:	75 23                	jne    801a24 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a01:	a1 18 50 80 00       	mov    0x805018,%eax
  801a06:	8b 40 48             	mov    0x48(%eax),%eax
  801a09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	c7 04 24 2a 31 80 00 	movl   $0x80312a,(%esp)
  801a18:	e8 a0 e8 ff ff       	call   8002bd <cprintf>
  801a1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a22:	eb 22                	jmp    801a46 <read+0x88>
	}
	if (!dev->dev_read)
  801a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a27:	8b 48 08             	mov    0x8(%eax),%ecx
  801a2a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a2f:	85 c9                	test   %ecx,%ecx
  801a31:	74 13                	je     801a46 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a33:	8b 45 10             	mov    0x10(%ebp),%eax
  801a36:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a41:	89 14 24             	mov    %edx,(%esp)
  801a44:	ff d1                	call   *%ecx
}
  801a46:	83 c4 24             	add    $0x24,%esp
  801a49:	5b                   	pop    %ebx
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	57                   	push   %edi
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	83 ec 1c             	sub    $0x1c,%esp
  801a55:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a58:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6a:	85 f6                	test   %esi,%esi
  801a6c:	74 29                	je     801a97 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a6e:	89 f0                	mov    %esi,%eax
  801a70:	29 d0                	sub    %edx,%eax
  801a72:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a76:	03 55 0c             	add    0xc(%ebp),%edx
  801a79:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a7d:	89 3c 24             	mov    %edi,(%esp)
  801a80:	e8 39 ff ff ff       	call   8019be <read>
		if (m < 0)
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 0e                	js     801a97 <readn+0x4b>
			return m;
		if (m == 0)
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	74 08                	je     801a95 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a8d:	01 c3                	add    %eax,%ebx
  801a8f:	89 da                	mov    %ebx,%edx
  801a91:	39 f3                	cmp    %esi,%ebx
  801a93:	72 d9                	jb     801a6e <readn+0x22>
  801a95:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a97:	83 c4 1c             	add    $0x1c,%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5e                   	pop    %esi
  801a9c:	5f                   	pop    %edi
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	83 ec 20             	sub    $0x20,%esp
  801aa7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801aaa:	89 34 24             	mov    %esi,(%esp)
  801aad:	e8 0e fc ff ff       	call   8016c0 <fd2num>
  801ab2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ab5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ab9:	89 04 24             	mov    %eax,(%esp)
  801abc:	e8 9c fc ff ff       	call   80175d <fd_lookup>
  801ac1:	89 c3                	mov    %eax,%ebx
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 05                	js     801acc <fd_close+0x2d>
  801ac7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801aca:	74 0c                	je     801ad8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801acc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801ad0:	19 c0                	sbb    %eax,%eax
  801ad2:	f7 d0                	not    %eax
  801ad4:	21 c3                	and    %eax,%ebx
  801ad6:	eb 3d                	jmp    801b15 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ad8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adf:	8b 06                	mov    (%esi),%eax
  801ae1:	89 04 24             	mov    %eax,(%esp)
  801ae4:	e8 e8 fc ff ff       	call   8017d1 <dev_lookup>
  801ae9:	89 c3                	mov    %eax,%ebx
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 16                	js     801b05 <fd_close+0x66>
		if (dev->dev_close)
  801aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af2:	8b 40 10             	mov    0x10(%eax),%eax
  801af5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801afa:	85 c0                	test   %eax,%eax
  801afc:	74 07                	je     801b05 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801afe:	89 34 24             	mov    %esi,(%esp)
  801b01:	ff d0                	call   *%eax
  801b03:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b05:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b10:	e8 29 f9 ff ff       	call   80143e <sys_page_unmap>
	return r;
}
  801b15:	89 d8                	mov    %ebx,%eax
  801b17:	83 c4 20             	add    $0x20,%esp
  801b1a:	5b                   	pop    %ebx
  801b1b:	5e                   	pop    %esi
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	89 04 24             	mov    %eax,(%esp)
  801b31:	e8 27 fc ff ff       	call   80175d <fd_lookup>
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 13                	js     801b4d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b3a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b41:	00 
  801b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	e8 52 ff ff ff       	call   801a9f <fd_close>
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    

00801b4f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	83 ec 18             	sub    $0x18,%esp
  801b55:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b58:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b62:	00 
  801b63:	8b 45 08             	mov    0x8(%ebp),%eax
  801b66:	89 04 24             	mov    %eax,(%esp)
  801b69:	e8 79 03 00 00       	call   801ee7 <open>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 1b                	js     801b8f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7b:	89 1c 24             	mov    %ebx,(%esp)
  801b7e:	e8 b7 fc ff ff       	call   80183a <fstat>
  801b83:	89 c6                	mov    %eax,%esi
	close(fd);
  801b85:	89 1c 24             	mov    %ebx,(%esp)
  801b88:	e8 91 ff ff ff       	call   801b1e <close>
  801b8d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b8f:	89 d8                	mov    %ebx,%eax
  801b91:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b94:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b97:	89 ec                	mov    %ebp,%esp
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	53                   	push   %ebx
  801b9f:	83 ec 14             	sub    $0x14,%esp
  801ba2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801ba7:	89 1c 24             	mov    %ebx,(%esp)
  801baa:	e8 6f ff ff ff       	call   801b1e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801baf:	83 c3 01             	add    $0x1,%ebx
  801bb2:	83 fb 20             	cmp    $0x20,%ebx
  801bb5:	75 f0                	jne    801ba7 <close_all+0xc>
		close(i);
}
  801bb7:	83 c4 14             	add    $0x14,%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 58             	sub    $0x58,%esp
  801bc3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801bc6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801bc9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801bcc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bcf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd9:	89 04 24             	mov    %eax,(%esp)
  801bdc:	e8 7c fb ff ff       	call   80175d <fd_lookup>
  801be1:	89 c3                	mov    %eax,%ebx
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 e0 00 00 00    	js     801ccb <dup+0x10e>
		return r;
	close(newfdnum);
  801beb:	89 3c 24             	mov    %edi,(%esp)
  801bee:	e8 2b ff ff ff       	call   801b1e <close>

	newfd = INDEX2FD(newfdnum);
  801bf3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801bf9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bff:	89 04 24             	mov    %eax,(%esp)
  801c02:	e8 c9 fa ff ff       	call   8016d0 <fd2data>
  801c07:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c09:	89 34 24             	mov    %esi,(%esp)
  801c0c:	e8 bf fa ff ff       	call   8016d0 <fd2data>
  801c11:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801c14:	89 da                	mov    %ebx,%edx
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	c1 e8 16             	shr    $0x16,%eax
  801c1b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c22:	a8 01                	test   $0x1,%al
  801c24:	74 43                	je     801c69 <dup+0xac>
  801c26:	c1 ea 0c             	shr    $0xc,%edx
  801c29:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c30:	a8 01                	test   $0x1,%al
  801c32:	74 35                	je     801c69 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c34:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c3b:	25 07 0e 00 00       	and    $0xe07,%eax
  801c40:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c44:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c52:	00 
  801c53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5e:	e8 47 f8 ff ff       	call   8014aa <sys_page_map>
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 3f                	js     801ca8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c6c:	89 c2                	mov    %eax,%edx
  801c6e:	c1 ea 0c             	shr    $0xc,%edx
  801c71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c78:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c7e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c82:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c8d:	00 
  801c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c99:	e8 0c f8 ff ff       	call   8014aa <sys_page_map>
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	78 04                	js     801ca8 <dup+0xeb>
  801ca4:	89 fb                	mov    %edi,%ebx
  801ca6:	eb 23                	jmp    801ccb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ca8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb3:	e8 86 f7 ff ff       	call   80143e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801cb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc6:	e8 73 f7 ff ff       	call   80143e <sys_page_unmap>
	return r;
}
  801ccb:	89 d8                	mov    %ebx,%eax
  801ccd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cd0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cd3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cd6:	89 ec                	mov    %ebp,%esp
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    
	...

00801cdc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	83 ec 18             	sub    $0x18,%esp
  801ce2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ce5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cec:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801cf3:	75 11                	jne    801d06 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cf5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801cfc:	e8 ef 07 00 00       	call   8024f0 <ipc_find_env>
  801d01:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d06:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d0d:	00 
  801d0e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d15:	00 
  801d16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d1a:	a1 00 50 80 00       	mov    0x805000,%eax
  801d1f:	89 04 24             	mov    %eax,(%esp)
  801d22:	e8 14 08 00 00       	call   80253b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d2e:	00 
  801d2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d3a:	e8 7a 08 00 00       	call   8025b9 <ipc_recv>
}
  801d3f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d42:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d45:	89 ec                	mov    %ebp,%esp
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	8b 40 0c             	mov    0xc(%eax),%eax
  801d55:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d62:	ba 00 00 00 00       	mov    $0x0,%edx
  801d67:	b8 02 00 00 00       	mov    $0x2,%eax
  801d6c:	e8 6b ff ff ff       	call   801cdc <fsipc>
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d7f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d84:	ba 00 00 00 00       	mov    $0x0,%edx
  801d89:	b8 06 00 00 00       	mov    $0x6,%eax
  801d8e:	e8 49 ff ff ff       	call   801cdc <fsipc>
}
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801da0:	b8 08 00 00 00       	mov    $0x8,%eax
  801da5:	e8 32 ff ff ff       	call   801cdc <fsipc>
}
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	53                   	push   %ebx
  801db0:	83 ec 14             	sub    $0x14,%esp
  801db3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	8b 40 0c             	mov    0xc(%eax),%eax
  801dbc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801dc1:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc6:	b8 05 00 00 00       	mov    $0x5,%eax
  801dcb:	e8 0c ff ff ff       	call   801cdc <fsipc>
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 2b                	js     801dff <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801dd4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ddb:	00 
  801ddc:	89 1c 24             	mov    %ebx,(%esp)
  801ddf:	e8 06 ee ff ff       	call   800bea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801de4:	a1 80 60 80 00       	mov    0x806080,%eax
  801de9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801def:	a1 84 60 80 00       	mov    0x806084,%eax
  801df4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801dfa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801dff:	83 c4 14             	add    $0x14,%esp
  801e02:	5b                   	pop    %ebx
  801e03:	5d                   	pop    %ebp
  801e04:	c3                   	ret    

00801e05 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 18             	sub    $0x18,%esp
  801e0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e13:	76 05                	jbe    801e1a <devfile_write+0x15>
  801e15:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e1d:	8b 52 0c             	mov    0xc(%edx),%edx
  801e20:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  801e26:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801e2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e36:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801e3d:	e8 93 ef ff ff       	call   800dd5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801e42:	ba 00 00 00 00       	mov    $0x0,%edx
  801e47:	b8 04 00 00 00       	mov    $0x4,%eax
  801e4c:	e8 8b fe ff ff       	call   801cdc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	53                   	push   %ebx
  801e57:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e60:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  801e65:	8b 45 10             	mov    0x10(%ebp),%eax
  801e68:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  801e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e72:	b8 03 00 00 00       	mov    $0x3,%eax
  801e77:	e8 60 fe ff ff       	call   801cdc <fsipc>
  801e7c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	78 17                	js     801e99 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801e82:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e86:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e8d:	00 
  801e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e91:	89 04 24             	mov    %eax,(%esp)
  801e94:	e8 3c ef ff ff       	call   800dd5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801e99:	89 d8                	mov    %ebx,%eax
  801e9b:	83 c4 14             	add    $0x14,%esp
  801e9e:	5b                   	pop    %ebx
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	53                   	push   %ebx
  801ea5:	83 ec 14             	sub    $0x14,%esp
  801ea8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801eab:	89 1c 24             	mov    %ebx,(%esp)
  801eae:	e8 ed ec ff ff       	call   800ba0 <strlen>
  801eb3:	89 c2                	mov    %eax,%edx
  801eb5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801eba:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ec0:	7f 1f                	jg     801ee1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801ec2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ec6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801ecd:	e8 18 ed ff ff       	call   800bea <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed7:	b8 07 00 00 00       	mov    $0x7,%eax
  801edc:	e8 fb fd ff ff       	call   801cdc <fsipc>
}
  801ee1:	83 c4 14             	add    $0x14,%esp
  801ee4:	5b                   	pop    %ebx
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	83 ec 28             	sub    $0x28,%esp
  801eed:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ef0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ef3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801ef6:	89 34 24             	mov    %esi,(%esp)
  801ef9:	e8 a2 ec ff ff       	call   800ba0 <strlen>
  801efe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801f03:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f08:	7f 6d                	jg     801f77 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0d:	89 04 24             	mov    %eax,(%esp)
  801f10:	e8 d6 f7 ff ff       	call   8016eb <fd_alloc>
  801f15:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 5c                	js     801f77 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801f23:	89 34 24             	mov    %esi,(%esp)
  801f26:	e8 75 ec ff ff       	call   800ba0 <strlen>
  801f2b:	83 c0 01             	add    $0x1,%eax
  801f2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f32:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f36:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f3d:	e8 93 ee ff ff       	call   800dd5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f45:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4a:	e8 8d fd ff ff       	call   801cdc <fsipc>
  801f4f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801f51:	85 c0                	test   %eax,%eax
  801f53:	79 15                	jns    801f6a <open+0x83>
             fd_close(fd,0);
  801f55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f5c:	00 
  801f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f60:	89 04 24             	mov    %eax,(%esp)
  801f63:	e8 37 fb ff ff       	call   801a9f <fd_close>
             return r;
  801f68:	eb 0d                	jmp    801f77 <open+0x90>
        }
        return fd2num(fd);
  801f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6d:	89 04 24             	mov    %eax,(%esp)
  801f70:	e8 4b f7 ff ff       	call   8016c0 <fd2num>
  801f75:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801f77:	89 d8                	mov    %ebx,%eax
  801f79:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f7c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f7f:	89 ec                	mov    %ebp,%esp
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    
	...

00801f90 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f96:	c7 44 24 04 54 31 80 	movl   $0x803154,0x4(%esp)
  801f9d:	00 
  801f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa1:	89 04 24             	mov    %eax,(%esp)
  801fa4:	e8 41 ec ff ff       	call   800bea <strcpy>
	return 0;
}
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 14             	sub    $0x14,%esp
  801fb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801fba:	89 1c 24             	mov    %ebx,(%esp)
  801fbd:	e8 6a 06 00 00       	call   80262c <pageref>
  801fc2:	89 c2                	mov    %eax,%edx
  801fc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc9:	83 fa 01             	cmp    $0x1,%edx
  801fcc:	75 0b                	jne    801fd9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801fce:	8b 43 0c             	mov    0xc(%ebx),%eax
  801fd1:	89 04 24             	mov    %eax,(%esp)
  801fd4:	e8 b9 02 00 00       	call   802292 <nsipc_close>
	else
		return 0;
}
  801fd9:	83 c4 14             	add    $0x14,%esp
  801fdc:	5b                   	pop    %ebx
  801fdd:	5d                   	pop    %ebp
  801fde:	c3                   	ret    

00801fdf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801fe5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801fec:	00 
  801fed:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffe:	8b 40 0c             	mov    0xc(%eax),%eax
  802001:	89 04 24             	mov    %eax,(%esp)
  802004:	e8 c5 02 00 00       	call   8022ce <nsipc_send>
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802011:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802018:	00 
  802019:	8b 45 10             	mov    0x10(%ebp),%eax
  80201c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802020:	8b 45 0c             	mov    0xc(%ebp),%eax
  802023:	89 44 24 04          	mov    %eax,0x4(%esp)
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	8b 40 0c             	mov    0xc(%eax),%eax
  80202d:	89 04 24             	mov    %eax,(%esp)
  802030:	e8 0c 03 00 00       	call   802341 <nsipc_recv>
}
  802035:	c9                   	leave  
  802036:	c3                   	ret    

00802037 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	56                   	push   %esi
  80203b:	53                   	push   %ebx
  80203c:	83 ec 20             	sub    $0x20,%esp
  80203f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802041:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802044:	89 04 24             	mov    %eax,(%esp)
  802047:	e8 9f f6 ff ff       	call   8016eb <fd_alloc>
  80204c:	89 c3                	mov    %eax,%ebx
  80204e:	85 c0                	test   %eax,%eax
  802050:	78 21                	js     802073 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802052:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802059:	00 
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802061:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802068:	e8 ab f4 ff ff       	call   801518 <sys_page_alloc>
  80206d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80206f:	85 c0                	test   %eax,%eax
  802071:	79 0a                	jns    80207d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802073:	89 34 24             	mov    %esi,(%esp)
  802076:	e8 17 02 00 00       	call   802292 <nsipc_close>
		return r;
  80207b:	eb 28                	jmp    8020a5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80207d:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802086:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802095:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209b:	89 04 24             	mov    %eax,(%esp)
  80209e:	e8 1d f6 ff ff       	call   8016c0 <fd2num>
  8020a3:	89 c3                	mov    %eax,%ebx
}
  8020a5:	89 d8                	mov    %ebx,%eax
  8020a7:	83 c4 20             	add    $0x20,%esp
  8020aa:	5b                   	pop    %ebx
  8020ab:	5e                   	pop    %esi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c5:	89 04 24             	mov    %eax,(%esp)
  8020c8:	e8 79 01 00 00       	call   802246 <nsipc_socket>
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 05                	js     8020d6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8020d1:	e8 61 ff ff ff       	call   802037 <alloc_sockfd>
}
  8020d6:	c9                   	leave  
  8020d7:	c3                   	ret    

008020d8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8020de:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8020e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 70 f6 ff ff       	call   80175d <fd_lookup>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 15                	js     802106 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8020f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f4:	8b 0a                	mov    (%edx),%ecx
  8020f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020fb:	3b 0d 24 40 80 00    	cmp    0x804024,%ecx
  802101:	75 03                	jne    802106 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802103:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
  802111:	e8 c2 ff ff ff       	call   8020d8 <fd2sockid>
  802116:	85 c0                	test   %eax,%eax
  802118:	78 0f                	js     802129 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80211a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80211d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802121:	89 04 24             	mov    %eax,(%esp)
  802124:	e8 47 01 00 00       	call   802270 <nsipc_listen>
}
  802129:	c9                   	leave  
  80212a:	c3                   	ret    

0080212b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80212b:	55                   	push   %ebp
  80212c:	89 e5                	mov    %esp,%ebp
  80212e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802131:	8b 45 08             	mov    0x8(%ebp),%eax
  802134:	e8 9f ff ff ff       	call   8020d8 <fd2sockid>
  802139:	85 c0                	test   %eax,%eax
  80213b:	78 16                	js     802153 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80213d:	8b 55 10             	mov    0x10(%ebp),%edx
  802140:	89 54 24 08          	mov    %edx,0x8(%esp)
  802144:	8b 55 0c             	mov    0xc(%ebp),%edx
  802147:	89 54 24 04          	mov    %edx,0x4(%esp)
  80214b:	89 04 24             	mov    %eax,(%esp)
  80214e:	e8 6e 02 00 00       	call   8023c1 <nsipc_connect>
}
  802153:	c9                   	leave  
  802154:	c3                   	ret    

00802155 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80215b:	8b 45 08             	mov    0x8(%ebp),%eax
  80215e:	e8 75 ff ff ff       	call   8020d8 <fd2sockid>
  802163:	85 c0                	test   %eax,%eax
  802165:	78 0f                	js     802176 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80216a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80216e:	89 04 24             	mov    %eax,(%esp)
  802171:	e8 36 01 00 00       	call   8022ac <nsipc_shutdown>
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80217e:	8b 45 08             	mov    0x8(%ebp),%eax
  802181:	e8 52 ff ff ff       	call   8020d8 <fd2sockid>
  802186:	85 c0                	test   %eax,%eax
  802188:	78 16                	js     8021a0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80218a:	8b 55 10             	mov    0x10(%ebp),%edx
  80218d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802191:	8b 55 0c             	mov    0xc(%ebp),%edx
  802194:	89 54 24 04          	mov    %edx,0x4(%esp)
  802198:	89 04 24             	mov    %eax,(%esp)
  80219b:	e8 60 02 00 00       	call   802400 <nsipc_bind>
}
  8021a0:	c9                   	leave  
  8021a1:	c3                   	ret    

008021a2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ab:	e8 28 ff ff ff       	call   8020d8 <fd2sockid>
  8021b0:	85 c0                	test   %eax,%eax
  8021b2:	78 1f                	js     8021d3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8021b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8021b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c2:	89 04 24             	mov    %eax,(%esp)
  8021c5:	e8 75 02 00 00       	call   80243f <nsipc_accept>
  8021ca:	85 c0                	test   %eax,%eax
  8021cc:	78 05                	js     8021d3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8021ce:	e8 64 fe ff ff       	call   802037 <alloc_sockfd>
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    
	...

008021e0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 14             	sub    $0x14,%esp
  8021e7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8021e9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8021f0:	75 11                	jne    802203 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021f2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8021f9:	e8 f2 02 00 00       	call   8024f0 <ipc_find_env>
  8021fe:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802203:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80220a:	00 
  80220b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802212:	00 
  802213:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802217:	a1 04 50 80 00       	mov    0x805004,%eax
  80221c:	89 04 24             	mov    %eax,(%esp)
  80221f:	e8 17 03 00 00       	call   80253b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802224:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80222b:	00 
  80222c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802233:	00 
  802234:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80223b:	e8 79 03 00 00       	call   8025b9 <ipc_recv>
}
  802240:	83 c4 14             	add    $0x14,%esp
  802243:	5b                   	pop    %ebx
  802244:	5d                   	pop    %ebp
  802245:	c3                   	ret    

00802246 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80224c:	8b 45 08             	mov    0x8(%ebp),%eax
  80224f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802254:	8b 45 0c             	mov    0xc(%ebp),%eax
  802257:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80225c:	8b 45 10             	mov    0x10(%ebp),%eax
  80225f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802264:	b8 09 00 00 00       	mov    $0x9,%eax
  802269:	e8 72 ff ff ff       	call   8021e0 <nsipc>
}
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802276:	8b 45 08             	mov    0x8(%ebp),%eax
  802279:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80227e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802281:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802286:	b8 06 00 00 00       	mov    $0x6,%eax
  80228b:	e8 50 ff ff ff       	call   8021e0 <nsipc>
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802298:	8b 45 08             	mov    0x8(%ebp),%eax
  80229b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8022a0:	b8 04 00 00 00       	mov    $0x4,%eax
  8022a5:	e8 36 ff ff ff       	call   8021e0 <nsipc>
}
  8022aa:	c9                   	leave  
  8022ab:	c3                   	ret    

008022ac <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8022ac:	55                   	push   %ebp
  8022ad:	89 e5                	mov    %esp,%ebp
  8022af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8022ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022bd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8022c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022c7:	e8 14 ff ff ff       	call   8021e0 <nsipc>
}
  8022cc:	c9                   	leave  
  8022cd:	c3                   	ret    

008022ce <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	53                   	push   %ebx
  8022d2:	83 ec 14             	sub    $0x14,%esp
  8022d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022db:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8022e0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022e6:	7e 24                	jle    80230c <nsipc_send+0x3e>
  8022e8:	c7 44 24 0c 60 31 80 	movl   $0x803160,0xc(%esp)
  8022ef:	00 
  8022f0:	c7 44 24 08 6c 31 80 	movl   $0x80316c,0x8(%esp)
  8022f7:	00 
  8022f8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8022ff:	00 
  802300:	c7 04 24 81 31 80 00 	movl   $0x803181,(%esp)
  802307:	e8 88 01 00 00       	call   802494 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80230c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802310:	8b 45 0c             	mov    0xc(%ebp),%eax
  802313:	89 44 24 04          	mov    %eax,0x4(%esp)
  802317:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80231e:	e8 b2 ea ff ff       	call   800dd5 <memmove>
	nsipcbuf.send.req_size = size;
  802323:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802329:	8b 45 14             	mov    0x14(%ebp),%eax
  80232c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802331:	b8 08 00 00 00       	mov    $0x8,%eax
  802336:	e8 a5 fe ff ff       	call   8021e0 <nsipc>
}
  80233b:	83 c4 14             	add    $0x14,%esp
  80233e:	5b                   	pop    %ebx
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	56                   	push   %esi
  802345:	53                   	push   %ebx
  802346:	83 ec 10             	sub    $0x10,%esp
  802349:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80234c:	8b 45 08             	mov    0x8(%ebp),%eax
  80234f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802354:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80235a:	8b 45 14             	mov    0x14(%ebp),%eax
  80235d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802362:	b8 07 00 00 00       	mov    $0x7,%eax
  802367:	e8 74 fe ff ff       	call   8021e0 <nsipc>
  80236c:	89 c3                	mov    %eax,%ebx
  80236e:	85 c0                	test   %eax,%eax
  802370:	78 46                	js     8023b8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802372:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802377:	7f 04                	jg     80237d <nsipc_recv+0x3c>
  802379:	39 c6                	cmp    %eax,%esi
  80237b:	7d 24                	jge    8023a1 <nsipc_recv+0x60>
  80237d:	c7 44 24 0c 8d 31 80 	movl   $0x80318d,0xc(%esp)
  802384:	00 
  802385:	c7 44 24 08 6c 31 80 	movl   $0x80316c,0x8(%esp)
  80238c:	00 
  80238d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802394:	00 
  802395:	c7 04 24 81 31 80 00 	movl   $0x803181,(%esp)
  80239c:	e8 f3 00 00 00       	call   802494 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023a5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8023ac:	00 
  8023ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b0:	89 04 24             	mov    %eax,(%esp)
  8023b3:	e8 1d ea ff ff       	call   800dd5 <memmove>
	}

	return r;
}
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	83 c4 10             	add    $0x10,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    

008023c1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	53                   	push   %ebx
  8023c5:	83 ec 14             	sub    $0x14,%esp
  8023c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8023cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ce:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8023d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023de:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8023e5:	e8 eb e9 ff ff       	call   800dd5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8023ea:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8023f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8023f5:	e8 e6 fd ff ff       	call   8021e0 <nsipc>
}
  8023fa:	83 c4 14             	add    $0x14,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    

00802400 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	53                   	push   %ebx
  802404:	83 ec 14             	sub    $0x14,%esp
  802407:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80240a:	8b 45 08             	mov    0x8(%ebp),%eax
  80240d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802412:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802416:	8b 45 0c             	mov    0xc(%ebp),%eax
  802419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802424:	e8 ac e9 ff ff       	call   800dd5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802429:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80242f:	b8 02 00 00 00       	mov    $0x2,%eax
  802434:	e8 a7 fd ff ff       	call   8021e0 <nsipc>
}
  802439:	83 c4 14             	add    $0x14,%esp
  80243c:	5b                   	pop    %ebx
  80243d:	5d                   	pop    %ebp
  80243e:	c3                   	ret    

0080243f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80243f:	55                   	push   %ebp
  802440:	89 e5                	mov    %esp,%ebp
  802442:	83 ec 18             	sub    $0x18,%esp
  802445:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802448:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80244b:	8b 45 08             	mov    0x8(%ebp),%eax
  80244e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802453:	b8 01 00 00 00       	mov    $0x1,%eax
  802458:	e8 83 fd ff ff       	call   8021e0 <nsipc>
  80245d:	89 c3                	mov    %eax,%ebx
  80245f:	85 c0                	test   %eax,%eax
  802461:	78 25                	js     802488 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802463:	be 10 70 80 00       	mov    $0x807010,%esi
  802468:	8b 06                	mov    (%esi),%eax
  80246a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80246e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802475:	00 
  802476:	8b 45 0c             	mov    0xc(%ebp),%eax
  802479:	89 04 24             	mov    %eax,(%esp)
  80247c:	e8 54 e9 ff ff       	call   800dd5 <memmove>
		*addrlen = ret->ret_addrlen;
  802481:	8b 16                	mov    (%esi),%edx
  802483:	8b 45 10             	mov    0x10(%ebp),%eax
  802486:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802488:	89 d8                	mov    %ebx,%eax
  80248a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80248d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802490:	89 ec                	mov    %ebp,%esp
  802492:	5d                   	pop    %ebp
  802493:	c3                   	ret    

00802494 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802494:	55                   	push   %ebp
  802495:	89 e5                	mov    %esp,%ebp
  802497:	56                   	push   %esi
  802498:	53                   	push   %ebx
  802499:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80249c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80249f:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8024a5:	e8 5d f1 ff ff       	call   801607 <sys_getenvid>
  8024aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8024b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c0:	c7 04 24 a4 31 80 00 	movl   $0x8031a4,(%esp)
  8024c7:	e8 f1 dd ff ff       	call   8002bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8024cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8024d3:	89 04 24             	mov    %eax,(%esp)
  8024d6:	e8 81 dd ff ff       	call   80025c <vcprintf>
	cprintf("\n");
  8024db:	c7 04 24 b4 2c 80 00 	movl   $0x802cb4,(%esp)
  8024e2:	e8 d6 dd ff ff       	call   8002bd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8024e7:	cc                   	int3   
  8024e8:	eb fd                	jmp    8024e7 <_panic+0x53>
  8024ea:	00 00                	add    %al,(%eax)
  8024ec:	00 00                	add    %al,(%eax)
	...

008024f0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8024f6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8024fc:	b8 01 00 00 00       	mov    $0x1,%eax
  802501:	39 ca                	cmp    %ecx,%edx
  802503:	75 04                	jne    802509 <ipc_find_env+0x19>
  802505:	b0 00                	mov    $0x0,%al
  802507:	eb 12                	jmp    80251b <ipc_find_env+0x2b>
  802509:	89 c2                	mov    %eax,%edx
  80250b:	c1 e2 07             	shl    $0x7,%edx
  80250e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802515:	8b 12                	mov    (%edx),%edx
  802517:	39 ca                	cmp    %ecx,%edx
  802519:	75 10                	jne    80252b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80251b:	89 c2                	mov    %eax,%edx
  80251d:	c1 e2 07             	shl    $0x7,%edx
  802520:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802527:	8b 00                	mov    (%eax),%eax
  802529:	eb 0e                	jmp    802539 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80252b:	83 c0 01             	add    $0x1,%eax
  80252e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802533:	75 d4                	jne    802509 <ipc_find_env+0x19>
  802535:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    

0080253b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80253b:	55                   	push   %ebp
  80253c:	89 e5                	mov    %esp,%ebp
  80253e:	57                   	push   %edi
  80253f:	56                   	push   %esi
  802540:	53                   	push   %ebx
  802541:	83 ec 1c             	sub    $0x1c,%esp
  802544:	8b 75 08             	mov    0x8(%ebp),%esi
  802547:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80254a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80254d:	85 db                	test   %ebx,%ebx
  80254f:	74 19                	je     80256a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802551:	8b 45 14             	mov    0x14(%ebp),%eax
  802554:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802558:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80255c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802560:	89 34 24             	mov    %esi,(%esp)
  802563:	e8 51 ed ff ff       	call   8012b9 <sys_ipc_try_send>
  802568:	eb 1b                	jmp    802585 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80256a:	8b 45 14             	mov    0x14(%ebp),%eax
  80256d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802571:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802578:	ee 
  802579:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80257d:	89 34 24             	mov    %esi,(%esp)
  802580:	e8 34 ed ff ff       	call   8012b9 <sys_ipc_try_send>
           if(ret == 0)
  802585:	85 c0                	test   %eax,%eax
  802587:	74 28                	je     8025b1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802589:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80258c:	74 1c                	je     8025aa <ipc_send+0x6f>
              panic("ipc send error");
  80258e:	c7 44 24 08 c8 31 80 	movl   $0x8031c8,0x8(%esp)
  802595:	00 
  802596:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80259d:	00 
  80259e:	c7 04 24 d7 31 80 00 	movl   $0x8031d7,(%esp)
  8025a5:	e8 ea fe ff ff       	call   802494 <_panic>
           sys_yield();
  8025aa:	e8 d6 ef ff ff       	call   801585 <sys_yield>
        }
  8025af:	eb 9c                	jmp    80254d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8025b1:	83 c4 1c             	add    $0x1c,%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    

008025b9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025b9:	55                   	push   %ebp
  8025ba:	89 e5                	mov    %esp,%ebp
  8025bc:	56                   	push   %esi
  8025bd:	53                   	push   %ebx
  8025be:	83 ec 10             	sub    $0x10,%esp
  8025c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8025c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8025ca:	85 c0                	test   %eax,%eax
  8025cc:	75 0e                	jne    8025dc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8025ce:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8025d5:	e8 74 ec ff ff       	call   80124e <sys_ipc_recv>
  8025da:	eb 08                	jmp    8025e4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8025dc:	89 04 24             	mov    %eax,(%esp)
  8025df:	e8 6a ec ff ff       	call   80124e <sys_ipc_recv>
        if(ret == 0){
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	75 26                	jne    80260e <ipc_recv+0x55>
           if(from_env_store)
  8025e8:	85 f6                	test   %esi,%esi
  8025ea:	74 0a                	je     8025f6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  8025ec:	a1 18 50 80 00       	mov    0x805018,%eax
  8025f1:	8b 40 78             	mov    0x78(%eax),%eax
  8025f4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  8025f6:	85 db                	test   %ebx,%ebx
  8025f8:	74 0a                	je     802604 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  8025fa:	a1 18 50 80 00       	mov    0x805018,%eax
  8025ff:	8b 40 7c             	mov    0x7c(%eax),%eax
  802602:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802604:	a1 18 50 80 00       	mov    0x805018,%eax
  802609:	8b 40 74             	mov    0x74(%eax),%eax
  80260c:	eb 14                	jmp    802622 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80260e:	85 f6                	test   %esi,%esi
  802610:	74 06                	je     802618 <ipc_recv+0x5f>
              *from_env_store = 0;
  802612:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802618:	85 db                	test   %ebx,%ebx
  80261a:	74 06                	je     802622 <ipc_recv+0x69>
              *perm_store = 0;
  80261c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802622:	83 c4 10             	add    $0x10,%esp
  802625:	5b                   	pop    %ebx
  802626:	5e                   	pop    %esi
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    
  802629:	00 00                	add    %al,(%eax)
	...

0080262c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80262c:	55                   	push   %ebp
  80262d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80262f:	8b 45 08             	mov    0x8(%ebp),%eax
  802632:	89 c2                	mov    %eax,%edx
  802634:	c1 ea 16             	shr    $0x16,%edx
  802637:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80263e:	f6 c2 01             	test   $0x1,%dl
  802641:	74 20                	je     802663 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802643:	c1 e8 0c             	shr    $0xc,%eax
  802646:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80264d:	a8 01                	test   $0x1,%al
  80264f:	74 12                	je     802663 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802651:	c1 e8 0c             	shr    $0xc,%eax
  802654:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802659:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80265e:	0f b7 c0             	movzwl %ax,%eax
  802661:	eb 05                	jmp    802668 <pageref+0x3c>
  802663:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    
  80266a:	00 00                	add    %al,(%eax)
  80266c:	00 00                	add    %al,(%eax)
	...

00802670 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
  802673:	57                   	push   %edi
  802674:	56                   	push   %esi
  802675:	53                   	push   %ebx
  802676:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802679:	8b 45 08             	mov    0x8(%ebp),%eax
  80267c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80267f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802682:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802685:	8d 45 f3             	lea    -0xd(%ebp),%eax
  802688:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80268b:	b9 08 50 80 00       	mov    $0x805008,%ecx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802690:	ba cd ff ff ff       	mov    $0xffffffcd,%edx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802695:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802698:	0f b6 18             	movzbl (%eax),%ebx
  80269b:	be 00 00 00 00       	mov    $0x0,%esi
  8026a0:	89 f0                	mov    %esi,%eax
  8026a2:	89 ce                	mov    %ecx,%esi
  8026a4:	89 c1                	mov    %eax,%ecx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8026a6:	89 d8                	mov    %ebx,%eax
  8026a8:	f6 e2                	mul    %dl
  8026aa:	66 c1 e8 08          	shr    $0x8,%ax
  8026ae:	c0 e8 03             	shr    $0x3,%al
  8026b1:	89 c7                	mov    %eax,%edi
  8026b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8026b6:	01 c0                	add    %eax,%eax
  8026b8:	28 c3                	sub    %al,%bl
  8026ba:	89 d8                	mov    %ebx,%eax
      *ap /= (u8_t)10;
  8026bc:	89 fb                	mov    %edi,%ebx
      inv[i++] = '0' + rem;
  8026be:	0f b6 f9             	movzbl %cl,%edi
  8026c1:	83 c0 30             	add    $0x30,%eax
  8026c4:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
  8026c8:	83 c1 01             	add    $0x1,%ecx
    } while(*ap);
  8026cb:	84 db                	test   %bl,%bl
  8026cd:	75 d7                	jne    8026a6 <inet_ntoa+0x36>
  8026cf:	89 c8                	mov    %ecx,%eax
  8026d1:	89 f1                	mov    %esi,%ecx
  8026d3:	89 c6                	mov    %eax,%esi
  8026d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026d8:	88 18                	mov    %bl,(%eax)
    while(i--)
  8026da:	89 f0                	mov    %esi,%eax
  8026dc:	84 c0                	test   %al,%al
  8026de:	74 2c                	je     80270c <inet_ntoa+0x9c>
  8026e0:	8d 5e ff             	lea    -0x1(%esi),%ebx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8026e3:	0f b6 c3             	movzbl %bl,%eax
  8026e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8026e9:	8d 7c 01 01          	lea    0x1(%ecx,%eax,1),%edi
  8026ed:	89 c8                	mov    %ecx,%eax
  8026ef:	89 ce                	mov    %ecx,%esi
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  8026f1:	0f b6 cb             	movzbl %bl,%ecx
  8026f4:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  8026f9:	88 08                	mov    %cl,(%eax)
  8026fb:	83 c0 01             	add    $0x1,%eax
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8026fe:	83 eb 01             	sub    $0x1,%ebx
  802701:	39 f8                	cmp    %edi,%eax
  802703:	75 ec                	jne    8026f1 <inet_ntoa+0x81>
  802705:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802708:	8d 4c 06 01          	lea    0x1(%esi,%eax,1),%ecx
      *rp++ = inv[i];
    *rp++ = '.';
  80270c:	c6 01 2e             	movb   $0x2e,(%ecx)
  80270f:	83 c1 01             	add    $0x1,%ecx
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802715:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802718:	74 09                	je     802723 <inet_ntoa+0xb3>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  80271a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80271e:	e9 72 ff ff ff       	jmp    802695 <inet_ntoa+0x25>
  }
  *--rp = 0;
  802723:	c6 41 ff 00          	movb   $0x0,-0x1(%ecx)
  return str;
}
  802727:	b8 08 50 80 00       	mov    $0x805008,%eax
  80272c:	83 c4 1c             	add    $0x1c,%esp
  80272f:	5b                   	pop    %ebx
  802730:	5e                   	pop    %esi
  802731:	5f                   	pop    %edi
  802732:	5d                   	pop    %ebp
  802733:	c3                   	ret    

00802734 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  802734:	55                   	push   %ebp
  802735:	89 e5                	mov    %esp,%ebp
  802737:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80273b:	66 c1 c0 08          	rol    $0x8,%ax
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}
  80273f:	5d                   	pop    %ebp
  802740:	c3                   	ret    

00802741 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802741:	55                   	push   %ebp
  802742:	89 e5                	mov    %esp,%ebp
  802744:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  802747:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80274b:	89 04 24             	mov    %eax,(%esp)
  80274e:	e8 e1 ff ff ff       	call   802734 <htons>
}
  802753:	c9                   	leave  
  802754:	c3                   	ret    

00802755 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  802755:	55                   	push   %ebp
  802756:	89 e5                	mov    %esp,%ebp
  802758:	8b 55 08             	mov    0x8(%ebp),%edx
  80275b:	89 d1                	mov    %edx,%ecx
  80275d:	c1 e9 18             	shr    $0x18,%ecx
  802760:	89 d0                	mov    %edx,%eax
  802762:	c1 e0 18             	shl    $0x18,%eax
  802765:	09 c8                	or     %ecx,%eax
  802767:	89 d1                	mov    %edx,%ecx
  802769:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  80276f:	c1 e1 08             	shl    $0x8,%ecx
  802772:	09 c8                	or     %ecx,%eax
  802774:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80277a:	c1 ea 08             	shr    $0x8,%edx
  80277d:	09 d0                	or     %edx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  80277f:	5d                   	pop    %ebp
  802780:	c3                   	ret    

00802781 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802781:	55                   	push   %ebp
  802782:	89 e5                	mov    %esp,%ebp
  802784:	57                   	push   %edi
  802785:	56                   	push   %esi
  802786:	53                   	push   %ebx
  802787:	83 ec 28             	sub    $0x28,%esp
  80278a:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  80278d:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802790:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802793:	80 f9 09             	cmp    $0x9,%cl
  802796:	0f 87 af 01 00 00    	ja     80294b <inet_aton+0x1ca>
  80279c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80279f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8027a2:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8027a5:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  8027a8:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8027af:	83 fa 30             	cmp    $0x30,%edx
  8027b2:	75 24                	jne    8027d8 <inet_aton+0x57>
      c = *++cp;
  8027b4:	83 c0 01             	add    $0x1,%eax
  8027b7:	0f be 10             	movsbl (%eax),%edx
      if (c == 'x' || c == 'X') {
  8027ba:	83 fa 78             	cmp    $0x78,%edx
  8027bd:	74 0c                	je     8027cb <inet_aton+0x4a>
  8027bf:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  8027c6:	83 fa 58             	cmp    $0x58,%edx
  8027c9:	75 0d                	jne    8027d8 <inet_aton+0x57>
        base = 16;
        c = *++cp;
  8027cb:	83 c0 01             	add    $0x1,%eax
  8027ce:	0f be 10             	movsbl (%eax),%edx
  8027d1:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  8027d8:	83 c0 01             	add    $0x1,%eax
  8027db:	be 00 00 00 00       	mov    $0x0,%esi
  8027e0:	eb 03                	jmp    8027e5 <inet_aton+0x64>
  8027e2:	83 c0 01             	add    $0x1,%eax
  8027e5:	8d 78 ff             	lea    -0x1(%eax),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8027e8:	89 d1                	mov    %edx,%ecx
  8027ea:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8027ed:	80 fb 09             	cmp    $0x9,%bl
  8027f0:	77 0d                	ja     8027ff <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  8027f2:	0f af 75 e0          	imul   -0x20(%ebp),%esi
  8027f6:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8027fa:	0f be 10             	movsbl (%eax),%edx
  8027fd:	eb e3                	jmp    8027e2 <inet_aton+0x61>
      } else if (base == 16 && isxdigit(c)) {
  8027ff:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  802803:	75 2b                	jne    802830 <inet_aton+0xaf>
  802805:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802808:	88 5d d3             	mov    %bl,-0x2d(%ebp)
  80280b:	80 fb 05             	cmp    $0x5,%bl
  80280e:	76 08                	jbe    802818 <inet_aton+0x97>
  802810:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802813:	80 fb 05             	cmp    $0x5,%bl
  802816:	77 18                	ja     802830 <inet_aton+0xaf>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802818:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80281c:	19 c9                	sbb    %ecx,%ecx
  80281e:	83 e1 20             	and    $0x20,%ecx
  802821:	c1 e6 04             	shl    $0x4,%esi
  802824:	29 ca                	sub    %ecx,%edx
  802826:	8d 52 c9             	lea    -0x37(%edx),%edx
  802829:	09 d6                	or     %edx,%esi
        c = *++cp;
  80282b:	0f be 10             	movsbl (%eax),%edx
  80282e:	eb b2                	jmp    8027e2 <inet_aton+0x61>
      } else
        break;
    }
    if (c == '.') {
  802830:	83 fa 2e             	cmp    $0x2e,%edx
  802833:	75 2c                	jne    802861 <inet_aton+0xe0>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802835:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802838:	39 55 d8             	cmp    %edx,-0x28(%ebp)
  80283b:	0f 83 0a 01 00 00    	jae    80294b <inet_aton+0x1ca>
        return (0);
      *pp++ = val;
  802841:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802844:	89 31                	mov    %esi,(%ecx)
      c = *++cp;
  802846:	8d 47 01             	lea    0x1(%edi),%eax
  802849:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80284c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80284f:	80 f9 09             	cmp    $0x9,%cl
  802852:	0f 87 f3 00 00 00    	ja     80294b <inet_aton+0x1ca>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  802858:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  80285c:	e9 47 ff ff ff       	jmp    8027a8 <inet_aton+0x27>
  802861:	89 f3                	mov    %esi,%ebx
  802863:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  802865:	85 d2                	test   %edx,%edx
  802867:	74 37                	je     8028a0 <inet_aton+0x11f>
  802869:	80 f9 1f             	cmp    $0x1f,%cl
  80286c:	0f 86 d9 00 00 00    	jbe    80294b <inet_aton+0x1ca>
  802872:	84 d2                	test   %dl,%dl
  802874:	0f 88 d1 00 00 00    	js     80294b <inet_aton+0x1ca>
  80287a:	83 fa 20             	cmp    $0x20,%edx
  80287d:	8d 76 00             	lea    0x0(%esi),%esi
  802880:	74 1e                	je     8028a0 <inet_aton+0x11f>
  802882:	83 fa 0c             	cmp    $0xc,%edx
  802885:	74 19                	je     8028a0 <inet_aton+0x11f>
  802887:	83 fa 0a             	cmp    $0xa,%edx
  80288a:	74 14                	je     8028a0 <inet_aton+0x11f>
  80288c:	83 fa 0d             	cmp    $0xd,%edx
  80288f:	90                   	nop
  802890:	74 0e                	je     8028a0 <inet_aton+0x11f>
  802892:	83 fa 09             	cmp    $0x9,%edx
  802895:	74 09                	je     8028a0 <inet_aton+0x11f>
  802897:	83 fa 0b             	cmp    $0xb,%edx
  80289a:	0f 85 ab 00 00 00    	jne    80294b <inet_aton+0x1ca>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8028a0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8028a3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8028a6:	29 d1                	sub    %edx,%ecx
  8028a8:	89 ca                	mov    %ecx,%edx
  8028aa:	c1 fa 02             	sar    $0x2,%edx
  8028ad:	83 c2 01             	add    $0x1,%edx
  8028b0:	83 fa 02             	cmp    $0x2,%edx
  8028b3:	74 2d                	je     8028e2 <inet_aton+0x161>
  8028b5:	83 fa 02             	cmp    $0x2,%edx
  8028b8:	7f 10                	jg     8028ca <inet_aton+0x149>
  8028ba:	85 d2                	test   %edx,%edx
  8028bc:	0f 84 89 00 00 00    	je     80294b <inet_aton+0x1ca>
  8028c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028c8:	eb 62                	jmp    80292c <inet_aton+0x1ab>
  8028ca:	83 fa 03             	cmp    $0x3,%edx
  8028cd:	8d 76 00             	lea    0x0(%esi),%esi
  8028d0:	74 22                	je     8028f4 <inet_aton+0x173>
  8028d2:	83 fa 04             	cmp    $0x4,%edx
  8028d5:	8d 76 00             	lea    0x0(%esi),%esi
  8028d8:	75 52                	jne    80292c <inet_aton+0x1ab>
  8028da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028e0:	eb 2b                	jmp    80290d <inet_aton+0x18c>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8028e2:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  8028e7:	90                   	nop
  8028e8:	77 61                	ja     80294b <inet_aton+0x1ca>
      return (0);
    val |= parts[0] << 24;
  8028ea:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8028ed:	c1 e3 18             	shl    $0x18,%ebx
  8028f0:	09 c3                	or     %eax,%ebx
    break;
  8028f2:	eb 38                	jmp    80292c <inet_aton+0x1ab>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8028f4:	3d ff ff 00 00       	cmp    $0xffff,%eax
  8028f9:	77 50                	ja     80294b <inet_aton+0x1ca>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8028fb:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8028fe:	c1 e3 10             	shl    $0x10,%ebx
  802901:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802904:	c1 e2 18             	shl    $0x18,%edx
  802907:	09 d3                	or     %edx,%ebx
  802909:	09 c3                	or     %eax,%ebx
    break;
  80290b:	eb 1f                	jmp    80292c <inet_aton+0x1ab>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80290d:	3d ff 00 00 00       	cmp    $0xff,%eax
  802912:	77 37                	ja     80294b <inet_aton+0x1ca>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  802914:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  802917:	c1 e3 10             	shl    $0x10,%ebx
  80291a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80291d:	c1 e2 18             	shl    $0x18,%edx
  802920:	09 d3                	or     %edx,%ebx
  802922:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802925:	c1 e2 08             	shl    $0x8,%edx
  802928:	09 d3                	or     %edx,%ebx
  80292a:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  80292c:	b8 01 00 00 00       	mov    $0x1,%eax
  802931:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802935:	74 19                	je     802950 <inet_aton+0x1cf>
    addr->s_addr = htonl(val);
  802937:	89 1c 24             	mov    %ebx,(%esp)
  80293a:	e8 16 fe ff ff       	call   802755 <htonl>
  80293f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802942:	89 03                	mov    %eax,(%ebx)
  802944:	b8 01 00 00 00       	mov    $0x1,%eax
  802949:	eb 05                	jmp    802950 <inet_aton+0x1cf>
  80294b:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  802950:	83 c4 28             	add    $0x28,%esp
  802953:	5b                   	pop    %ebx
  802954:	5e                   	pop    %esi
  802955:	5f                   	pop    %edi
  802956:	5d                   	pop    %ebp
  802957:	c3                   	ret    

00802958 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  802958:	55                   	push   %ebp
  802959:	89 e5                	mov    %esp,%ebp
  80295b:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80295e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802961:	89 44 24 04          	mov    %eax,0x4(%esp)
  802965:	8b 45 08             	mov    0x8(%ebp),%eax
  802968:	89 04 24             	mov    %eax,(%esp)
  80296b:	e8 11 fe ff ff       	call   802781 <inet_aton>
  802970:	83 f8 01             	cmp    $0x1,%eax
  802973:	19 c0                	sbb    %eax,%eax
  802975:	0b 45 fc             	or     -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  802978:	c9                   	leave  
  802979:	c3                   	ret    

0080297a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80297a:	55                   	push   %ebp
  80297b:	89 e5                	mov    %esp,%ebp
  80297d:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802980:	8b 45 08             	mov    0x8(%ebp),%eax
  802983:	89 04 24             	mov    %eax,(%esp)
  802986:	e8 ca fd ff ff       	call   802755 <htonl>
}
  80298b:	c9                   	leave  
  80298c:	c3                   	ret    
  80298d:	00 00                	add    %al,(%eax)
	...

00802990 <__udivdi3>:
  802990:	55                   	push   %ebp
  802991:	89 e5                	mov    %esp,%ebp
  802993:	57                   	push   %edi
  802994:	56                   	push   %esi
  802995:	83 ec 10             	sub    $0x10,%esp
  802998:	8b 45 14             	mov    0x14(%ebp),%eax
  80299b:	8b 55 08             	mov    0x8(%ebp),%edx
  80299e:	8b 75 10             	mov    0x10(%ebp),%esi
  8029a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029a4:	85 c0                	test   %eax,%eax
  8029a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8029a9:	75 35                	jne    8029e0 <__udivdi3+0x50>
  8029ab:	39 fe                	cmp    %edi,%esi
  8029ad:	77 61                	ja     802a10 <__udivdi3+0x80>
  8029af:	85 f6                	test   %esi,%esi
  8029b1:	75 0b                	jne    8029be <__udivdi3+0x2e>
  8029b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8029b8:	31 d2                	xor    %edx,%edx
  8029ba:	f7 f6                	div    %esi
  8029bc:	89 c6                	mov    %eax,%esi
  8029be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8029c1:	31 d2                	xor    %edx,%edx
  8029c3:	89 f8                	mov    %edi,%eax
  8029c5:	f7 f6                	div    %esi
  8029c7:	89 c7                	mov    %eax,%edi
  8029c9:	89 c8                	mov    %ecx,%eax
  8029cb:	f7 f6                	div    %esi
  8029cd:	89 c1                	mov    %eax,%ecx
  8029cf:	89 fa                	mov    %edi,%edx
  8029d1:	89 c8                	mov    %ecx,%eax
  8029d3:	83 c4 10             	add    $0x10,%esp
  8029d6:	5e                   	pop    %esi
  8029d7:	5f                   	pop    %edi
  8029d8:	5d                   	pop    %ebp
  8029d9:	c3                   	ret    
  8029da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029e0:	39 f8                	cmp    %edi,%eax
  8029e2:	77 1c                	ja     802a00 <__udivdi3+0x70>
  8029e4:	0f bd d0             	bsr    %eax,%edx
  8029e7:	83 f2 1f             	xor    $0x1f,%edx
  8029ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8029ed:	75 39                	jne    802a28 <__udivdi3+0x98>
  8029ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8029f2:	0f 86 a0 00 00 00    	jbe    802a98 <__udivdi3+0x108>
  8029f8:	39 f8                	cmp    %edi,%eax
  8029fa:	0f 82 98 00 00 00    	jb     802a98 <__udivdi3+0x108>
  802a00:	31 ff                	xor    %edi,%edi
  802a02:	31 c9                	xor    %ecx,%ecx
  802a04:	89 c8                	mov    %ecx,%eax
  802a06:	89 fa                	mov    %edi,%edx
  802a08:	83 c4 10             	add    $0x10,%esp
  802a0b:	5e                   	pop    %esi
  802a0c:	5f                   	pop    %edi
  802a0d:	5d                   	pop    %ebp
  802a0e:	c3                   	ret    
  802a0f:	90                   	nop
  802a10:	89 d1                	mov    %edx,%ecx
  802a12:	89 fa                	mov    %edi,%edx
  802a14:	89 c8                	mov    %ecx,%eax
  802a16:	31 ff                	xor    %edi,%edi
  802a18:	f7 f6                	div    %esi
  802a1a:	89 c1                	mov    %eax,%ecx
  802a1c:	89 fa                	mov    %edi,%edx
  802a1e:	89 c8                	mov    %ecx,%eax
  802a20:	83 c4 10             	add    $0x10,%esp
  802a23:	5e                   	pop    %esi
  802a24:	5f                   	pop    %edi
  802a25:	5d                   	pop    %ebp
  802a26:	c3                   	ret    
  802a27:	90                   	nop
  802a28:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a2c:	89 f2                	mov    %esi,%edx
  802a2e:	d3 e0                	shl    %cl,%eax
  802a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a33:	b8 20 00 00 00       	mov    $0x20,%eax
  802a38:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802a3b:	89 c1                	mov    %eax,%ecx
  802a3d:	d3 ea                	shr    %cl,%edx
  802a3f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a43:	0b 55 ec             	or     -0x14(%ebp),%edx
  802a46:	d3 e6                	shl    %cl,%esi
  802a48:	89 c1                	mov    %eax,%ecx
  802a4a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802a4d:	89 fe                	mov    %edi,%esi
  802a4f:	d3 ee                	shr    %cl,%esi
  802a51:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a55:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a5b:	d3 e7                	shl    %cl,%edi
  802a5d:	89 c1                	mov    %eax,%ecx
  802a5f:	d3 ea                	shr    %cl,%edx
  802a61:	09 d7                	or     %edx,%edi
  802a63:	89 f2                	mov    %esi,%edx
  802a65:	89 f8                	mov    %edi,%eax
  802a67:	f7 75 ec             	divl   -0x14(%ebp)
  802a6a:	89 d6                	mov    %edx,%esi
  802a6c:	89 c7                	mov    %eax,%edi
  802a6e:	f7 65 e8             	mull   -0x18(%ebp)
  802a71:	39 d6                	cmp    %edx,%esi
  802a73:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a76:	72 30                	jb     802aa8 <__udivdi3+0x118>
  802a78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a7b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a7f:	d3 e2                	shl    %cl,%edx
  802a81:	39 c2                	cmp    %eax,%edx
  802a83:	73 05                	jae    802a8a <__udivdi3+0xfa>
  802a85:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802a88:	74 1e                	je     802aa8 <__udivdi3+0x118>
  802a8a:	89 f9                	mov    %edi,%ecx
  802a8c:	31 ff                	xor    %edi,%edi
  802a8e:	e9 71 ff ff ff       	jmp    802a04 <__udivdi3+0x74>
  802a93:	90                   	nop
  802a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a98:	31 ff                	xor    %edi,%edi
  802a9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  802a9f:	e9 60 ff ff ff       	jmp    802a04 <__udivdi3+0x74>
  802aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802aa8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802aab:	31 ff                	xor    %edi,%edi
  802aad:	89 c8                	mov    %ecx,%eax
  802aaf:	89 fa                	mov    %edi,%edx
  802ab1:	83 c4 10             	add    $0x10,%esp
  802ab4:	5e                   	pop    %esi
  802ab5:	5f                   	pop    %edi
  802ab6:	5d                   	pop    %ebp
  802ab7:	c3                   	ret    
	...

00802ac0 <__umoddi3>:
  802ac0:	55                   	push   %ebp
  802ac1:	89 e5                	mov    %esp,%ebp
  802ac3:	57                   	push   %edi
  802ac4:	56                   	push   %esi
  802ac5:	83 ec 20             	sub    $0x20,%esp
  802ac8:	8b 55 14             	mov    0x14(%ebp),%edx
  802acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ace:	8b 7d 10             	mov    0x10(%ebp),%edi
  802ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ad4:	85 d2                	test   %edx,%edx
  802ad6:	89 c8                	mov    %ecx,%eax
  802ad8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802adb:	75 13                	jne    802af0 <__umoddi3+0x30>
  802add:	39 f7                	cmp    %esi,%edi
  802adf:	76 3f                	jbe    802b20 <__umoddi3+0x60>
  802ae1:	89 f2                	mov    %esi,%edx
  802ae3:	f7 f7                	div    %edi
  802ae5:	89 d0                	mov    %edx,%eax
  802ae7:	31 d2                	xor    %edx,%edx
  802ae9:	83 c4 20             	add    $0x20,%esp
  802aec:	5e                   	pop    %esi
  802aed:	5f                   	pop    %edi
  802aee:	5d                   	pop    %ebp
  802aef:	c3                   	ret    
  802af0:	39 f2                	cmp    %esi,%edx
  802af2:	77 4c                	ja     802b40 <__umoddi3+0x80>
  802af4:	0f bd ca             	bsr    %edx,%ecx
  802af7:	83 f1 1f             	xor    $0x1f,%ecx
  802afa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802afd:	75 51                	jne    802b50 <__umoddi3+0x90>
  802aff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802b02:	0f 87 e0 00 00 00    	ja     802be8 <__umoddi3+0x128>
  802b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b0b:	29 f8                	sub    %edi,%eax
  802b0d:	19 d6                	sbb    %edx,%esi
  802b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b15:	89 f2                	mov    %esi,%edx
  802b17:	83 c4 20             	add    $0x20,%esp
  802b1a:	5e                   	pop    %esi
  802b1b:	5f                   	pop    %edi
  802b1c:	5d                   	pop    %ebp
  802b1d:	c3                   	ret    
  802b1e:	66 90                	xchg   %ax,%ax
  802b20:	85 ff                	test   %edi,%edi
  802b22:	75 0b                	jne    802b2f <__umoddi3+0x6f>
  802b24:	b8 01 00 00 00       	mov    $0x1,%eax
  802b29:	31 d2                	xor    %edx,%edx
  802b2b:	f7 f7                	div    %edi
  802b2d:	89 c7                	mov    %eax,%edi
  802b2f:	89 f0                	mov    %esi,%eax
  802b31:	31 d2                	xor    %edx,%edx
  802b33:	f7 f7                	div    %edi
  802b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b38:	f7 f7                	div    %edi
  802b3a:	eb a9                	jmp    802ae5 <__umoddi3+0x25>
  802b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b40:	89 c8                	mov    %ecx,%eax
  802b42:	89 f2                	mov    %esi,%edx
  802b44:	83 c4 20             	add    $0x20,%esp
  802b47:	5e                   	pop    %esi
  802b48:	5f                   	pop    %edi
  802b49:	5d                   	pop    %ebp
  802b4a:	c3                   	ret    
  802b4b:	90                   	nop
  802b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b50:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b54:	d3 e2                	shl    %cl,%edx
  802b56:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b59:	ba 20 00 00 00       	mov    $0x20,%edx
  802b5e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802b61:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802b64:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b68:	89 fa                	mov    %edi,%edx
  802b6a:	d3 ea                	shr    %cl,%edx
  802b6c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b70:	0b 55 f4             	or     -0xc(%ebp),%edx
  802b73:	d3 e7                	shl    %cl,%edi
  802b75:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b79:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b7c:	89 f2                	mov    %esi,%edx
  802b7e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802b81:	89 c7                	mov    %eax,%edi
  802b83:	d3 ea                	shr    %cl,%edx
  802b85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b89:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802b8c:	89 c2                	mov    %eax,%edx
  802b8e:	d3 e6                	shl    %cl,%esi
  802b90:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b94:	d3 ea                	shr    %cl,%edx
  802b96:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b9a:	09 d6                	or     %edx,%esi
  802b9c:	89 f0                	mov    %esi,%eax
  802b9e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802ba1:	d3 e7                	shl    %cl,%edi
  802ba3:	89 f2                	mov    %esi,%edx
  802ba5:	f7 75 f4             	divl   -0xc(%ebp)
  802ba8:	89 d6                	mov    %edx,%esi
  802baa:	f7 65 e8             	mull   -0x18(%ebp)
  802bad:	39 d6                	cmp    %edx,%esi
  802baf:	72 2b                	jb     802bdc <__umoddi3+0x11c>
  802bb1:	39 c7                	cmp    %eax,%edi
  802bb3:	72 23                	jb     802bd8 <__umoddi3+0x118>
  802bb5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bb9:	29 c7                	sub    %eax,%edi
  802bbb:	19 d6                	sbb    %edx,%esi
  802bbd:	89 f0                	mov    %esi,%eax
  802bbf:	89 f2                	mov    %esi,%edx
  802bc1:	d3 ef                	shr    %cl,%edi
  802bc3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bc7:	d3 e0                	shl    %cl,%eax
  802bc9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bcd:	09 f8                	or     %edi,%eax
  802bcf:	d3 ea                	shr    %cl,%edx
  802bd1:	83 c4 20             	add    $0x20,%esp
  802bd4:	5e                   	pop    %esi
  802bd5:	5f                   	pop    %edi
  802bd6:	5d                   	pop    %ebp
  802bd7:	c3                   	ret    
  802bd8:	39 d6                	cmp    %edx,%esi
  802bda:	75 d9                	jne    802bb5 <__umoddi3+0xf5>
  802bdc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802bdf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802be2:	eb d1                	jmp    802bb5 <__umoddi3+0xf5>
  802be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802be8:	39 f2                	cmp    %esi,%edx
  802bea:	0f 82 18 ff ff ff    	jb     802b08 <__umoddi3+0x48>
  802bf0:	e9 1d ff ff ff       	jmp    802b12 <__umoddi3+0x52>
