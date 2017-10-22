
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 db 01 00 00       	call   80020c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 70 2c 80 00 	movl   $0x802c70,(%esp)
  800045:	e8 93 02 00 00       	call   8002dd <cprintf>
	exit();
  80004a:	e8 11 02 00 00       	call   800260 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <handle_client>:

void
handle_client(int sock)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 3c             	sub    $0x3c,%esp
  80005a:	8b 7d 08             	mov    0x8(%ebp),%edi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005d:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  800064:	00 
  800065:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	89 3c 24             	mov    %edi,(%esp)
  80006f:	e8 6a 19 00 00       	call   8019de <read>
  800074:	89 c3                	mov    %eax,%ebx
  800076:	85 c0                	test   %eax,%eax
  800078:	79 0a                	jns    800084 <handle_client+0x33>
		die("Failed to receive initial bytes from client");
  80007a:	b8 74 2c 80 00       	mov    $0x802c74,%eax
  80007f:	e8 b0 ff ff ff       	call   800034 <die>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  800084:	85 db                	test   %ebx,%ebx
  800086:	7e 49                	jle    8000d1 <handle_client+0x80>
		// Send back received data
		if (write(sock, buffer, received) != received)
  800088:	8d 75 c8             	lea    -0x38(%ebp),%esi
  80008b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80008f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800093:	89 3c 24             	mov    %edi,(%esp)
  800096:	e8 ba 18 00 00       	call   801955 <write>
  80009b:	39 d8                	cmp    %ebx,%eax
  80009d:	74 0a                	je     8000a9 <handle_client+0x58>
			die("Failed to send bytes to client");
  80009f:	b8 a0 2c 80 00       	mov    $0x802ca0,%eax
  8000a4:	e8 8b ff ff ff       	call   800034 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000a9:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  8000b0:	00 
  8000b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b5:	89 3c 24             	mov    %edi,(%esp)
  8000b8:	e8 21 19 00 00       	call   8019de <read>
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	79 0a                	jns    8000cd <handle_client+0x7c>
			die("Failed to receive additional bytes from client");
  8000c3:	b8 c0 2c 80 00       	mov    $0x802cc0,%eax
  8000c8:	e8 67 ff ff ff       	call   800034 <die>
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000cd:	85 db                	test   %ebx,%ebx
  8000cf:	7f ba                	jg     80008b <handle_client+0x3a>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000d1:	89 3c 24             	mov    %edi,(%esp)
  8000d4:	e8 65 1a 00 00       	call   801b3e <close>
}
  8000d9:	83 c4 3c             	add    $0x3c,%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <umain>:

void
umain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 4c             	sub    $0x4c,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000ea:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8000f1:	00 
  8000f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000f9:	00 
  8000fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800101:	e8 c8 1f 00 00       	call   8020ce <socket>
  800106:	89 c6                	mov    %eax,%esi
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 0a                	jns    800116 <umain+0x35>
		die("Failed to create socket");
  80010c:	b8 20 2c 80 00       	mov    $0x802c20,%eax
  800111:	e8 1e ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  800116:	c7 04 24 38 2c 80 00 	movl   $0x802c38,(%esp)
  80011d:	e8 bb 01 00 00       	call   8002dd <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800122:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800129:	00 
  80012a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800131:	00 
  800132:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800135:	89 1c 24             	mov    %ebx,(%esp)
  800138:	e8 59 0c 00 00       	call   800d96 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  80013d:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 28 26 00 00       	call   802775 <htonl>
  80014d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800150:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800157:	e8 f8 25 00 00       	call   802754 <htons>
  80015c:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800160:	c7 04 24 47 2c 80 00 	movl   $0x802c47,(%esp)
  800167:	e8 71 01 00 00       	call   8002dd <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  80016c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800173:	00 
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	89 34 24             	mov    %esi,(%esp)
  80017b:	e8 18 20 00 00       	call   802198 <bind>
  800180:	85 c0                	test   %eax,%eax
  800182:	79 0a                	jns    80018e <umain+0xad>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800184:	b8 f0 2c 80 00       	mov    $0x802cf0,%eax
  800189:	e8 a6 fe ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  80018e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  800195:	00 
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 8a 1f 00 00       	call   802128 <listen>
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 0a                	jns    8001ac <umain+0xcb>
		die("Failed to listen on server socket");
  8001a2:	b8 14 2d 80 00       	mov    $0x802d14,%eax
  8001a7:	e8 88 fe ff ff       	call   800034 <die>

	cprintf("bound\n");
  8001ac:	c7 04 24 57 2c 80 00 	movl   $0x802c57,(%esp)
  8001b3:	e8 25 01 00 00       	call   8002dd <cprintf>
	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
  8001b8:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  8001bb:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
  8001c2:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8001c6:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	89 34 24             	mov    %esi,(%esp)
  8001d0:	e8 ed 1f 00 00       	call   8021c2 <accept>
  8001d5:	89 c3                	mov    %eax,%ebx

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  8001d7:	85 c0                	test   %eax,%eax
  8001d9:	79 0a                	jns    8001e5 <umain+0x104>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001db:	b8 38 2d 80 00       	mov    $0x802d38,%eax
  8001e0:	e8 4f fe ff ff       	call   800034 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 a0 24 00 00       	call   802690 <inet_ntoa>
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 5e 2c 80 00 	movl   $0x802c5e,(%esp)
  8001fb:	e8 dd 00 00 00       	call   8002dd <cprintf>
		handle_client(clientsock);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 49 fe ff ff       	call   800051 <handle_client>
	}
  800208:	eb b1                	jmp    8001bb <umain+0xda>
	...

0080020c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 18             	sub    $0x18,%esp
  800212:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800215:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800218:	8b 75 08             	mov    0x8(%ebp),%esi
  80021b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80021e:	e8 04 14 00 00       	call   801627 <sys_getenvid>
  800223:	25 ff 03 00 00       	and    $0x3ff,%eax
  800228:	89 c2                	mov    %eax,%edx
  80022a:	c1 e2 07             	shl    $0x7,%edx
  80022d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800234:	a3 18 50 80 00       	mov    %eax,0x805018
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800239:	85 f6                	test   %esi,%esi
  80023b:	7e 07                	jle    800244 <libmain+0x38>
		binaryname = argv[0];
  80023d:	8b 03                	mov    (%ebx),%eax
  80023f:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800244:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800248:	89 34 24             	mov    %esi,(%esp)
  80024b:	e8 91 fe ff ff       	call   8000e1 <umain>

	// exit gracefully
	exit();
  800250:	e8 0b 00 00 00       	call   800260 <exit>
}
  800255:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800258:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80025b:	89 ec                	mov    %ebp,%esp
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    
	...

00800260 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800266:	e8 50 19 00 00       	call   801bbb <close_all>
	sys_env_destroy(0);
  80026b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800272:	e8 f0 13 00 00       	call   801667 <sys_env_destroy>
}
  800277:	c9                   	leave  
  800278:	c3                   	ret    
  800279:	00 00                	add    %al,(%eax)
	...

0080027c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800285:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028c:	00 00 00 
	b.cnt = 0;
  80028f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800296:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800299:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b1:	c7 04 24 f7 02 80 00 	movl   $0x8002f7,(%esp)
  8002b8:	e8 cf 01 00 00       	call   80048c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	e8 67 0d 00 00       	call   80103c <sys_cputs>

	return b.cnt;
}
  8002d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002e3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	89 04 24             	mov    %eax,(%esp)
  8002f0:	e8 87 ff ff ff       	call   80027c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 14             	sub    $0x14,%esp
  8002fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800301:	8b 03                	mov    (%ebx),%eax
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030a:	83 c0 01             	add    $0x1,%eax
  80030d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800314:	75 19                	jne    80032f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800316:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80031d:	00 
  80031e:	8d 43 08             	lea    0x8(%ebx),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 13 0d 00 00       	call   80103c <sys_cputs>
		b->idx = 0;
  800329:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80032f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800333:	83 c4 14             	add    $0x14,%esp
  800336:	5b                   	pop    %ebx
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    
  800339:	00 00                	add    %al,(%eax)
  80033b:	00 00                	add    %al,(%eax)
  80033d:	00 00                	add    %al,(%eax)
	...

00800340 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 4c             	sub    $0x4c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d6                	mov    %edx,%esi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800354:	8b 55 0c             	mov    0xc(%ebp),%edx
  800357:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80035a:	8b 45 10             	mov    0x10(%ebp),%eax
  80035d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800360:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800363:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800366:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036b:	39 d1                	cmp    %edx,%ecx
  80036d:	72 07                	jb     800376 <printnum_v2+0x36>
  80036f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800372:	39 d0                	cmp    %edx,%eax
  800374:	77 5f                	ja     8003d5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800376:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80037a:	83 eb 01             	sub    $0x1,%ebx
  80037d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800381:	89 44 24 08          	mov    %eax,0x8(%esp)
  800385:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800389:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80038d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800390:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800393:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800396:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80039a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a1:	00 
  8003a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003af:	e8 fc 25 00 00       	call   8029b0 <__udivdi3>
  8003b4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8003ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c2:	89 04 24             	mov    %eax,(%esp)
  8003c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003c9:	89 f2                	mov    %esi,%edx
  8003cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ce:	e8 6d ff ff ff       	call   800340 <printnum_v2>
  8003d3:	eb 1e                	jmp    8003f3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8003d5:	83 ff 2d             	cmp    $0x2d,%edi
  8003d8:	74 19                	je     8003f3 <printnum_v2+0xb3>
		while (--width > 0)
  8003da:	83 eb 01             	sub    $0x1,%ebx
  8003dd:	85 db                	test   %ebx,%ebx
  8003df:	90                   	nop
  8003e0:	7e 11                	jle    8003f3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8003e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e6:	89 3c 24             	mov    %edi,(%esp)
  8003e9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8003ec:	83 eb 01             	sub    $0x1,%ebx
  8003ef:	85 db                	test   %ebx,%ebx
  8003f1:	7f ef                	jg     8003e2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800402:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800409:	00 
  80040a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80040d:	89 14 24             	mov    %edx,(%esp)
  800410:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800413:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800417:	e8 c4 26 00 00       	call   802ae0 <__umoddi3>
  80041c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800420:	0f be 80 65 2d 80 00 	movsbl 0x802d65(%eax),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80042d:	83 c4 4c             	add    $0x4c,%esp
  800430:	5b                   	pop    %ebx
  800431:	5e                   	pop    %esi
  800432:	5f                   	pop    %edi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    

00800435 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800438:	83 fa 01             	cmp    $0x1,%edx
  80043b:	7e 0e                	jle    80044b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043d:	8b 10                	mov    (%eax),%edx
  80043f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800442:	89 08                	mov    %ecx,(%eax)
  800444:	8b 02                	mov    (%edx),%eax
  800446:	8b 52 04             	mov    0x4(%edx),%edx
  800449:	eb 22                	jmp    80046d <getuint+0x38>
	else if (lflag)
  80044b:	85 d2                	test   %edx,%edx
  80044d:	74 10                	je     80045f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044f:	8b 10                	mov    (%eax),%edx
  800451:	8d 4a 04             	lea    0x4(%edx),%ecx
  800454:	89 08                	mov    %ecx,(%eax)
  800456:	8b 02                	mov    (%edx),%eax
  800458:	ba 00 00 00 00       	mov    $0x0,%edx
  80045d:	eb 0e                	jmp    80046d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045f:	8b 10                	mov    (%eax),%edx
  800461:	8d 4a 04             	lea    0x4(%edx),%ecx
  800464:	89 08                	mov    %ecx,(%eax)
  800466:	8b 02                	mov    (%edx),%eax
  800468:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046d:	5d                   	pop    %ebp
  80046e:	c3                   	ret    

0080046f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800475:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800479:	8b 10                	mov    (%eax),%edx
  80047b:	3b 50 04             	cmp    0x4(%eax),%edx
  80047e:	73 0a                	jae    80048a <sprintputch+0x1b>
		*b->buf++ = ch;
  800480:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800483:	88 0a                	mov    %cl,(%edx)
  800485:	83 c2 01             	add    $0x1,%edx
  800488:	89 10                	mov    %edx,(%eax)
}
  80048a:	5d                   	pop    %ebp
  80048b:	c3                   	ret    

0080048c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	57                   	push   %edi
  800490:	56                   	push   %esi
  800491:	53                   	push   %ebx
  800492:	83 ec 6c             	sub    $0x6c,%esp
  800495:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800498:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80049f:	eb 1a                	jmp    8004bb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a1:	85 c0                	test   %eax,%eax
  8004a3:	0f 84 66 06 00 00    	je     800b0f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8004a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b0:	89 04 24             	mov    %eax,(%esp)
  8004b3:	ff 55 08             	call   *0x8(%ebp)
  8004b6:	eb 03                	jmp    8004bb <vprintfmt+0x2f>
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004bb:	0f b6 07             	movzbl (%edi),%eax
  8004be:	83 c7 01             	add    $0x1,%edi
  8004c1:	83 f8 25             	cmp    $0x25,%eax
  8004c4:	75 db                	jne    8004a1 <vprintfmt+0x15>
  8004c6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8004ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004cf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8004d6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8004db:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004e2:	be 00 00 00 00       	mov    $0x0,%esi
  8004e7:	eb 06                	jmp    8004ef <vprintfmt+0x63>
  8004e9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8004ed:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	0f b6 17             	movzbl (%edi),%edx
  8004f2:	0f b6 c2             	movzbl %dl,%eax
  8004f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f8:	8d 47 01             	lea    0x1(%edi),%eax
  8004fb:	83 ea 23             	sub    $0x23,%edx
  8004fe:	80 fa 55             	cmp    $0x55,%dl
  800501:	0f 87 60 05 00 00    	ja     800a67 <vprintfmt+0x5db>
  800507:	0f b6 d2             	movzbl %dl,%edx
  80050a:	ff 24 95 40 2f 80 00 	jmp    *0x802f40(,%edx,4)
  800511:	b9 01 00 00 00       	mov    $0x1,%ecx
  800516:	eb d5                	jmp    8004ed <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800518:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80051b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80051e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800521:	8d 7a d0             	lea    -0x30(%edx),%edi
  800524:	83 ff 09             	cmp    $0x9,%edi
  800527:	76 08                	jbe    800531 <vprintfmt+0xa5>
  800529:	eb 40                	jmp    80056b <vprintfmt+0xdf>
  80052b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80052f:	eb bc                	jmp    8004ed <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800531:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800534:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800537:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80053b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80053e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800541:	83 ff 09             	cmp    $0x9,%edi
  800544:	76 eb                	jbe    800531 <vprintfmt+0xa5>
  800546:	eb 23                	jmp    80056b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800548:	8b 55 14             	mov    0x14(%ebp),%edx
  80054b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80054e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800551:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800553:	eb 16                	jmp    80056b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800555:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800558:	c1 fa 1f             	sar    $0x1f,%edx
  80055b:	f7 d2                	not    %edx
  80055d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800560:	eb 8b                	jmp    8004ed <vprintfmt+0x61>
  800562:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800569:	eb 82                	jmp    8004ed <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80056b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056f:	0f 89 78 ff ff ff    	jns    8004ed <vprintfmt+0x61>
  800575:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800578:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80057b:	e9 6d ff ff ff       	jmp    8004ed <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800580:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800583:	e9 65 ff ff ff       	jmp    8004ed <vprintfmt+0x61>
  800588:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 55 0c             	mov    0xc(%ebp),%edx
  800597:	89 54 24 04          	mov    %edx,0x4(%esp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 04 24             	mov    %eax,(%esp)
  8005a0:	ff 55 08             	call   *0x8(%ebp)
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8005a6:	e9 10 ff ff ff       	jmp    8004bb <vprintfmt+0x2f>
  8005ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 c2                	mov    %eax,%edx
  8005bb:	c1 fa 1f             	sar    $0x1f,%edx
  8005be:	31 d0                	xor    %edx,%eax
  8005c0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c2:	83 f8 0f             	cmp    $0xf,%eax
  8005c5:	7f 0b                	jg     8005d2 <vprintfmt+0x146>
  8005c7:	8b 14 85 a0 30 80 00 	mov    0x8030a0(,%eax,4),%edx
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	75 26                	jne    8005f8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8005d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d6:	c7 44 24 08 76 2d 80 	movl   $0x802d76,0x8(%esp)
  8005dd:	00 
  8005de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005e8:	89 1c 24             	mov    %ebx,(%esp)
  8005eb:	e8 a7 05 00 00       	call   800b97 <printfmt>
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f3:	e9 c3 fe ff ff       	jmp    8004bb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005fc:	c7 44 24 08 be 31 80 	movl   $0x8031be,0x8(%esp)
  800603:	00 
  800604:	8b 45 0c             	mov    0xc(%ebp),%eax
  800607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060b:	8b 55 08             	mov    0x8(%ebp),%edx
  80060e:	89 14 24             	mov    %edx,(%esp)
  800611:	e8 81 05 00 00       	call   800b97 <printfmt>
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800619:	e9 9d fe ff ff       	jmp    8004bb <vprintfmt+0x2f>
  80061e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800621:	89 c7                	mov    %eax,%edi
  800623:	89 d9                	mov    %ebx,%ecx
  800625:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800628:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 30                	mov    (%eax),%esi
  800636:	85 f6                	test   %esi,%esi
  800638:	75 05                	jne    80063f <vprintfmt+0x1b3>
  80063a:	be 7f 2d 80 00       	mov    $0x802d7f,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80063f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800643:	7e 06                	jle    80064b <vprintfmt+0x1bf>
  800645:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800649:	75 10                	jne    80065b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064b:	0f be 06             	movsbl (%esi),%eax
  80064e:	85 c0                	test   %eax,%eax
  800650:	0f 85 a2 00 00 00    	jne    8006f8 <vprintfmt+0x26c>
  800656:	e9 92 00 00 00       	jmp    8006ed <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065f:	89 34 24             	mov    %esi,(%esp)
  800662:	e8 74 05 00 00       	call   800bdb <strnlen>
  800667:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80066a:	29 c2                	sub    %eax,%edx
  80066c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80066f:	85 d2                	test   %edx,%edx
  800671:	7e d8                	jle    80064b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800673:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800677:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80067a:	89 d3                	mov    %edx,%ebx
  80067c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80067f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800682:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800685:	89 ce                	mov    %ecx,%esi
  800687:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068b:	89 34 24             	mov    %esi,(%esp)
  80068e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800691:	83 eb 01             	sub    $0x1,%ebx
  800694:	85 db                	test   %ebx,%ebx
  800696:	7f ef                	jg     800687 <vprintfmt+0x1fb>
  800698:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80069b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80069e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8006a1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006a8:	eb a1                	jmp    80064b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006aa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006ae:	74 1b                	je     8006cb <vprintfmt+0x23f>
  8006b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006b3:	83 fa 5e             	cmp    $0x5e,%edx
  8006b6:	76 13                	jbe    8006cb <vprintfmt+0x23f>
					putch('?', putdat);
  8006b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bf:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006c6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c9:	eb 0d                	jmp    8006d8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d2:	89 04 24             	mov    %eax,(%esp)
  8006d5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d8:	83 ef 01             	sub    $0x1,%edi
  8006db:	0f be 06             	movsbl (%esi),%eax
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	74 05                	je     8006e7 <vprintfmt+0x25b>
  8006e2:	83 c6 01             	add    $0x1,%esi
  8006e5:	eb 1a                	jmp    800701 <vprintfmt+0x275>
  8006e7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006ea:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f1:	7f 1f                	jg     800712 <vprintfmt+0x286>
  8006f3:	e9 c0 fd ff ff       	jmp    8004b8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f8:	83 c6 01             	add    $0x1,%esi
  8006fb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006fe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800701:	85 db                	test   %ebx,%ebx
  800703:	78 a5                	js     8006aa <vprintfmt+0x21e>
  800705:	83 eb 01             	sub    $0x1,%ebx
  800708:	79 a0                	jns    8006aa <vprintfmt+0x21e>
  80070a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80070d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800710:	eb db                	jmp    8006ed <vprintfmt+0x261>
  800712:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800715:	8b 75 0c             	mov    0xc(%ebp),%esi
  800718:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80071b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80071e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800722:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800729:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072b:	83 eb 01             	sub    $0x1,%ebx
  80072e:	85 db                	test   %ebx,%ebx
  800730:	7f ec                	jg     80071e <vprintfmt+0x292>
  800732:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800735:	e9 81 fd ff ff       	jmp    8004bb <vprintfmt+0x2f>
  80073a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073d:	83 fe 01             	cmp    $0x1,%esi
  800740:	7e 10                	jle    800752 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 50 08             	lea    0x8(%eax),%edx
  800748:	89 55 14             	mov    %edx,0x14(%ebp)
  80074b:	8b 18                	mov    (%eax),%ebx
  80074d:	8b 70 04             	mov    0x4(%eax),%esi
  800750:	eb 26                	jmp    800778 <vprintfmt+0x2ec>
	else if (lflag)
  800752:	85 f6                	test   %esi,%esi
  800754:	74 12                	je     800768 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8d 50 04             	lea    0x4(%eax),%edx
  80075c:	89 55 14             	mov    %edx,0x14(%ebp)
  80075f:	8b 18                	mov    (%eax),%ebx
  800761:	89 de                	mov    %ebx,%esi
  800763:	c1 fe 1f             	sar    $0x1f,%esi
  800766:	eb 10                	jmp    800778 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 50 04             	lea    0x4(%eax),%edx
  80076e:	89 55 14             	mov    %edx,0x14(%ebp)
  800771:	8b 18                	mov    (%eax),%ebx
  800773:	89 de                	mov    %ebx,%esi
  800775:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800778:	83 f9 01             	cmp    $0x1,%ecx
  80077b:	75 1e                	jne    80079b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80077d:	85 f6                	test   %esi,%esi
  80077f:	78 1a                	js     80079b <vprintfmt+0x30f>
  800781:	85 f6                	test   %esi,%esi
  800783:	7f 05                	jg     80078a <vprintfmt+0x2fe>
  800785:	83 fb 00             	cmp    $0x0,%ebx
  800788:	76 11                	jbe    80079b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80078a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800791:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800798:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80079b:	85 f6                	test   %esi,%esi
  80079d:	78 13                	js     8007b2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80079f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8007a2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8007a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ad:	e9 da 00 00 00       	jmp    80088c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007c0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007c3:	89 da                	mov    %ebx,%edx
  8007c5:	89 f1                	mov    %esi,%ecx
  8007c7:	f7 da                	neg    %edx
  8007c9:	83 d1 00             	adc    $0x0,%ecx
  8007cc:	f7 d9                	neg    %ecx
  8007ce:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007d1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007dc:	e9 ab 00 00 00       	jmp    80088c <vprintfmt+0x400>
  8007e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 47 fc ff ff       	call   800435 <getuint>
  8007ee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007f1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8007fc:	e9 8b 00 00 00       	jmp    80088c <vprintfmt+0x400>
  800801:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800807:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80080b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800812:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800815:	89 f2                	mov    %esi,%edx
  800817:	8d 45 14             	lea    0x14(%ebp),%eax
  80081a:	e8 16 fc ff ff       	call   800435 <getuint>
  80081f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800822:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800825:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800828:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80082d:	eb 5d                	jmp    80088c <vprintfmt+0x400>
  80082f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800835:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800839:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800840:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800843:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800847:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 50 04             	lea    0x4(%eax),%edx
  800857:	89 55 14             	mov    %edx,0x14(%ebp)
  80085a:	8b 10                	mov    (%eax),%edx
  80085c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800861:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800864:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800867:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80086f:	eb 1b                	jmp    80088c <vprintfmt+0x400>
  800871:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800874:	89 f2                	mov    %esi,%edx
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
  800879:	e8 b7 fb ff ff       	call   800435 <getuint>
  80087e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800881:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800884:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800887:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800890:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800893:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800896:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80089a:	77 09                	ja     8008a5 <vprintfmt+0x419>
  80089c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80089f:	0f 82 ac 00 00 00    	jb     800951 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8008a5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008a8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8008ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008af:	83 ea 01             	sub    $0x1,%edx
  8008b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ba:	8b 44 24 08          	mov    0x8(%esp),%eax
  8008be:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8008c2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8008c5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8008c8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008d6:	00 
  8008d7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008da:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008dd:	89 0c 24             	mov    %ecx,(%esp)
  8008e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e4:	e8 c7 20 00 00       	call   8029b0 <__udivdi3>
  8008e9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8008ec:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8008ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008f3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008f7:	89 04 24             	mov    %eax,(%esp)
  8008fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	e8 37 fa ff ff       	call   800340 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800909:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80090c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800910:	8b 74 24 04          	mov    0x4(%esp),%esi
  800914:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800917:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800922:	00 
  800923:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800926:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800929:	89 14 24             	mov    %edx,(%esp)
  80092c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800930:	e8 ab 21 00 00       	call   802ae0 <__umoddi3>
  800935:	89 74 24 04          	mov    %esi,0x4(%esp)
  800939:	0f be 80 65 2d 80 00 	movsbl 0x802d65(%eax),%eax
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800946:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80094a:	74 54                	je     8009a0 <vprintfmt+0x514>
  80094c:	e9 67 fb ff ff       	jmp    8004b8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800951:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800955:	8d 76 00             	lea    0x0(%esi),%esi
  800958:	0f 84 2a 01 00 00    	je     800a88 <vprintfmt+0x5fc>
		while (--width > 0)
  80095e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800961:	83 ef 01             	sub    $0x1,%edi
  800964:	85 ff                	test   %edi,%edi
  800966:	0f 8e 5e 01 00 00    	jle    800aca <vprintfmt+0x63e>
  80096c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80096f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800972:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800975:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800978:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80097b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80097e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800982:	89 1c 24             	mov    %ebx,(%esp)
  800985:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800988:	83 ef 01             	sub    $0x1,%edi
  80098b:	85 ff                	test   %edi,%edi
  80098d:	7f ef                	jg     80097e <vprintfmt+0x4f2>
  80098f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800992:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800995:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800998:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80099b:	e9 2a 01 00 00       	jmp    800aca <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8009a0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8009a3:	83 eb 01             	sub    $0x1,%ebx
  8009a6:	85 db                	test   %ebx,%ebx
  8009a8:	0f 8e 0a fb ff ff    	jle    8004b8 <vprintfmt+0x2c>
  8009ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8009b4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8009b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009c2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8009c4:	83 eb 01             	sub    $0x1,%ebx
  8009c7:	85 db                	test   %ebx,%ebx
  8009c9:	7f ec                	jg     8009b7 <vprintfmt+0x52b>
  8009cb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8009ce:	e9 e8 fa ff ff       	jmp    8004bb <vprintfmt+0x2f>
  8009d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8009d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d9:	8d 50 04             	lea    0x4(%eax),%edx
  8009dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8009df:	8b 00                	mov    (%eax),%eax
  8009e1:	85 c0                	test   %eax,%eax
  8009e3:	75 2a                	jne    800a0f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8009e5:	c7 44 24 0c 98 2e 80 	movl   $0x802e98,0xc(%esp)
  8009ec:	00 
  8009ed:	c7 44 24 08 be 31 80 	movl   $0x8031be,0x8(%esp)
  8009f4:	00 
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ff:	89 0c 24             	mov    %ecx,(%esp)
  800a02:	e8 90 01 00 00       	call   800b97 <printfmt>
  800a07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a0a:	e9 ac fa ff ff       	jmp    8004bb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a12:	8b 13                	mov    (%ebx),%edx
  800a14:	83 fa 7f             	cmp    $0x7f,%edx
  800a17:	7e 29                	jle    800a42 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800a19:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800a1b:	c7 44 24 0c d0 2e 80 	movl   $0x802ed0,0xc(%esp)
  800a22:	00 
  800a23:	c7 44 24 08 be 31 80 	movl   $0x8031be,0x8(%esp)
  800a2a:	00 
  800a2b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	89 04 24             	mov    %eax,(%esp)
  800a35:	e8 5d 01 00 00       	call   800b97 <printfmt>
  800a3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a3d:	e9 79 fa ff ff       	jmp    8004bb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800a42:	88 10                	mov    %dl,(%eax)
  800a44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a47:	e9 6f fa ff ff       	jmp    8004bb <vprintfmt+0x2f>
  800a4c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a55:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a59:	89 14 24             	mov    %edx,(%esp)
  800a5c:	ff 55 08             	call   *0x8(%ebp)
  800a5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800a62:	e9 54 fa ff ff       	jmp    8004bb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a75:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a78:	8d 47 ff             	lea    -0x1(%edi),%eax
  800a7b:	80 38 25             	cmpb   $0x25,(%eax)
  800a7e:	0f 84 37 fa ff ff    	je     8004bb <vprintfmt+0x2f>
  800a84:	89 c7                	mov    %eax,%edi
  800a86:	eb f0                	jmp    800a78 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a93:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a96:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a9a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800aa1:	00 
  800aa2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800aa5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800aa8:	89 04 24             	mov    %eax,(%esp)
  800aab:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aaf:	e8 2c 20 00 00       	call   802ae0 <__umoddi3>
  800ab4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ab8:	0f be 80 65 2d 80 00 	movsbl 0x802d65(%eax),%eax
  800abf:	89 04 24             	mov    %eax,(%esp)
  800ac2:	ff 55 08             	call   *0x8(%ebp)
  800ac5:	e9 d6 fe ff ff       	jmp    8009a0 <vprintfmt+0x514>
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ad5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ad8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800adc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ae3:	00 
  800ae4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800ae7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800aea:	89 04 24             	mov    %eax,(%esp)
  800aed:	89 54 24 04          	mov    %edx,0x4(%esp)
  800af1:	e8 ea 1f 00 00       	call   802ae0 <__umoddi3>
  800af6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800afa:	0f be 80 65 2d 80 00 	movsbl 0x802d65(%eax),%eax
  800b01:	89 04 24             	mov    %eax,(%esp)
  800b04:	ff 55 08             	call   *0x8(%ebp)
  800b07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b0a:	e9 ac f9 ff ff       	jmp    8004bb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b0f:	83 c4 6c             	add    $0x6c,%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 28             	sub    $0x28,%esp
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800b23:	85 c0                	test   %eax,%eax
  800b25:	74 04                	je     800b2b <vsnprintf+0x14>
  800b27:	85 d2                	test   %edx,%edx
  800b29:	7f 07                	jg     800b32 <vsnprintf+0x1b>
  800b2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b30:	eb 3b                	jmp    800b6d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b35:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b43:	8b 45 14             	mov    0x14(%ebp),%eax
  800b46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b51:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b58:	c7 04 24 6f 04 80 00 	movl   $0x80046f,(%esp)
  800b5f:	e8 28 f9 ff ff       	call   80048c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b67:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b75:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b78:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	89 04 24             	mov    %eax,(%esp)
  800b90:	e8 82 ff ff ff       	call   800b17 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b9d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800ba0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	89 04 24             	mov    %eax,(%esp)
  800bb8:	e8 cf f8 ff ff       	call   80048c <vprintfmt>
	va_end(ap);
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    
	...

00800bc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	80 3a 00             	cmpb   $0x0,(%edx)
  800bce:	74 09                	je     800bd9 <strlen+0x19>
		n++;
  800bd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bd7:	75 f7                	jne    800bd0 <strlen+0x10>
		n++;
	return n;
}
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	53                   	push   %ebx
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be5:	85 c9                	test   %ecx,%ecx
  800be7:	74 19                	je     800c02 <strnlen+0x27>
  800be9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bec:	74 14                	je     800c02 <strnlen+0x27>
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bf3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf6:	39 c8                	cmp    %ecx,%eax
  800bf8:	74 0d                	je     800c07 <strnlen+0x2c>
  800bfa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bfe:	75 f3                	jne    800bf3 <strnlen+0x18>
  800c00:	eb 05                	jmp    800c07 <strnlen+0x2c>
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c20:	83 c2 01             	add    $0x1,%edx
  800c23:	84 c9                	test   %cl,%cl
  800c25:	75 f2                	jne    800c19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c27:	5b                   	pop    %ebx
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 08             	sub    $0x8,%esp
  800c31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c34:	89 1c 24             	mov    %ebx,(%esp)
  800c37:	e8 84 ff ff ff       	call   800bc0 <strlen>
	strcpy(dst + len, src);
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c46:	89 04 24             	mov    %eax,(%esp)
  800c49:	e8 bc ff ff ff       	call   800c0a <strcpy>
	return dst;
}
  800c4e:	89 d8                	mov    %ebx,%eax
  800c50:	83 c4 08             	add    $0x8,%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c64:	85 f6                	test   %esi,%esi
  800c66:	74 18                	je     800c80 <strncpy+0x2a>
  800c68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c6d:	0f b6 1a             	movzbl (%edx),%ebx
  800c70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c73:	80 3a 01             	cmpb   $0x1,(%edx)
  800c76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c79:	83 c1 01             	add    $0x1,%ecx
  800c7c:	39 ce                	cmp    %ecx,%esi
  800c7e:	77 ed                	ja     800c6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	8b 75 08             	mov    0x8(%ebp),%esi
  800c8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c92:	89 f0                	mov    %esi,%eax
  800c94:	85 c9                	test   %ecx,%ecx
  800c96:	74 27                	je     800cbf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c98:	83 e9 01             	sub    $0x1,%ecx
  800c9b:	74 1d                	je     800cba <strlcpy+0x36>
  800c9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ca0:	84 db                	test   %bl,%bl
  800ca2:	74 16                	je     800cba <strlcpy+0x36>
			*dst++ = *src++;
  800ca4:	88 18                	mov    %bl,(%eax)
  800ca6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ca9:	83 e9 01             	sub    $0x1,%ecx
  800cac:	74 0e                	je     800cbc <strlcpy+0x38>
			*dst++ = *src++;
  800cae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cb1:	0f b6 1a             	movzbl (%edx),%ebx
  800cb4:	84 db                	test   %bl,%bl
  800cb6:	75 ec                	jne    800ca4 <strlcpy+0x20>
  800cb8:	eb 02                	jmp    800cbc <strlcpy+0x38>
  800cba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cbc:	c6 00 00             	movb   $0x0,(%eax)
  800cbf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cce:	0f b6 01             	movzbl (%ecx),%eax
  800cd1:	84 c0                	test   %al,%al
  800cd3:	74 15                	je     800cea <strcmp+0x25>
  800cd5:	3a 02                	cmp    (%edx),%al
  800cd7:	75 11                	jne    800cea <strcmp+0x25>
		p++, q++;
  800cd9:	83 c1 01             	add    $0x1,%ecx
  800cdc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cdf:	0f b6 01             	movzbl (%ecx),%eax
  800ce2:	84 c0                	test   %al,%al
  800ce4:	74 04                	je     800cea <strcmp+0x25>
  800ce6:	3a 02                	cmp    (%edx),%al
  800ce8:	74 ef                	je     800cd9 <strcmp+0x14>
  800cea:	0f b6 c0             	movzbl %al,%eax
  800ced:	0f b6 12             	movzbl (%edx),%edx
  800cf0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	74 23                	je     800d28 <strncmp+0x34>
  800d05:	0f b6 1a             	movzbl (%edx),%ebx
  800d08:	84 db                	test   %bl,%bl
  800d0a:	74 25                	je     800d31 <strncmp+0x3d>
  800d0c:	3a 19                	cmp    (%ecx),%bl
  800d0e:	75 21                	jne    800d31 <strncmp+0x3d>
  800d10:	83 e8 01             	sub    $0x1,%eax
  800d13:	74 13                	je     800d28 <strncmp+0x34>
		n--, p++, q++;
  800d15:	83 c2 01             	add    $0x1,%edx
  800d18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d1b:	0f b6 1a             	movzbl (%edx),%ebx
  800d1e:	84 db                	test   %bl,%bl
  800d20:	74 0f                	je     800d31 <strncmp+0x3d>
  800d22:	3a 19                	cmp    (%ecx),%bl
  800d24:	74 ea                	je     800d10 <strncmp+0x1c>
  800d26:	eb 09                	jmp    800d31 <strncmp+0x3d>
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5d                   	pop    %ebp
  800d2f:	90                   	nop
  800d30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d31:	0f b6 02             	movzbl (%edx),%eax
  800d34:	0f b6 11             	movzbl (%ecx),%edx
  800d37:	29 d0                	sub    %edx,%eax
  800d39:	eb f2                	jmp    800d2d <strncmp+0x39>

00800d3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d45:	0f b6 10             	movzbl (%eax),%edx
  800d48:	84 d2                	test   %dl,%dl
  800d4a:	74 18                	je     800d64 <strchr+0x29>
		if (*s == c)
  800d4c:	38 ca                	cmp    %cl,%dl
  800d4e:	75 0a                	jne    800d5a <strchr+0x1f>
  800d50:	eb 17                	jmp    800d69 <strchr+0x2e>
  800d52:	38 ca                	cmp    %cl,%dl
  800d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d58:	74 0f                	je     800d69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d5a:	83 c0 01             	add    $0x1,%eax
  800d5d:	0f b6 10             	movzbl (%eax),%edx
  800d60:	84 d2                	test   %dl,%dl
  800d62:	75 ee                	jne    800d52 <strchr+0x17>
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d75:	0f b6 10             	movzbl (%eax),%edx
  800d78:	84 d2                	test   %dl,%dl
  800d7a:	74 18                	je     800d94 <strfind+0x29>
		if (*s == c)
  800d7c:	38 ca                	cmp    %cl,%dl
  800d7e:	75 0a                	jne    800d8a <strfind+0x1f>
  800d80:	eb 12                	jmp    800d94 <strfind+0x29>
  800d82:	38 ca                	cmp    %cl,%dl
  800d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d88:	74 0a                	je     800d94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d8a:	83 c0 01             	add    $0x1,%eax
  800d8d:	0f b6 10             	movzbl (%eax),%edx
  800d90:	84 d2                	test   %dl,%dl
  800d92:	75 ee                	jne    800d82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	89 1c 24             	mov    %ebx,(%esp)
  800d9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800da3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800da7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800daa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800db0:	85 c9                	test   %ecx,%ecx
  800db2:	74 30                	je     800de4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800db4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dba:	75 25                	jne    800de1 <memset+0x4b>
  800dbc:	f6 c1 03             	test   $0x3,%cl
  800dbf:	75 20                	jne    800de1 <memset+0x4b>
		c &= 0xFF;
  800dc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	c1 e3 08             	shl    $0x8,%ebx
  800dc9:	89 d6                	mov    %edx,%esi
  800dcb:	c1 e6 18             	shl    $0x18,%esi
  800dce:	89 d0                	mov    %edx,%eax
  800dd0:	c1 e0 10             	shl    $0x10,%eax
  800dd3:	09 f0                	or     %esi,%eax
  800dd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800dd7:	09 d8                	or     %ebx,%eax
  800dd9:	c1 e9 02             	shr    $0x2,%ecx
  800ddc:	fc                   	cld    
  800ddd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ddf:	eb 03                	jmp    800de4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800de1:	fc                   	cld    
  800de2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800de4:	89 f8                	mov    %edi,%eax
  800de6:	8b 1c 24             	mov    (%esp),%ebx
  800de9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ded:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800df1:	89 ec                	mov    %ebp,%esp
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	89 34 24             	mov    %esi,(%esp)
  800dfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800e08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800e0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800e0d:	39 c6                	cmp    %eax,%esi
  800e0f:	73 35                	jae    800e46 <memmove+0x51>
  800e11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e14:	39 d0                	cmp    %edx,%eax
  800e16:	73 2e                	jae    800e46 <memmove+0x51>
		s += n;
		d += n;
  800e18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e1a:	f6 c2 03             	test   $0x3,%dl
  800e1d:	75 1b                	jne    800e3a <memmove+0x45>
  800e1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e25:	75 13                	jne    800e3a <memmove+0x45>
  800e27:	f6 c1 03             	test   $0x3,%cl
  800e2a:	75 0e                	jne    800e3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800e2c:	83 ef 04             	sub    $0x4,%edi
  800e2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e32:	c1 e9 02             	shr    $0x2,%ecx
  800e35:	fd                   	std    
  800e36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e38:	eb 09                	jmp    800e43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e3a:	83 ef 01             	sub    $0x1,%edi
  800e3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e40:	fd                   	std    
  800e41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e44:	eb 20                	jmp    800e66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e4c:	75 15                	jne    800e63 <memmove+0x6e>
  800e4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e54:	75 0d                	jne    800e63 <memmove+0x6e>
  800e56:	f6 c1 03             	test   $0x3,%cl
  800e59:	75 08                	jne    800e63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e5b:	c1 e9 02             	shr    $0x2,%ecx
  800e5e:	fc                   	cld    
  800e5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e61:	eb 03                	jmp    800e66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e63:	fc                   	cld    
  800e64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e66:	8b 34 24             	mov    (%esp),%esi
  800e69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e6d:	89 ec                	mov    %ebp,%esp
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e77:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	89 04 24             	mov    %eax,(%esp)
  800e8b:	e8 65 ff ff ff       	call   800df5 <memmove>
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ea1:	85 c9                	test   %ecx,%ecx
  800ea3:	74 36                	je     800edb <memcmp+0x49>
		if (*s1 != *s2)
  800ea5:	0f b6 06             	movzbl (%esi),%eax
  800ea8:	0f b6 1f             	movzbl (%edi),%ebx
  800eab:	38 d8                	cmp    %bl,%al
  800ead:	74 20                	je     800ecf <memcmp+0x3d>
  800eaf:	eb 14                	jmp    800ec5 <memcmp+0x33>
  800eb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800eb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ebb:	83 c2 01             	add    $0x1,%edx
  800ebe:	83 e9 01             	sub    $0x1,%ecx
  800ec1:	38 d8                	cmp    %bl,%al
  800ec3:	74 12                	je     800ed7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ec5:	0f b6 c0             	movzbl %al,%eax
  800ec8:	0f b6 db             	movzbl %bl,%ebx
  800ecb:	29 d8                	sub    %ebx,%eax
  800ecd:	eb 11                	jmp    800ee0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ecf:	83 e9 01             	sub    $0x1,%ecx
  800ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed7:	85 c9                	test   %ecx,%ecx
  800ed9:	75 d6                	jne    800eb1 <memcmp+0x1f>
  800edb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ef0:	39 d0                	cmp    %edx,%eax
  800ef2:	73 15                	jae    800f09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ef4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ef8:	38 08                	cmp    %cl,(%eax)
  800efa:	75 06                	jne    800f02 <memfind+0x1d>
  800efc:	eb 0b                	jmp    800f09 <memfind+0x24>
  800efe:	38 08                	cmp    %cl,(%eax)
  800f00:	74 07                	je     800f09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f02:	83 c0 01             	add    $0x1,%eax
  800f05:	39 c2                	cmp    %eax,%edx
  800f07:	77 f5                	ja     800efe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	57                   	push   %edi
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	8b 55 08             	mov    0x8(%ebp),%edx
  800f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f1a:	0f b6 02             	movzbl (%edx),%eax
  800f1d:	3c 20                	cmp    $0x20,%al
  800f1f:	74 04                	je     800f25 <strtol+0x1a>
  800f21:	3c 09                	cmp    $0x9,%al
  800f23:	75 0e                	jne    800f33 <strtol+0x28>
		s++;
  800f25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f28:	0f b6 02             	movzbl (%edx),%eax
  800f2b:	3c 20                	cmp    $0x20,%al
  800f2d:	74 f6                	je     800f25 <strtol+0x1a>
  800f2f:	3c 09                	cmp    $0x9,%al
  800f31:	74 f2                	je     800f25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f33:	3c 2b                	cmp    $0x2b,%al
  800f35:	75 0c                	jne    800f43 <strtol+0x38>
		s++;
  800f37:	83 c2 01             	add    $0x1,%edx
  800f3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f41:	eb 15                	jmp    800f58 <strtol+0x4d>
	else if (*s == '-')
  800f43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f4a:	3c 2d                	cmp    $0x2d,%al
  800f4c:	75 0a                	jne    800f58 <strtol+0x4d>
		s++, neg = 1;
  800f4e:	83 c2 01             	add    $0x1,%edx
  800f51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f58:	85 db                	test   %ebx,%ebx
  800f5a:	0f 94 c0             	sete   %al
  800f5d:	74 05                	je     800f64 <strtol+0x59>
  800f5f:	83 fb 10             	cmp    $0x10,%ebx
  800f62:	75 18                	jne    800f7c <strtol+0x71>
  800f64:	80 3a 30             	cmpb   $0x30,(%edx)
  800f67:	75 13                	jne    800f7c <strtol+0x71>
  800f69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	75 0a                	jne    800f7c <strtol+0x71>
		s += 2, base = 16;
  800f72:	83 c2 02             	add    $0x2,%edx
  800f75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f7a:	eb 15                	jmp    800f91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f7c:	84 c0                	test   %al,%al
  800f7e:	66 90                	xchg   %ax,%ax
  800f80:	74 0f                	je     800f91 <strtol+0x86>
  800f82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f87:	80 3a 30             	cmpb   $0x30,(%edx)
  800f8a:	75 05                	jne    800f91 <strtol+0x86>
		s++, base = 8;
  800f8c:	83 c2 01             	add    $0x1,%edx
  800f8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
  800f96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f98:	0f b6 0a             	movzbl (%edx),%ecx
  800f9b:	89 cf                	mov    %ecx,%edi
  800f9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800fa0:	80 fb 09             	cmp    $0x9,%bl
  800fa3:	77 08                	ja     800fad <strtol+0xa2>
			dig = *s - '0';
  800fa5:	0f be c9             	movsbl %cl,%ecx
  800fa8:	83 e9 30             	sub    $0x30,%ecx
  800fab:	eb 1e                	jmp    800fcb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800fad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800fb0:	80 fb 19             	cmp    $0x19,%bl
  800fb3:	77 08                	ja     800fbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800fb5:	0f be c9             	movsbl %cl,%ecx
  800fb8:	83 e9 57             	sub    $0x57,%ecx
  800fbb:	eb 0e                	jmp    800fcb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800fbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800fc0:	80 fb 19             	cmp    $0x19,%bl
  800fc3:	77 15                	ja     800fda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800fc5:	0f be c9             	movsbl %cl,%ecx
  800fc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fcb:	39 f1                	cmp    %esi,%ecx
  800fcd:	7d 0b                	jge    800fda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800fcf:	83 c2 01             	add    $0x1,%edx
  800fd2:	0f af c6             	imul   %esi,%eax
  800fd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800fd8:	eb be                	jmp    800f98 <strtol+0x8d>
  800fda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800fdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fe0:	74 05                	je     800fe7 <strtol+0xdc>
		*endptr = (char *) s;
  800fe2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fe5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fe7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800feb:	74 04                	je     800ff1 <strtol+0xe6>
  800fed:	89 c8                	mov    %ecx,%eax
  800fef:	f7 d8                	neg    %eax
}
  800ff1:	83 c4 04             	add    $0x4,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    
  800ff9:	00 00                	add    %al,(%eax)
	...

00800ffc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	89 1c 24             	mov    %ebx,(%esp)
  801005:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801009:	ba 00 00 00 00       	mov    $0x0,%edx
  80100e:	b8 01 00 00 00       	mov    $0x1,%eax
  801013:	89 d1                	mov    %edx,%ecx
  801015:	89 d3                	mov    %edx,%ebx
  801017:	89 d7                	mov    %edx,%edi
  801019:	51                   	push   %ecx
  80101a:	52                   	push   %edx
  80101b:	53                   	push   %ebx
  80101c:	54                   	push   %esp
  80101d:	55                   	push   %ebp
  80101e:	56                   	push   %esi
  80101f:	57                   	push   %edi
  801020:	54                   	push   %esp
  801021:	5d                   	pop    %ebp
  801022:	8d 35 2a 10 80 00    	lea    0x80102a,%esi
  801028:	0f 34                	sysenter 
  80102a:	5f                   	pop    %edi
  80102b:	5e                   	pop    %esi
  80102c:	5d                   	pop    %ebp
  80102d:	5c                   	pop    %esp
  80102e:	5b                   	pop    %ebx
  80102f:	5a                   	pop    %edx
  801030:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801031:	8b 1c 24             	mov    (%esp),%ebx
  801034:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801038:	89 ec                	mov    %ebp,%esp
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	89 1c 24             	mov    %ebx,(%esp)
  801045:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801049:	b8 00 00 00 00       	mov    $0x0,%eax
  80104e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801051:	8b 55 08             	mov    0x8(%ebp),%edx
  801054:	89 c3                	mov    %eax,%ebx
  801056:	89 c7                	mov    %eax,%edi
  801058:	51                   	push   %ecx
  801059:	52                   	push   %edx
  80105a:	53                   	push   %ebx
  80105b:	54                   	push   %esp
  80105c:	55                   	push   %ebp
  80105d:	56                   	push   %esi
  80105e:	57                   	push   %edi
  80105f:	54                   	push   %esp
  801060:	5d                   	pop    %ebp
  801061:	8d 35 69 10 80 00    	lea    0x801069,%esi
  801067:	0f 34                	sysenter 
  801069:	5f                   	pop    %edi
  80106a:	5e                   	pop    %esi
  80106b:	5d                   	pop    %ebp
  80106c:	5c                   	pop    %esp
  80106d:	5b                   	pop    %ebx
  80106e:	5a                   	pop    %edx
  80106f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801070:	8b 1c 24             	mov    (%esp),%ebx
  801073:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801077:	89 ec                	mov    %ebp,%esp
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	89 1c 24             	mov    %ebx,(%esp)
  801084:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801088:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108d:	b8 13 00 00 00       	mov    $0x13,%eax
  801092:	8b 55 08             	mov    0x8(%ebp),%edx
  801095:	89 cb                	mov    %ecx,%ebx
  801097:	89 cf                	mov    %ecx,%edi
  801099:	51                   	push   %ecx
  80109a:	52                   	push   %edx
  80109b:	53                   	push   %ebx
  80109c:	54                   	push   %esp
  80109d:	55                   	push   %ebp
  80109e:	56                   	push   %esi
  80109f:	57                   	push   %edi
  8010a0:	54                   	push   %esp
  8010a1:	5d                   	pop    %ebp
  8010a2:	8d 35 aa 10 80 00    	lea    0x8010aa,%esi
  8010a8:	0f 34                	sysenter 
  8010aa:	5f                   	pop    %edi
  8010ab:	5e                   	pop    %esi
  8010ac:	5d                   	pop    %ebp
  8010ad:	5c                   	pop    %esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5a                   	pop    %edx
  8010b0:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  8010b1:	8b 1c 24             	mov    (%esp),%ebx
  8010b4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b8:	89 ec                	mov    %ebp,%esp
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	89 1c 24             	mov    %ebx,(%esp)
  8010c5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ce:	b8 12 00 00 00       	mov    $0x12,%eax
  8010d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d9:	89 df                	mov    %ebx,%edi
  8010db:	51                   	push   %ecx
  8010dc:	52                   	push   %edx
  8010dd:	53                   	push   %ebx
  8010de:	54                   	push   %esp
  8010df:	55                   	push   %ebp
  8010e0:	56                   	push   %esi
  8010e1:	57                   	push   %edi
  8010e2:	54                   	push   %esp
  8010e3:	5d                   	pop    %ebp
  8010e4:	8d 35 ec 10 80 00    	lea    0x8010ec,%esi
  8010ea:	0f 34                	sysenter 
  8010ec:	5f                   	pop    %edi
  8010ed:	5e                   	pop    %esi
  8010ee:	5d                   	pop    %ebp
  8010ef:	5c                   	pop    %esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5a                   	pop    %edx
  8010f2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8010f3:	8b 1c 24             	mov    (%esp),%ebx
  8010f6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010fa:	89 ec                	mov    %ebp,%esp
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	89 1c 24             	mov    %ebx,(%esp)
  801107:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80110b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801110:	b8 11 00 00 00       	mov    $0x11,%eax
  801115:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801118:	8b 55 08             	mov    0x8(%ebp),%edx
  80111b:	89 df                	mov    %ebx,%edi
  80111d:	51                   	push   %ecx
  80111e:	52                   	push   %edx
  80111f:	53                   	push   %ebx
  801120:	54                   	push   %esp
  801121:	55                   	push   %ebp
  801122:	56                   	push   %esi
  801123:	57                   	push   %edi
  801124:	54                   	push   %esp
  801125:	5d                   	pop    %ebp
  801126:	8d 35 2e 11 80 00    	lea    0x80112e,%esi
  80112c:	0f 34                	sysenter 
  80112e:	5f                   	pop    %edi
  80112f:	5e                   	pop    %esi
  801130:	5d                   	pop    %ebp
  801131:	5c                   	pop    %esp
  801132:	5b                   	pop    %ebx
  801133:	5a                   	pop    %edx
  801134:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801135:	8b 1c 24             	mov    (%esp),%ebx
  801138:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80113c:	89 ec                	mov    %ebp,%esp
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	89 1c 24             	mov    %ebx,(%esp)
  801149:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80114d:	b8 10 00 00 00       	mov    $0x10,%eax
  801152:	8b 7d 14             	mov    0x14(%ebp),%edi
  801155:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115b:	8b 55 08             	mov    0x8(%ebp),%edx
  80115e:	51                   	push   %ecx
  80115f:	52                   	push   %edx
  801160:	53                   	push   %ebx
  801161:	54                   	push   %esp
  801162:	55                   	push   %ebp
  801163:	56                   	push   %esi
  801164:	57                   	push   %edi
  801165:	54                   	push   %esp
  801166:	5d                   	pop    %ebp
  801167:	8d 35 6f 11 80 00    	lea    0x80116f,%esi
  80116d:	0f 34                	sysenter 
  80116f:	5f                   	pop    %edi
  801170:	5e                   	pop    %esi
  801171:	5d                   	pop    %ebp
  801172:	5c                   	pop    %esp
  801173:	5b                   	pop    %ebx
  801174:	5a                   	pop    %edx
  801175:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801176:	8b 1c 24             	mov    (%esp),%ebx
  801179:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80117d:	89 ec                	mov    %ebp,%esp
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	83 ec 28             	sub    $0x28,%esp
  801187:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80118a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	b8 0f 00 00 00       	mov    $0xf,%eax
  801197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119a:	8b 55 08             	mov    0x8(%ebp),%edx
  80119d:	89 df                	mov    %ebx,%edi
  80119f:	51                   	push   %ecx
  8011a0:	52                   	push   %edx
  8011a1:	53                   	push   %ebx
  8011a2:	54                   	push   %esp
  8011a3:	55                   	push   %ebp
  8011a4:	56                   	push   %esi
  8011a5:	57                   	push   %edi
  8011a6:	54                   	push   %esp
  8011a7:	5d                   	pop    %ebp
  8011a8:	8d 35 b0 11 80 00    	lea    0x8011b0,%esi
  8011ae:	0f 34                	sysenter 
  8011b0:	5f                   	pop    %edi
  8011b1:	5e                   	pop    %esi
  8011b2:	5d                   	pop    %ebp
  8011b3:	5c                   	pop    %esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5a                   	pop    %edx
  8011b6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	7e 28                	jle    8011e3 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bf:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8011c6:	00 
  8011c7:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  8011ce:	00 
  8011cf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011d6:	00 
  8011d7:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  8011de:	e8 d1 12 00 00       	call   8024b4 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8011e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e9:	89 ec                	mov    %ebp,%esp
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	89 1c 24             	mov    %ebx,(%esp)
  8011f6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ff:	b8 15 00 00 00       	mov    $0x15,%eax
  801204:	89 d1                	mov    %edx,%ecx
  801206:	89 d3                	mov    %edx,%ebx
  801208:	89 d7                	mov    %edx,%edi
  80120a:	51                   	push   %ecx
  80120b:	52                   	push   %edx
  80120c:	53                   	push   %ebx
  80120d:	54                   	push   %esp
  80120e:	55                   	push   %ebp
  80120f:	56                   	push   %esi
  801210:	57                   	push   %edi
  801211:	54                   	push   %esp
  801212:	5d                   	pop    %ebp
  801213:	8d 35 1b 12 80 00    	lea    0x80121b,%esi
  801219:	0f 34                	sysenter 
  80121b:	5f                   	pop    %edi
  80121c:	5e                   	pop    %esi
  80121d:	5d                   	pop    %ebp
  80121e:	5c                   	pop    %esp
  80121f:	5b                   	pop    %ebx
  801220:	5a                   	pop    %edx
  801221:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801222:	8b 1c 24             	mov    (%esp),%ebx
  801225:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801229:	89 ec                	mov    %ebp,%esp
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	89 1c 24             	mov    %ebx,(%esp)
  801236:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80123a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123f:	b8 14 00 00 00       	mov    $0x14,%eax
  801244:	8b 55 08             	mov    0x8(%ebp),%edx
  801247:	89 cb                	mov    %ecx,%ebx
  801249:	89 cf                	mov    %ecx,%edi
  80124b:	51                   	push   %ecx
  80124c:	52                   	push   %edx
  80124d:	53                   	push   %ebx
  80124e:	54                   	push   %esp
  80124f:	55                   	push   %ebp
  801250:	56                   	push   %esi
  801251:	57                   	push   %edi
  801252:	54                   	push   %esp
  801253:	5d                   	pop    %ebp
  801254:	8d 35 5c 12 80 00    	lea    0x80125c,%esi
  80125a:	0f 34                	sysenter 
  80125c:	5f                   	pop    %edi
  80125d:	5e                   	pop    %esi
  80125e:	5d                   	pop    %ebp
  80125f:	5c                   	pop    %esp
  801260:	5b                   	pop    %ebx
  801261:	5a                   	pop    %edx
  801262:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801263:	8b 1c 24             	mov    (%esp),%ebx
  801266:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80126a:	89 ec                	mov    %ebp,%esp
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	83 ec 28             	sub    $0x28,%esp
  801274:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801277:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80127a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80127f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801284:	8b 55 08             	mov    0x8(%ebp),%edx
  801287:	89 cb                	mov    %ecx,%ebx
  801289:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	7e 28                	jle    8012cf <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ab:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8012b2:	00 
  8012b3:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  8012ba:	00 
  8012bb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012c2:	00 
  8012c3:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  8012ca:	e8 e5 11 00 00       	call   8024b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012d5:	89 ec                	mov    %ebp,%esp
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	89 1c 24             	mov    %ebx,(%esp)
  8012e2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012e6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f7:	51                   	push   %ecx
  8012f8:	52                   	push   %edx
  8012f9:	53                   	push   %ebx
  8012fa:	54                   	push   %esp
  8012fb:	55                   	push   %ebp
  8012fc:	56                   	push   %esi
  8012fd:	57                   	push   %edi
  8012fe:	54                   	push   %esp
  8012ff:	5d                   	pop    %ebp
  801300:	8d 35 08 13 80 00    	lea    0x801308,%esi
  801306:	0f 34                	sysenter 
  801308:	5f                   	pop    %edi
  801309:	5e                   	pop    %esi
  80130a:	5d                   	pop    %ebp
  80130b:	5c                   	pop    %esp
  80130c:	5b                   	pop    %ebx
  80130d:	5a                   	pop    %edx
  80130e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80130f:	8b 1c 24             	mov    (%esp),%ebx
  801312:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801316:	89 ec                	mov    %ebp,%esp
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 28             	sub    $0x28,%esp
  801320:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801323:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801326:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801333:	8b 55 08             	mov    0x8(%ebp),%edx
  801336:	89 df                	mov    %ebx,%edi
  801338:	51                   	push   %ecx
  801339:	52                   	push   %edx
  80133a:	53                   	push   %ebx
  80133b:	54                   	push   %esp
  80133c:	55                   	push   %ebp
  80133d:	56                   	push   %esi
  80133e:	57                   	push   %edi
  80133f:	54                   	push   %esp
  801340:	5d                   	pop    %ebp
  801341:	8d 35 49 13 80 00    	lea    0x801349,%esi
  801347:	0f 34                	sysenter 
  801349:	5f                   	pop    %edi
  80134a:	5e                   	pop    %esi
  80134b:	5d                   	pop    %ebp
  80134c:	5c                   	pop    %esp
  80134d:	5b                   	pop    %ebx
  80134e:	5a                   	pop    %edx
  80134f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801350:	85 c0                	test   %eax,%eax
  801352:	7e 28                	jle    80137c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801354:	89 44 24 10          	mov    %eax,0x10(%esp)
  801358:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80135f:	00 
  801360:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  801367:	00 
  801368:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80136f:	00 
  801370:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  801377:	e8 38 11 00 00       	call   8024b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80137c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80137f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801382:	89 ec                	mov    %ebp,%esp
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	83 ec 28             	sub    $0x28,%esp
  80138c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80138f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801392:	bb 00 00 00 00       	mov    $0x0,%ebx
  801397:	b8 0a 00 00 00       	mov    $0xa,%eax
  80139c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139f:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a2:	89 df                	mov    %ebx,%edi
  8013a4:	51                   	push   %ecx
  8013a5:	52                   	push   %edx
  8013a6:	53                   	push   %ebx
  8013a7:	54                   	push   %esp
  8013a8:	55                   	push   %ebp
  8013a9:	56                   	push   %esi
  8013aa:	57                   	push   %edi
  8013ab:	54                   	push   %esp
  8013ac:	5d                   	pop    %ebp
  8013ad:	8d 35 b5 13 80 00    	lea    0x8013b5,%esi
  8013b3:	0f 34                	sysenter 
  8013b5:	5f                   	pop    %edi
  8013b6:	5e                   	pop    %esi
  8013b7:	5d                   	pop    %ebp
  8013b8:	5c                   	pop    %esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5a                   	pop    %edx
  8013bb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	7e 28                	jle    8013e8 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8013cb:	00 
  8013cc:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  8013d3:	00 
  8013d4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013db:	00 
  8013dc:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  8013e3:	e8 cc 10 00 00       	call   8024b4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8013e8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013eb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ee:	89 ec                	mov    %ebp,%esp
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 28             	sub    $0x28,%esp
  8013f8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013fb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801403:	b8 09 00 00 00       	mov    $0x9,%eax
  801408:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140b:	8b 55 08             	mov    0x8(%ebp),%edx
  80140e:	89 df                	mov    %ebx,%edi
  801410:	51                   	push   %ecx
  801411:	52                   	push   %edx
  801412:	53                   	push   %ebx
  801413:	54                   	push   %esp
  801414:	55                   	push   %ebp
  801415:	56                   	push   %esi
  801416:	57                   	push   %edi
  801417:	54                   	push   %esp
  801418:	5d                   	pop    %ebp
  801419:	8d 35 21 14 80 00    	lea    0x801421,%esi
  80141f:	0f 34                	sysenter 
  801421:	5f                   	pop    %edi
  801422:	5e                   	pop    %esi
  801423:	5d                   	pop    %ebp
  801424:	5c                   	pop    %esp
  801425:	5b                   	pop    %ebx
  801426:	5a                   	pop    %edx
  801427:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801428:	85 c0                	test   %eax,%eax
  80142a:	7e 28                	jle    801454 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80142c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801430:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801437:	00 
  801438:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  80143f:	00 
  801440:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801447:	00 
  801448:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  80144f:	e8 60 10 00 00       	call   8024b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801454:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801457:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80145a:	89 ec                	mov    %ebp,%esp
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 28             	sub    $0x28,%esp
  801464:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801467:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80146a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146f:	b8 07 00 00 00       	mov    $0x7,%eax
  801474:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801477:	8b 55 08             	mov    0x8(%ebp),%edx
  80147a:	89 df                	mov    %ebx,%edi
  80147c:	51                   	push   %ecx
  80147d:	52                   	push   %edx
  80147e:	53                   	push   %ebx
  80147f:	54                   	push   %esp
  801480:	55                   	push   %ebp
  801481:	56                   	push   %esi
  801482:	57                   	push   %edi
  801483:	54                   	push   %esp
  801484:	5d                   	pop    %ebp
  801485:	8d 35 8d 14 80 00    	lea    0x80148d,%esi
  80148b:	0f 34                	sysenter 
  80148d:	5f                   	pop    %edi
  80148e:	5e                   	pop    %esi
  80148f:	5d                   	pop    %ebp
  801490:	5c                   	pop    %esp
  801491:	5b                   	pop    %ebx
  801492:	5a                   	pop    %edx
  801493:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801494:	85 c0                	test   %eax,%eax
  801496:	7e 28                	jle    8014c0 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801498:	89 44 24 10          	mov    %eax,0x10(%esp)
  80149c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014a3:	00 
  8014a4:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  8014ab:	00 
  8014ac:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014b3:	00 
  8014b4:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  8014bb:	e8 f4 0f 00 00       	call   8024b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8014c0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014c3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014c6:	89 ec                	mov    %ebp,%esp
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  8014d6:	8b 7d 18             	mov    0x18(%ebp),%edi
  8014d9:	0b 7d 14             	or     0x14(%ebp),%edi
  8014dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ea:	51                   	push   %ecx
  8014eb:	52                   	push   %edx
  8014ec:	53                   	push   %ebx
  8014ed:	54                   	push   %esp
  8014ee:	55                   	push   %ebp
  8014ef:	56                   	push   %esi
  8014f0:	57                   	push   %edi
  8014f1:	54                   	push   %esp
  8014f2:	5d                   	pop    %ebp
  8014f3:	8d 35 fb 14 80 00    	lea    0x8014fb,%esi
  8014f9:	0f 34                	sysenter 
  8014fb:	5f                   	pop    %edi
  8014fc:	5e                   	pop    %esi
  8014fd:	5d                   	pop    %ebp
  8014fe:	5c                   	pop    %esp
  8014ff:	5b                   	pop    %ebx
  801500:	5a                   	pop    %edx
  801501:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801502:	85 c0                	test   %eax,%eax
  801504:	7e 28                	jle    80152e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801506:	89 44 24 10          	mov    %eax,0x10(%esp)
  80150a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801511:	00 
  801512:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  801519:	00 
  80151a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801521:	00 
  801522:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  801529:	e8 86 0f 00 00       	call   8024b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80152e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801531:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801534:	89 ec                	mov    %ebp,%esp
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    

00801538 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	83 ec 28             	sub    $0x28,%esp
  80153e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801541:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801544:	bf 00 00 00 00       	mov    $0x0,%edi
  801549:	b8 05 00 00 00       	mov    $0x5,%eax
  80154e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801551:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801554:	8b 55 08             	mov    0x8(%ebp),%edx
  801557:	51                   	push   %ecx
  801558:	52                   	push   %edx
  801559:	53                   	push   %ebx
  80155a:	54                   	push   %esp
  80155b:	55                   	push   %ebp
  80155c:	56                   	push   %esi
  80155d:	57                   	push   %edi
  80155e:	54                   	push   %esp
  80155f:	5d                   	pop    %ebp
  801560:	8d 35 68 15 80 00    	lea    0x801568,%esi
  801566:	0f 34                	sysenter 
  801568:	5f                   	pop    %edi
  801569:	5e                   	pop    %esi
  80156a:	5d                   	pop    %ebp
  80156b:	5c                   	pop    %esp
  80156c:	5b                   	pop    %ebx
  80156d:	5a                   	pop    %edx
  80156e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80156f:	85 c0                	test   %eax,%eax
  801571:	7e 28                	jle    80159b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801573:	89 44 24 10          	mov    %eax,0x10(%esp)
  801577:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80157e:	00 
  80157f:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  801586:	00 
  801587:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80158e:	00 
  80158f:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  801596:	e8 19 0f 00 00       	call   8024b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80159b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80159e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015a1:	89 ec                	mov    %ebp,%esp
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	89 1c 24             	mov    %ebx,(%esp)
  8015ae:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8015bc:	89 d1                	mov    %edx,%ecx
  8015be:	89 d3                	mov    %edx,%ebx
  8015c0:	89 d7                	mov    %edx,%edi
  8015c2:	51                   	push   %ecx
  8015c3:	52                   	push   %edx
  8015c4:	53                   	push   %ebx
  8015c5:	54                   	push   %esp
  8015c6:	55                   	push   %ebp
  8015c7:	56                   	push   %esi
  8015c8:	57                   	push   %edi
  8015c9:	54                   	push   %esp
  8015ca:	5d                   	pop    %ebp
  8015cb:	8d 35 d3 15 80 00    	lea    0x8015d3,%esi
  8015d1:	0f 34                	sysenter 
  8015d3:	5f                   	pop    %edi
  8015d4:	5e                   	pop    %esi
  8015d5:	5d                   	pop    %ebp
  8015d6:	5c                   	pop    %esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5a                   	pop    %edx
  8015d9:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015da:	8b 1c 24             	mov    (%esp),%ebx
  8015dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015e1:	89 ec                	mov    %ebp,%esp
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	89 1c 24             	mov    %ebx,(%esp)
  8015ee:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8015fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801602:	89 df                	mov    %ebx,%edi
  801604:	51                   	push   %ecx
  801605:	52                   	push   %edx
  801606:	53                   	push   %ebx
  801607:	54                   	push   %esp
  801608:	55                   	push   %ebp
  801609:	56                   	push   %esi
  80160a:	57                   	push   %edi
  80160b:	54                   	push   %esp
  80160c:	5d                   	pop    %ebp
  80160d:	8d 35 15 16 80 00    	lea    0x801615,%esi
  801613:	0f 34                	sysenter 
  801615:	5f                   	pop    %edi
  801616:	5e                   	pop    %esi
  801617:	5d                   	pop    %ebp
  801618:	5c                   	pop    %esp
  801619:	5b                   	pop    %ebx
  80161a:	5a                   	pop    %edx
  80161b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80161c:	8b 1c 24             	mov    (%esp),%ebx
  80161f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801623:	89 ec                	mov    %ebp,%esp
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	89 1c 24             	mov    %ebx,(%esp)
  801630:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	b8 02 00 00 00       	mov    $0x2,%eax
  80163e:	89 d1                	mov    %edx,%ecx
  801640:	89 d3                	mov    %edx,%ebx
  801642:	89 d7                	mov    %edx,%edi
  801644:	51                   	push   %ecx
  801645:	52                   	push   %edx
  801646:	53                   	push   %ebx
  801647:	54                   	push   %esp
  801648:	55                   	push   %ebp
  801649:	56                   	push   %esi
  80164a:	57                   	push   %edi
  80164b:	54                   	push   %esp
  80164c:	5d                   	pop    %ebp
  80164d:	8d 35 55 16 80 00    	lea    0x801655,%esi
  801653:	0f 34                	sysenter 
  801655:	5f                   	pop    %edi
  801656:	5e                   	pop    %esi
  801657:	5d                   	pop    %ebp
  801658:	5c                   	pop    %esp
  801659:	5b                   	pop    %ebx
  80165a:	5a                   	pop    %edx
  80165b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80165c:	8b 1c 24             	mov    (%esp),%ebx
  80165f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801663:	89 ec                	mov    %ebp,%esp
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	83 ec 28             	sub    $0x28,%esp
  80166d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801670:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801673:	b9 00 00 00 00       	mov    $0x0,%ecx
  801678:	b8 03 00 00 00       	mov    $0x3,%eax
  80167d:	8b 55 08             	mov    0x8(%ebp),%edx
  801680:	89 cb                	mov    %ecx,%ebx
  801682:	89 cf                	mov    %ecx,%edi
  801684:	51                   	push   %ecx
  801685:	52                   	push   %edx
  801686:	53                   	push   %ebx
  801687:	54                   	push   %esp
  801688:	55                   	push   %ebp
  801689:	56                   	push   %esi
  80168a:	57                   	push   %edi
  80168b:	54                   	push   %esp
  80168c:	5d                   	pop    %ebp
  80168d:	8d 35 95 16 80 00    	lea    0x801695,%esi
  801693:	0f 34                	sysenter 
  801695:	5f                   	pop    %edi
  801696:	5e                   	pop    %esi
  801697:	5d                   	pop    %ebp
  801698:	5c                   	pop    %esp
  801699:	5b                   	pop    %ebx
  80169a:	5a                   	pop    %edx
  80169b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80169c:	85 c0                	test   %eax,%eax
  80169e:	7e 28                	jle    8016c8 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016a4:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8016ab:	00 
  8016ac:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  8016b3:	00 
  8016b4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8016bb:	00 
  8016bc:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  8016c3:	e8 ec 0d 00 00       	call   8024b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8016c8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016ce:	89 ec                	mov    %ebp,%esp
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    
	...

008016e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016eb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	89 04 24             	mov    %eax,(%esp)
  8016fc:	e8 df ff ff ff       	call   8016e0 <fd2num>
  801701:	05 20 00 0d 00       	add    $0xd0020,%eax
  801706:	c1 e0 0c             	shl    $0xc,%eax
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	57                   	push   %edi
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
  801711:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801714:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801719:	a8 01                	test   $0x1,%al
  80171b:	74 36                	je     801753 <fd_alloc+0x48>
  80171d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801722:	a8 01                	test   $0x1,%al
  801724:	74 2d                	je     801753 <fd_alloc+0x48>
  801726:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80172b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801730:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801735:	89 c3                	mov    %eax,%ebx
  801737:	89 c2                	mov    %eax,%edx
  801739:	c1 ea 16             	shr    $0x16,%edx
  80173c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80173f:	f6 c2 01             	test   $0x1,%dl
  801742:	74 14                	je     801758 <fd_alloc+0x4d>
  801744:	89 c2                	mov    %eax,%edx
  801746:	c1 ea 0c             	shr    $0xc,%edx
  801749:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80174c:	f6 c2 01             	test   $0x1,%dl
  80174f:	75 10                	jne    801761 <fd_alloc+0x56>
  801751:	eb 05                	jmp    801758 <fd_alloc+0x4d>
  801753:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801758:	89 1f                	mov    %ebx,(%edi)
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80175f:	eb 17                	jmp    801778 <fd_alloc+0x6d>
  801761:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801766:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80176b:	75 c8                	jne    801735 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80176d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801773:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	83 f8 1f             	cmp    $0x1f,%eax
  801786:	77 36                	ja     8017be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801788:	05 00 00 0d 00       	add    $0xd0000,%eax
  80178d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801790:	89 c2                	mov    %eax,%edx
  801792:	c1 ea 16             	shr    $0x16,%edx
  801795:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80179c:	f6 c2 01             	test   $0x1,%dl
  80179f:	74 1d                	je     8017be <fd_lookup+0x41>
  8017a1:	89 c2                	mov    %eax,%edx
  8017a3:	c1 ea 0c             	shr    $0xc,%edx
  8017a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017ad:	f6 c2 01             	test   $0x1,%dl
  8017b0:	74 0c                	je     8017be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b5:	89 02                	mov    %eax,(%edx)
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8017bc:	eb 05                	jmp    8017c3 <fd_lookup+0x46>
  8017be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 a0 ff ff ff       	call   80177d <fd_lookup>
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 0e                	js     8017ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e7:	89 50 04             	mov    %edx,0x4(%eax)
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 10             	sub    $0x10,%esp
  8017f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8017ff:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801804:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801809:	be 88 31 80 00       	mov    $0x803188,%esi
		if (devtab[i]->dev_id == dev_id) {
  80180e:	39 08                	cmp    %ecx,(%eax)
  801810:	75 10                	jne    801822 <dev_lookup+0x31>
  801812:	eb 04                	jmp    801818 <dev_lookup+0x27>
  801814:	39 08                	cmp    %ecx,(%eax)
  801816:	75 0a                	jne    801822 <dev_lookup+0x31>
			*dev = devtab[i];
  801818:	89 03                	mov    %eax,(%ebx)
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80181f:	90                   	nop
  801820:	eb 31                	jmp    801853 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801822:	83 c2 01             	add    $0x1,%edx
  801825:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801828:	85 c0                	test   %eax,%eax
  80182a:	75 e8                	jne    801814 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80182c:	a1 18 50 80 00       	mov    0x805018,%eax
  801831:	8b 40 48             	mov    0x48(%eax),%eax
  801834:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	c7 04 24 0c 31 80 00 	movl   $0x80310c,(%esp)
  801843:	e8 95 ea ff ff       	call   8002dd <cprintf>
	*dev = 0;
  801848:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80184e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	5b                   	pop    %ebx
  801857:	5e                   	pop    %esi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	53                   	push   %ebx
  80185e:	83 ec 24             	sub    $0x24,%esp
  801861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	e8 07 ff ff ff       	call   80177d <fd_lookup>
  801876:	85 c0                	test   %eax,%eax
  801878:	78 53                	js     8018cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801884:	8b 00                	mov    (%eax),%eax
  801886:	89 04 24             	mov    %eax,(%esp)
  801889:	e8 63 ff ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 3b                	js     8018cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801892:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801897:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80189e:	74 2d                	je     8018cd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018aa:	00 00 00 
	stat->st_isdir = 0;
  8018ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b4:	00 00 00 
	stat->st_dev = dev;
  8018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018c7:	89 14 24             	mov    %edx,(%esp)
  8018ca:	ff 50 14             	call   *0x14(%eax)
}
  8018cd:	83 c4 24             	add    $0x24,%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 24             	sub    $0x24,%esp
  8018da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e4:	89 1c 24             	mov    %ebx,(%esp)
  8018e7:	e8 91 fe ff ff       	call   80177d <fd_lookup>
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 5f                	js     80194f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fa:	8b 00                	mov    (%eax),%eax
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	e8 ed fe ff ff       	call   8017f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801904:	85 c0                	test   %eax,%eax
  801906:	78 47                	js     80194f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801908:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80190b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80190f:	75 23                	jne    801934 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801911:	a1 18 50 80 00       	mov    0x805018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801916:	8b 40 48             	mov    0x48(%eax),%eax
  801919:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	c7 04 24 2c 31 80 00 	movl   $0x80312c,(%esp)
  801928:	e8 b0 e9 ff ff       	call   8002dd <cprintf>
  80192d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801932:	eb 1b                	jmp    80194f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801937:	8b 48 18             	mov    0x18(%eax),%ecx
  80193a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80193f:	85 c9                	test   %ecx,%ecx
  801941:	74 0c                	je     80194f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801943:	8b 45 0c             	mov    0xc(%ebp),%eax
  801946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194a:	89 14 24             	mov    %edx,(%esp)
  80194d:	ff d1                	call   *%ecx
}
  80194f:	83 c4 24             	add    $0x24,%esp
  801952:	5b                   	pop    %ebx
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	53                   	push   %ebx
  801959:	83 ec 24             	sub    $0x24,%esp
  80195c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801962:	89 44 24 04          	mov    %eax,0x4(%esp)
  801966:	89 1c 24             	mov    %ebx,(%esp)
  801969:	e8 0f fe ff ff       	call   80177d <fd_lookup>
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 66                	js     8019d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197c:	8b 00                	mov    (%eax),%eax
  80197e:	89 04 24             	mov    %eax,(%esp)
  801981:	e8 6b fe ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801986:	85 c0                	test   %eax,%eax
  801988:	78 4e                	js     8019d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80198a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80198d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801991:	75 23                	jne    8019b6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801993:	a1 18 50 80 00       	mov    0x805018,%eax
  801998:	8b 40 48             	mov    0x48(%eax),%eax
  80199b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80199f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a3:	c7 04 24 4d 31 80 00 	movl   $0x80314d,(%esp)
  8019aa:	e8 2e e9 ff ff       	call   8002dd <cprintf>
  8019af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019b4:	eb 22                	jmp    8019d8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8019bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c1:	85 c9                	test   %ecx,%ecx
  8019c3:	74 13                	je     8019d8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d3:	89 14 24             	mov    %edx,(%esp)
  8019d6:	ff d1                	call   *%ecx
}
  8019d8:	83 c4 24             	add    $0x24,%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 24             	sub    $0x24,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ef:	89 1c 24             	mov    %ebx,(%esp)
  8019f2:	e8 86 fd ff ff       	call   80177d <fd_lookup>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 6b                	js     801a66 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a05:	8b 00                	mov    (%eax),%eax
  801a07:	89 04 24             	mov    %eax,(%esp)
  801a0a:	e8 e2 fd ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 53                	js     801a66 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a13:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a16:	8b 42 08             	mov    0x8(%edx),%eax
  801a19:	83 e0 03             	and    $0x3,%eax
  801a1c:	83 f8 01             	cmp    $0x1,%eax
  801a1f:	75 23                	jne    801a44 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a21:	a1 18 50 80 00       	mov    0x805018,%eax
  801a26:	8b 40 48             	mov    0x48(%eax),%eax
  801a29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a31:	c7 04 24 6a 31 80 00 	movl   $0x80316a,(%esp)
  801a38:	e8 a0 e8 ff ff       	call   8002dd <cprintf>
  801a3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a42:	eb 22                	jmp    801a66 <read+0x88>
	}
	if (!dev->dev_read)
  801a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a47:	8b 48 08             	mov    0x8(%eax),%ecx
  801a4a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a4f:	85 c9                	test   %ecx,%ecx
  801a51:	74 13                	je     801a66 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a53:	8b 45 10             	mov    0x10(%ebp),%eax
  801a56:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a61:	89 14 24             	mov    %edx,(%esp)
  801a64:	ff d1                	call   *%ecx
}
  801a66:	83 c4 24             	add    $0x24,%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	57                   	push   %edi
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 1c             	sub    $0x1c,%esp
  801a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a78:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8a:	85 f6                	test   %esi,%esi
  801a8c:	74 29                	je     801ab7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a8e:	89 f0                	mov    %esi,%eax
  801a90:	29 d0                	sub    %edx,%eax
  801a92:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a96:	03 55 0c             	add    0xc(%ebp),%edx
  801a99:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a9d:	89 3c 24             	mov    %edi,(%esp)
  801aa0:	e8 39 ff ff ff       	call   8019de <read>
		if (m < 0)
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 0e                	js     801ab7 <readn+0x4b>
			return m;
		if (m == 0)
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	74 08                	je     801ab5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801aad:	01 c3                	add    %eax,%ebx
  801aaf:	89 da                	mov    %ebx,%edx
  801ab1:	39 f3                	cmp    %esi,%ebx
  801ab3:	72 d9                	jb     801a8e <readn+0x22>
  801ab5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801ab7:	83 c4 1c             	add    $0x1c,%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5f                   	pop    %edi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 20             	sub    $0x20,%esp
  801ac7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801aca:	89 34 24             	mov    %esi,(%esp)
  801acd:	e8 0e fc ff ff       	call   8016e0 <fd2num>
  801ad2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ad5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ad9:	89 04 24             	mov    %eax,(%esp)
  801adc:	e8 9c fc ff ff       	call   80177d <fd_lookup>
  801ae1:	89 c3                	mov    %eax,%ebx
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	78 05                	js     801aec <fd_close+0x2d>
  801ae7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801aea:	74 0c                	je     801af8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801aec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801af0:	19 c0                	sbb    %eax,%eax
  801af2:	f7 d0                	not    %eax
  801af4:	21 c3                	and    %eax,%ebx
  801af6:	eb 3d                	jmp    801b35 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801af8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aff:	8b 06                	mov    (%esi),%eax
  801b01:	89 04 24             	mov    %eax,(%esp)
  801b04:	e8 e8 fc ff ff       	call   8017f1 <dev_lookup>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 16                	js     801b25 <fd_close+0x66>
		if (dev->dev_close)
  801b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b12:	8b 40 10             	mov    0x10(%eax),%eax
  801b15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	74 07                	je     801b25 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801b1e:	89 34 24             	mov    %esi,(%esp)
  801b21:	ff d0                	call   *%eax
  801b23:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b25:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b30:	e8 29 f9 ff ff       	call   80145e <sys_page_unmap>
	return r;
}
  801b35:	89 d8                	mov    %ebx,%eax
  801b37:	83 c4 20             	add    $0x20,%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 27 fc ff ff       	call   80177d <fd_lookup>
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 13                	js     801b6d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b61:	00 
  801b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b65:	89 04 24             	mov    %eax,(%esp)
  801b68:	e8 52 ff ff ff       	call   801abf <fd_close>
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	83 ec 18             	sub    $0x18,%esp
  801b75:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b78:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b82:	00 
  801b83:	8b 45 08             	mov    0x8(%ebp),%eax
  801b86:	89 04 24             	mov    %eax,(%esp)
  801b89:	e8 79 03 00 00       	call   801f07 <open>
  801b8e:	89 c3                	mov    %eax,%ebx
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 1b                	js     801baf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9b:	89 1c 24             	mov    %ebx,(%esp)
  801b9e:	e8 b7 fc ff ff       	call   80185a <fstat>
  801ba3:	89 c6                	mov    %eax,%esi
	close(fd);
  801ba5:	89 1c 24             	mov    %ebx,(%esp)
  801ba8:	e8 91 ff ff ff       	call   801b3e <close>
  801bad:	89 f3                	mov    %esi,%ebx
	return r;
}
  801baf:	89 d8                	mov    %ebx,%eax
  801bb1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bb4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bb7:	89 ec                	mov    %ebp,%esp
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	53                   	push   %ebx
  801bbf:	83 ec 14             	sub    $0x14,%esp
  801bc2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801bc7:	89 1c 24             	mov    %ebx,(%esp)
  801bca:	e8 6f ff ff ff       	call   801b3e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801bcf:	83 c3 01             	add    $0x1,%ebx
  801bd2:	83 fb 20             	cmp    $0x20,%ebx
  801bd5:	75 f0                	jne    801bc7 <close_all+0xc>
		close(i);
}
  801bd7:	83 c4 14             	add    $0x14,%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 58             	sub    $0x58,%esp
  801be3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801be6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801be9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801bec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	89 04 24             	mov    %eax,(%esp)
  801bfc:	e8 7c fb ff ff       	call   80177d <fd_lookup>
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	85 c0                	test   %eax,%eax
  801c05:	0f 88 e0 00 00 00    	js     801ceb <dup+0x10e>
		return r;
	close(newfdnum);
  801c0b:	89 3c 24             	mov    %edi,(%esp)
  801c0e:	e8 2b ff ff ff       	call   801b3e <close>

	newfd = INDEX2FD(newfdnum);
  801c13:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801c19:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c1f:	89 04 24             	mov    %eax,(%esp)
  801c22:	e8 c9 fa ff ff       	call   8016f0 <fd2data>
  801c27:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c29:	89 34 24             	mov    %esi,(%esp)
  801c2c:	e8 bf fa ff ff       	call   8016f0 <fd2data>
  801c31:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801c34:	89 da                	mov    %ebx,%edx
  801c36:	89 d8                	mov    %ebx,%eax
  801c38:	c1 e8 16             	shr    $0x16,%eax
  801c3b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c42:	a8 01                	test   $0x1,%al
  801c44:	74 43                	je     801c89 <dup+0xac>
  801c46:	c1 ea 0c             	shr    $0xc,%edx
  801c49:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c50:	a8 01                	test   $0x1,%al
  801c52:	74 35                	je     801c89 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c54:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c5b:	25 07 0e 00 00       	and    $0xe07,%eax
  801c60:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c72:	00 
  801c73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7e:	e8 47 f8 ff ff       	call   8014ca <sys_page_map>
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 3f                	js     801cc8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8c:	89 c2                	mov    %eax,%edx
  801c8e:	c1 ea 0c             	shr    $0xc,%edx
  801c91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c98:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c9e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ca2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ca6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cad:	00 
  801cae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb9:	e8 0c f8 ff ff       	call   8014ca <sys_page_map>
  801cbe:	89 c3                	mov    %eax,%ebx
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 04                	js     801cc8 <dup+0xeb>
  801cc4:	89 fb                	mov    %edi,%ebx
  801cc6:	eb 23                	jmp    801ceb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801cc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ccc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd3:	e8 86 f7 ff ff       	call   80145e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801cd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce6:	e8 73 f7 ff ff       	call   80145e <sys_page_unmap>
	return r;
}
  801ceb:	89 d8                	mov    %ebx,%eax
  801ced:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cf0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cf3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cf6:	89 ec                	mov    %ebp,%esp
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    
	...

00801cfc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 18             	sub    $0x18,%esp
  801d02:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d05:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d0c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d13:	75 11                	jne    801d26 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d15:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d1c:	e8 ef 07 00 00       	call   802510 <ipc_find_env>
  801d21:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d26:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d2d:	00 
  801d2e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d35:	00 
  801d36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d3a:	a1 00 50 80 00       	mov    0x805000,%eax
  801d3f:	89 04 24             	mov    %eax,(%esp)
  801d42:	e8 14 08 00 00       	call   80255b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d4e:	00 
  801d4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5a:	e8 7a 08 00 00       	call   8025d9 <ipc_recv>
}
  801d5f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d62:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d65:	89 ec                	mov    %ebp,%esp
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	8b 40 0c             	mov    0xc(%eax),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d82:	ba 00 00 00 00       	mov    $0x0,%edx
  801d87:	b8 02 00 00 00       	mov    $0x2,%eax
  801d8c:	e8 6b ff ff ff       	call   801cfc <fsipc>
}
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d9f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801da4:	ba 00 00 00 00       	mov    $0x0,%edx
  801da9:	b8 06 00 00 00       	mov    $0x6,%eax
  801dae:	e8 49 ff ff ff       	call   801cfc <fsipc>
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc5:	e8 32 ff ff ff       	call   801cfc <fsipc>
}
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	53                   	push   %ebx
  801dd0:	83 ec 14             	sub    $0x14,%esp
  801dd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd9:	8b 40 0c             	mov    0xc(%eax),%eax
  801ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801de1:	ba 00 00 00 00       	mov    $0x0,%edx
  801de6:	b8 05 00 00 00       	mov    $0x5,%eax
  801deb:	e8 0c ff ff ff       	call   801cfc <fsipc>
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 2b                	js     801e1f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801df4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801dfb:	00 
  801dfc:	89 1c 24             	mov    %ebx,(%esp)
  801dff:	e8 06 ee ff ff       	call   800c0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e04:	a1 80 60 80 00       	mov    0x806080,%eax
  801e09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e0f:	a1 84 60 80 00       	mov    0x806084,%eax
  801e14:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e1f:	83 c4 14             	add    $0x14,%esp
  801e22:	5b                   	pop    %ebx
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 18             	sub    $0x18,%esp
  801e2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e33:	76 05                	jbe    801e3a <devfile_write+0x15>
  801e35:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e3d:	8b 52 0c             	mov    0xc(%edx),%edx
  801e40:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  801e46:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801e4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e56:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801e5d:	e8 93 ef ff ff       	call   800df5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801e62:	ba 00 00 00 00       	mov    $0x0,%edx
  801e67:	b8 04 00 00 00       	mov    $0x4,%eax
  801e6c:	e8 8b fe ff ff       	call   801cfc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	53                   	push   %ebx
  801e77:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e80:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  801e85:	8b 45 10             	mov    0x10(%ebp),%eax
  801e88:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  801e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e92:	b8 03 00 00 00       	mov    $0x3,%eax
  801e97:	e8 60 fe ff ff       	call   801cfc <fsipc>
  801e9c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 17                	js     801eb9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801ea2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea6:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ead:	00 
  801eae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb1:	89 04 24             	mov    %eax,(%esp)
  801eb4:	e8 3c ef ff ff       	call   800df5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801eb9:	89 d8                	mov    %ebx,%eax
  801ebb:	83 c4 14             	add    $0x14,%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	53                   	push   %ebx
  801ec5:	83 ec 14             	sub    $0x14,%esp
  801ec8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801ecb:	89 1c 24             	mov    %ebx,(%esp)
  801ece:	e8 ed ec ff ff       	call   800bc0 <strlen>
  801ed3:	89 c2                	mov    %eax,%edx
  801ed5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801eda:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ee0:	7f 1f                	jg     801f01 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801ee2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ee6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801eed:	e8 18 ed ff ff       	call   800c0a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801ef2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef7:	b8 07 00 00 00       	mov    $0x7,%eax
  801efc:	e8 fb fd ff ff       	call   801cfc <fsipc>
}
  801f01:	83 c4 14             	add    $0x14,%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    

00801f07 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 28             	sub    $0x28,%esp
  801f0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f10:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f13:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801f16:	89 34 24             	mov    %esi,(%esp)
  801f19:	e8 a2 ec ff ff       	call   800bc0 <strlen>
  801f1e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801f23:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f28:	7f 6d                	jg     801f97 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801f2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2d:	89 04 24             	mov    %eax,(%esp)
  801f30:	e8 d6 f7 ff ff       	call   80170b <fd_alloc>
  801f35:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 5c                	js     801f97 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801f43:	89 34 24             	mov    %esi,(%esp)
  801f46:	e8 75 ec ff ff       	call   800bc0 <strlen>
  801f4b:	83 c0 01             	add    $0x1,%eax
  801f4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f56:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f5d:	e8 93 ee ff ff       	call   800df5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801f62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f65:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6a:	e8 8d fd ff ff       	call   801cfc <fsipc>
  801f6f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801f71:	85 c0                	test   %eax,%eax
  801f73:	79 15                	jns    801f8a <open+0x83>
             fd_close(fd,0);
  801f75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f7c:	00 
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	89 04 24             	mov    %eax,(%esp)
  801f83:	e8 37 fb ff ff       	call   801abf <fd_close>
             return r;
  801f88:	eb 0d                	jmp    801f97 <open+0x90>
        }
        return fd2num(fd);
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	89 04 24             	mov    %eax,(%esp)
  801f90:	e8 4b f7 ff ff       	call   8016e0 <fd2num>
  801f95:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801f97:	89 d8                	mov    %ebx,%eax
  801f99:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f9c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f9f:	89 ec                	mov    %ebp,%esp
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    
	...

00801fb0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801fb6:	c7 44 24 04 94 31 80 	movl   $0x803194,0x4(%esp)
  801fbd:	00 
  801fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc1:	89 04 24             	mov    %eax,(%esp)
  801fc4:	e8 41 ec ff ff       	call   800c0a <strcpy>
	return 0;
}
  801fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 14             	sub    $0x14,%esp
  801fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801fda:	89 1c 24             	mov    %ebx,(%esp)
  801fdd:	e8 6a 06 00 00       	call   80264c <pageref>
  801fe2:	89 c2                	mov    %eax,%edx
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe9:	83 fa 01             	cmp    $0x1,%edx
  801fec:	75 0b                	jne    801ff9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801fee:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ff1:	89 04 24             	mov    %eax,(%esp)
  801ff4:	e8 b9 02 00 00       	call   8022b2 <nsipc_close>
	else
		return 0;
}
  801ff9:	83 c4 14             	add    $0x14,%esp
  801ffc:	5b                   	pop    %ebx
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802005:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80200c:	00 
  80200d:	8b 45 10             	mov    0x10(%ebp),%eax
  802010:	89 44 24 08          	mov    %eax,0x8(%esp)
  802014:	8b 45 0c             	mov    0xc(%ebp),%eax
  802017:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
  80201e:	8b 40 0c             	mov    0xc(%eax),%eax
  802021:	89 04 24             	mov    %eax,(%esp)
  802024:	e8 c5 02 00 00       	call   8022ee <nsipc_send>
}
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802031:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802038:	00 
  802039:	8b 45 10             	mov    0x10(%ebp),%eax
  80203c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802040:	8b 45 0c             	mov    0xc(%ebp),%eax
  802043:	89 44 24 04          	mov    %eax,0x4(%esp)
  802047:	8b 45 08             	mov    0x8(%ebp),%eax
  80204a:	8b 40 0c             	mov    0xc(%eax),%eax
  80204d:	89 04 24             	mov    %eax,(%esp)
  802050:	e8 0c 03 00 00       	call   802361 <nsipc_recv>
}
  802055:	c9                   	leave  
  802056:	c3                   	ret    

00802057 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	56                   	push   %esi
  80205b:	53                   	push   %ebx
  80205c:	83 ec 20             	sub    $0x20,%esp
  80205f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802064:	89 04 24             	mov    %eax,(%esp)
  802067:	e8 9f f6 ff ff       	call   80170b <fd_alloc>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 21                	js     802093 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802072:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802079:	00 
  80207a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802081:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802088:	e8 ab f4 ff ff       	call   801538 <sys_page_alloc>
  80208d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80208f:	85 c0                	test   %eax,%eax
  802091:	79 0a                	jns    80209d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802093:	89 34 24             	mov    %esi,(%esp)
  802096:	e8 17 02 00 00       	call   8022b2 <nsipc_close>
		return r;
  80209b:	eb 28                	jmp    8020c5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80209d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8020a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8020b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bb:	89 04 24             	mov    %eax,(%esp)
  8020be:	e8 1d f6 ff ff       	call   8016e0 <fd2num>
  8020c3:	89 c3                	mov    %eax,%ebx
}
  8020c5:	89 d8                	mov    %ebx,%eax
  8020c7:	83 c4 20             	add    $0x20,%esp
  8020ca:	5b                   	pop    %ebx
  8020cb:	5e                   	pop    %esi
  8020cc:	5d                   	pop    %ebp
  8020cd:	c3                   	ret    

008020ce <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 79 01 00 00       	call   802266 <nsipc_socket>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 05                	js     8020f6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8020f1:	e8 61 ff ff ff       	call   802057 <alloc_sockfd>
}
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8020fe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802101:	89 54 24 04          	mov    %edx,0x4(%esp)
  802105:	89 04 24             	mov    %eax,(%esp)
  802108:	e8 70 f6 ff ff       	call   80177d <fd_lookup>
  80210d:	85 c0                	test   %eax,%eax
  80210f:	78 15                	js     802126 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802111:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802114:	8b 0a                	mov    (%edx),%ecx
  802116:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80211b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802121:	75 03                	jne    802126 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802123:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80212e:	8b 45 08             	mov    0x8(%ebp),%eax
  802131:	e8 c2 ff ff ff       	call   8020f8 <fd2sockid>
  802136:	85 c0                	test   %eax,%eax
  802138:	78 0f                	js     802149 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80213a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80213d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802141:	89 04 24             	mov    %eax,(%esp)
  802144:	e8 47 01 00 00       	call   802290 <nsipc_listen>
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802151:	8b 45 08             	mov    0x8(%ebp),%eax
  802154:	e8 9f ff ff ff       	call   8020f8 <fd2sockid>
  802159:	85 c0                	test   %eax,%eax
  80215b:	78 16                	js     802173 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80215d:	8b 55 10             	mov    0x10(%ebp),%edx
  802160:	89 54 24 08          	mov    %edx,0x8(%esp)
  802164:	8b 55 0c             	mov    0xc(%ebp),%edx
  802167:	89 54 24 04          	mov    %edx,0x4(%esp)
  80216b:	89 04 24             	mov    %eax,(%esp)
  80216e:	e8 6e 02 00 00       	call   8023e1 <nsipc_connect>
}
  802173:	c9                   	leave  
  802174:	c3                   	ret    

00802175 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80217b:	8b 45 08             	mov    0x8(%ebp),%eax
  80217e:	e8 75 ff ff ff       	call   8020f8 <fd2sockid>
  802183:	85 c0                	test   %eax,%eax
  802185:	78 0f                	js     802196 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80218a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80218e:	89 04 24             	mov    %eax,(%esp)
  802191:	e8 36 01 00 00       	call   8022cc <nsipc_shutdown>
}
  802196:	c9                   	leave  
  802197:	c3                   	ret    

00802198 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80219e:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a1:	e8 52 ff ff ff       	call   8020f8 <fd2sockid>
  8021a6:	85 c0                	test   %eax,%eax
  8021a8:	78 16                	js     8021c0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8021aa:	8b 55 10             	mov    0x10(%ebp),%edx
  8021ad:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b8:	89 04 24             	mov    %eax,(%esp)
  8021bb:	e8 60 02 00 00       	call   802420 <nsipc_bind>
}
  8021c0:	c9                   	leave  
  8021c1:	c3                   	ret    

008021c2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cb:	e8 28 ff ff ff       	call   8020f8 <fd2sockid>
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 1f                	js     8021f3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8021d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8021d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e2:	89 04 24             	mov    %eax,(%esp)
  8021e5:	e8 75 02 00 00       	call   80245f <nsipc_accept>
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	78 05                	js     8021f3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8021ee:	e8 64 fe ff ff       	call   802057 <alloc_sockfd>
}
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    
	...

00802200 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	53                   	push   %ebx
  802204:	83 ec 14             	sub    $0x14,%esp
  802207:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802209:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802210:	75 11                	jne    802223 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802212:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802219:	e8 f2 02 00 00       	call   802510 <ipc_find_env>
  80221e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802223:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80222a:	00 
  80222b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802232:	00 
  802233:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802237:	a1 04 50 80 00       	mov    0x805004,%eax
  80223c:	89 04 24             	mov    %eax,(%esp)
  80223f:	e8 17 03 00 00       	call   80255b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802244:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80224b:	00 
  80224c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802253:	00 
  802254:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80225b:	e8 79 03 00 00       	call   8025d9 <ipc_recv>
}
  802260:	83 c4 14             	add    $0x14,%esp
  802263:	5b                   	pop    %ebx
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80226c:	8b 45 08             	mov    0x8(%ebp),%eax
  80226f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802274:	8b 45 0c             	mov    0xc(%ebp),%eax
  802277:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80227c:	8b 45 10             	mov    0x10(%ebp),%eax
  80227f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802284:	b8 09 00 00 00       	mov    $0x9,%eax
  802289:	e8 72 ff ff ff       	call   802200 <nsipc>
}
  80228e:	c9                   	leave  
  80228f:	c3                   	ret    

00802290 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802296:	8b 45 08             	mov    0x8(%ebp),%eax
  802299:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80229e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8022ab:	e8 50 ff ff ff       	call   802200 <nsipc>
}
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8022c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8022c5:	e8 36 ff ff ff       	call   802200 <nsipc>
}
  8022ca:	c9                   	leave  
  8022cb:	c3                   	ret    

008022cc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8022da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022dd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8022e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022e7:	e8 14 ff ff ff       	call   802200 <nsipc>
}
  8022ec:	c9                   	leave  
  8022ed:	c3                   	ret    

008022ee <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022ee:	55                   	push   %ebp
  8022ef:	89 e5                	mov    %esp,%ebp
  8022f1:	53                   	push   %ebx
  8022f2:	83 ec 14             	sub    $0x14,%esp
  8022f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802300:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802306:	7e 24                	jle    80232c <nsipc_send+0x3e>
  802308:	c7 44 24 0c a0 31 80 	movl   $0x8031a0,0xc(%esp)
  80230f:	00 
  802310:	c7 44 24 08 ac 31 80 	movl   $0x8031ac,0x8(%esp)
  802317:	00 
  802318:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80231f:	00 
  802320:	c7 04 24 c1 31 80 00 	movl   $0x8031c1,(%esp)
  802327:	e8 88 01 00 00       	call   8024b4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80232c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802330:	8b 45 0c             	mov    0xc(%ebp),%eax
  802333:	89 44 24 04          	mov    %eax,0x4(%esp)
  802337:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80233e:	e8 b2 ea ff ff       	call   800df5 <memmove>
	nsipcbuf.send.req_size = size;
  802343:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802349:	8b 45 14             	mov    0x14(%ebp),%eax
  80234c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802351:	b8 08 00 00 00       	mov    $0x8,%eax
  802356:	e8 a5 fe ff ff       	call   802200 <nsipc>
}
  80235b:	83 c4 14             	add    $0x14,%esp
  80235e:	5b                   	pop    %ebx
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    

00802361 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	56                   	push   %esi
  802365:	53                   	push   %ebx
  802366:	83 ec 10             	sub    $0x10,%esp
  802369:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80236c:	8b 45 08             	mov    0x8(%ebp),%eax
  80236f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802374:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80237a:	8b 45 14             	mov    0x14(%ebp),%eax
  80237d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802382:	b8 07 00 00 00       	mov    $0x7,%eax
  802387:	e8 74 fe ff ff       	call   802200 <nsipc>
  80238c:	89 c3                	mov    %eax,%ebx
  80238e:	85 c0                	test   %eax,%eax
  802390:	78 46                	js     8023d8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802392:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802397:	7f 04                	jg     80239d <nsipc_recv+0x3c>
  802399:	39 c6                	cmp    %eax,%esi
  80239b:	7d 24                	jge    8023c1 <nsipc_recv+0x60>
  80239d:	c7 44 24 0c cd 31 80 	movl   $0x8031cd,0xc(%esp)
  8023a4:	00 
  8023a5:	c7 44 24 08 ac 31 80 	movl   $0x8031ac,0x8(%esp)
  8023ac:	00 
  8023ad:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8023b4:	00 
  8023b5:	c7 04 24 c1 31 80 00 	movl   $0x8031c1,(%esp)
  8023bc:	e8 f3 00 00 00       	call   8024b4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023c5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8023cc:	00 
  8023cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d0:	89 04 24             	mov    %eax,(%esp)
  8023d3:	e8 1d ea ff ff       	call   800df5 <memmove>
	}

	return r;
}
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    

008023e1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	53                   	push   %ebx
  8023e5:	83 ec 14             	sub    $0x14,%esp
  8023e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8023eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ee:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8023f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023fe:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802405:	e8 eb e9 ff ff       	call   800df5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80240a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802410:	b8 05 00 00 00       	mov    $0x5,%eax
  802415:	e8 e6 fd ff ff       	call   802200 <nsipc>
}
  80241a:	83 c4 14             	add    $0x14,%esp
  80241d:	5b                   	pop    %ebx
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    

00802420 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	53                   	push   %ebx
  802424:	83 ec 14             	sub    $0x14,%esp
  802427:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80242a:	8b 45 08             	mov    0x8(%ebp),%eax
  80242d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802432:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802436:	8b 45 0c             	mov    0xc(%ebp),%eax
  802439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80243d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802444:	e8 ac e9 ff ff       	call   800df5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802449:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80244f:	b8 02 00 00 00       	mov    $0x2,%eax
  802454:	e8 a7 fd ff ff       	call   802200 <nsipc>
}
  802459:	83 c4 14             	add    $0x14,%esp
  80245c:	5b                   	pop    %ebx
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    

0080245f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	83 ec 18             	sub    $0x18,%esp
  802465:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802468:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80246b:	8b 45 08             	mov    0x8(%ebp),%eax
  80246e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802473:	b8 01 00 00 00       	mov    $0x1,%eax
  802478:	e8 83 fd ff ff       	call   802200 <nsipc>
  80247d:	89 c3                	mov    %eax,%ebx
  80247f:	85 c0                	test   %eax,%eax
  802481:	78 25                	js     8024a8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802483:	be 10 70 80 00       	mov    $0x807010,%esi
  802488:	8b 06                	mov    (%esi),%eax
  80248a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80248e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802495:	00 
  802496:	8b 45 0c             	mov    0xc(%ebp),%eax
  802499:	89 04 24             	mov    %eax,(%esp)
  80249c:	e8 54 e9 ff ff       	call   800df5 <memmove>
		*addrlen = ret->ret_addrlen;
  8024a1:	8b 16                	mov    (%esi),%edx
  8024a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8024a6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8024a8:	89 d8                	mov    %ebx,%eax
  8024aa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8024ad:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8024b0:	89 ec                	mov    %ebp,%esp
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    

008024b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
  8024b7:	56                   	push   %esi
  8024b8:	53                   	push   %ebx
  8024b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8024bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8024bf:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8024c5:	e8 5d f1 ff ff       	call   801627 <sys_getenvid>
  8024ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8024d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e0:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  8024e7:	e8 f1 dd ff ff       	call   8002dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8024ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8024f3:	89 04 24             	mov    %eax,(%esp)
  8024f6:	e8 81 dd ff ff       	call   80027c <vcprintf>
	cprintf("\n");
  8024fb:	c7 04 24 55 2c 80 00 	movl   $0x802c55,(%esp)
  802502:	e8 d6 dd ff ff       	call   8002dd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802507:	cc                   	int3   
  802508:	eb fd                	jmp    802507 <_panic+0x53>
  80250a:	00 00                	add    %al,(%eax)
  80250c:	00 00                	add    %al,(%eax)
	...

00802510 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802516:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80251c:	b8 01 00 00 00       	mov    $0x1,%eax
  802521:	39 ca                	cmp    %ecx,%edx
  802523:	75 04                	jne    802529 <ipc_find_env+0x19>
  802525:	b0 00                	mov    $0x0,%al
  802527:	eb 12                	jmp    80253b <ipc_find_env+0x2b>
  802529:	89 c2                	mov    %eax,%edx
  80252b:	c1 e2 07             	shl    $0x7,%edx
  80252e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802535:	8b 12                	mov    (%edx),%edx
  802537:	39 ca                	cmp    %ecx,%edx
  802539:	75 10                	jne    80254b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80253b:	89 c2                	mov    %eax,%edx
  80253d:	c1 e2 07             	shl    $0x7,%edx
  802540:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802547:	8b 00                	mov    (%eax),%eax
  802549:	eb 0e                	jmp    802559 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80254b:	83 c0 01             	add    $0x1,%eax
  80254e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802553:	75 d4                	jne    802529 <ipc_find_env+0x19>
  802555:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802559:	5d                   	pop    %ebp
  80255a:	c3                   	ret    

0080255b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80255b:	55                   	push   %ebp
  80255c:	89 e5                	mov    %esp,%ebp
  80255e:	57                   	push   %edi
  80255f:	56                   	push   %esi
  802560:	53                   	push   %ebx
  802561:	83 ec 1c             	sub    $0x1c,%esp
  802564:	8b 75 08             	mov    0x8(%ebp),%esi
  802567:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80256a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80256d:	85 db                	test   %ebx,%ebx
  80256f:	74 19                	je     80258a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802571:	8b 45 14             	mov    0x14(%ebp),%eax
  802574:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802578:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80257c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802580:	89 34 24             	mov    %esi,(%esp)
  802583:	e8 51 ed ff ff       	call   8012d9 <sys_ipc_try_send>
  802588:	eb 1b                	jmp    8025a5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80258a:	8b 45 14             	mov    0x14(%ebp),%eax
  80258d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802591:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802598:	ee 
  802599:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80259d:	89 34 24             	mov    %esi,(%esp)
  8025a0:	e8 34 ed ff ff       	call   8012d9 <sys_ipc_try_send>
           if(ret == 0)
  8025a5:	85 c0                	test   %eax,%eax
  8025a7:	74 28                	je     8025d1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8025a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025ac:	74 1c                	je     8025ca <ipc_send+0x6f>
              panic("ipc send error");
  8025ae:	c7 44 24 08 08 32 80 	movl   $0x803208,0x8(%esp)
  8025b5:	00 
  8025b6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8025bd:	00 
  8025be:	c7 04 24 17 32 80 00 	movl   $0x803217,(%esp)
  8025c5:	e8 ea fe ff ff       	call   8024b4 <_panic>
           sys_yield();
  8025ca:	e8 d6 ef ff ff       	call   8015a5 <sys_yield>
        }
  8025cf:	eb 9c                	jmp    80256d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8025d1:	83 c4 1c             	add    $0x1c,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    

008025d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025d9:	55                   	push   %ebp
  8025da:	89 e5                	mov    %esp,%ebp
  8025dc:	56                   	push   %esi
  8025dd:	53                   	push   %ebx
  8025de:	83 ec 10             	sub    $0x10,%esp
  8025e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8025e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8025ea:	85 c0                	test   %eax,%eax
  8025ec:	75 0e                	jne    8025fc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8025ee:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8025f5:	e8 74 ec ff ff       	call   80126e <sys_ipc_recv>
  8025fa:	eb 08                	jmp    802604 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8025fc:	89 04 24             	mov    %eax,(%esp)
  8025ff:	e8 6a ec ff ff       	call   80126e <sys_ipc_recv>
        if(ret == 0){
  802604:	85 c0                	test   %eax,%eax
  802606:	75 26                	jne    80262e <ipc_recv+0x55>
           if(from_env_store)
  802608:	85 f6                	test   %esi,%esi
  80260a:	74 0a                	je     802616 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80260c:	a1 18 50 80 00       	mov    0x805018,%eax
  802611:	8b 40 78             	mov    0x78(%eax),%eax
  802614:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802616:	85 db                	test   %ebx,%ebx
  802618:	74 0a                	je     802624 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80261a:	a1 18 50 80 00       	mov    0x805018,%eax
  80261f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802622:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802624:	a1 18 50 80 00       	mov    0x805018,%eax
  802629:	8b 40 74             	mov    0x74(%eax),%eax
  80262c:	eb 14                	jmp    802642 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80262e:	85 f6                	test   %esi,%esi
  802630:	74 06                	je     802638 <ipc_recv+0x5f>
              *from_env_store = 0;
  802632:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802638:	85 db                	test   %ebx,%ebx
  80263a:	74 06                	je     802642 <ipc_recv+0x69>
              *perm_store = 0;
  80263c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802642:	83 c4 10             	add    $0x10,%esp
  802645:	5b                   	pop    %ebx
  802646:	5e                   	pop    %esi
  802647:	5d                   	pop    %ebp
  802648:	c3                   	ret    
  802649:	00 00                	add    %al,(%eax)
	...

0080264c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80264c:	55                   	push   %ebp
  80264d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80264f:	8b 45 08             	mov    0x8(%ebp),%eax
  802652:	89 c2                	mov    %eax,%edx
  802654:	c1 ea 16             	shr    $0x16,%edx
  802657:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80265e:	f6 c2 01             	test   $0x1,%dl
  802661:	74 20                	je     802683 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802663:	c1 e8 0c             	shr    $0xc,%eax
  802666:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80266d:	a8 01                	test   $0x1,%al
  80266f:	74 12                	je     802683 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802671:	c1 e8 0c             	shr    $0xc,%eax
  802674:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802679:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80267e:	0f b7 c0             	movzwl %ax,%eax
  802681:	eb 05                	jmp    802688 <pageref+0x3c>
  802683:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802688:	5d                   	pop    %ebp
  802689:	c3                   	ret    
  80268a:	00 00                	add    %al,(%eax)
  80268c:	00 00                	add    %al,(%eax)
	...

00802690 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802690:	55                   	push   %ebp
  802691:	89 e5                	mov    %esp,%ebp
  802693:	57                   	push   %edi
  802694:	56                   	push   %esi
  802695:	53                   	push   %ebx
  802696:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802699:	8b 45 08             	mov    0x8(%ebp),%eax
  80269c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80269f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8026a5:	8d 45 f3             	lea    -0xd(%ebp),%eax
  8026a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8026ab:	b9 08 50 80 00       	mov    $0x805008,%ecx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8026b0:	ba cd ff ff ff       	mov    $0xffffffcd,%edx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8026b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026b8:	0f b6 18             	movzbl (%eax),%ebx
  8026bb:	be 00 00 00 00       	mov    $0x0,%esi
  8026c0:	89 f0                	mov    %esi,%eax
  8026c2:	89 ce                	mov    %ecx,%esi
  8026c4:	89 c1                	mov    %eax,%ecx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8026c6:	89 d8                	mov    %ebx,%eax
  8026c8:	f6 e2                	mul    %dl
  8026ca:	66 c1 e8 08          	shr    $0x8,%ax
  8026ce:	c0 e8 03             	shr    $0x3,%al
  8026d1:	89 c7                	mov    %eax,%edi
  8026d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8026d6:	01 c0                	add    %eax,%eax
  8026d8:	28 c3                	sub    %al,%bl
  8026da:	89 d8                	mov    %ebx,%eax
      *ap /= (u8_t)10;
  8026dc:	89 fb                	mov    %edi,%ebx
      inv[i++] = '0' + rem;
  8026de:	0f b6 f9             	movzbl %cl,%edi
  8026e1:	83 c0 30             	add    $0x30,%eax
  8026e4:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
  8026e8:	83 c1 01             	add    $0x1,%ecx
    } while(*ap);
  8026eb:	84 db                	test   %bl,%bl
  8026ed:	75 d7                	jne    8026c6 <inet_ntoa+0x36>
  8026ef:	89 c8                	mov    %ecx,%eax
  8026f1:	89 f1                	mov    %esi,%ecx
  8026f3:	89 c6                	mov    %eax,%esi
  8026f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026f8:	88 18                	mov    %bl,(%eax)
    while(i--)
  8026fa:	89 f0                	mov    %esi,%eax
  8026fc:	84 c0                	test   %al,%al
  8026fe:	74 2c                	je     80272c <inet_ntoa+0x9c>
  802700:	8d 5e ff             	lea    -0x1(%esi),%ebx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802703:	0f b6 c3             	movzbl %bl,%eax
  802706:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802709:	8d 7c 01 01          	lea    0x1(%ecx,%eax,1),%edi
  80270d:	89 c8                	mov    %ecx,%eax
  80270f:	89 ce                	mov    %ecx,%esi
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  802711:	0f b6 cb             	movzbl %bl,%ecx
  802714:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  802719:	88 08                	mov    %cl,(%eax)
  80271b:	83 c0 01             	add    $0x1,%eax
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80271e:	83 eb 01             	sub    $0x1,%ebx
  802721:	39 f8                	cmp    %edi,%eax
  802723:	75 ec                	jne    802711 <inet_ntoa+0x81>
  802725:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802728:	8d 4c 06 01          	lea    0x1(%esi,%eax,1),%ecx
      *rp++ = inv[i];
    *rp++ = '.';
  80272c:	c6 01 2e             	movb   $0x2e,(%ecx)
  80272f:	83 c1 01             	add    $0x1,%ecx
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802732:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802735:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802738:	74 09                	je     802743 <inet_ntoa+0xb3>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  80273a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80273e:	e9 72 ff ff ff       	jmp    8026b5 <inet_ntoa+0x25>
  }
  *--rp = 0;
  802743:	c6 41 ff 00          	movb   $0x0,-0x1(%ecx)
  return str;
}
  802747:	b8 08 50 80 00       	mov    $0x805008,%eax
  80274c:	83 c4 1c             	add    $0x1c,%esp
  80274f:	5b                   	pop    %ebx
  802750:	5e                   	pop    %esi
  802751:	5f                   	pop    %edi
  802752:	5d                   	pop    %ebp
  802753:	c3                   	ret    

00802754 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  802754:	55                   	push   %ebp
  802755:	89 e5                	mov    %esp,%ebp
  802757:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80275b:	66 c1 c0 08          	rol    $0x8,%ax
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}
  80275f:	5d                   	pop    %ebp
  802760:	c3                   	ret    

00802761 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802761:	55                   	push   %ebp
  802762:	89 e5                	mov    %esp,%ebp
  802764:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  802767:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80276b:	89 04 24             	mov    %eax,(%esp)
  80276e:	e8 e1 ff ff ff       	call   802754 <htons>
}
  802773:	c9                   	leave  
  802774:	c3                   	ret    

00802775 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  802775:	55                   	push   %ebp
  802776:	89 e5                	mov    %esp,%ebp
  802778:	8b 55 08             	mov    0x8(%ebp),%edx
  80277b:	89 d1                	mov    %edx,%ecx
  80277d:	c1 e9 18             	shr    $0x18,%ecx
  802780:	89 d0                	mov    %edx,%eax
  802782:	c1 e0 18             	shl    $0x18,%eax
  802785:	09 c8                	or     %ecx,%eax
  802787:	89 d1                	mov    %edx,%ecx
  802789:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  80278f:	c1 e1 08             	shl    $0x8,%ecx
  802792:	09 c8                	or     %ecx,%eax
  802794:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80279a:	c1 ea 08             	shr    $0x8,%edx
  80279d:	09 d0                	or     %edx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  80279f:	5d                   	pop    %ebp
  8027a0:	c3                   	ret    

008027a1 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8027a1:	55                   	push   %ebp
  8027a2:	89 e5                	mov    %esp,%ebp
  8027a4:	57                   	push   %edi
  8027a5:	56                   	push   %esi
  8027a6:	53                   	push   %ebx
  8027a7:	83 ec 28             	sub    $0x28,%esp
  8027aa:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8027ad:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8027b0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8027b3:	80 f9 09             	cmp    $0x9,%cl
  8027b6:	0f 87 af 01 00 00    	ja     80296b <inet_aton+0x1ca>
  8027bc:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8027bf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8027c2:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8027c5:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  8027c8:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  8027cf:	83 fa 30             	cmp    $0x30,%edx
  8027d2:	75 24                	jne    8027f8 <inet_aton+0x57>
      c = *++cp;
  8027d4:	83 c0 01             	add    $0x1,%eax
  8027d7:	0f be 10             	movsbl (%eax),%edx
      if (c == 'x' || c == 'X') {
  8027da:	83 fa 78             	cmp    $0x78,%edx
  8027dd:	74 0c                	je     8027eb <inet_aton+0x4a>
  8027df:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  8027e6:	83 fa 58             	cmp    $0x58,%edx
  8027e9:	75 0d                	jne    8027f8 <inet_aton+0x57>
        base = 16;
        c = *++cp;
  8027eb:	83 c0 01             	add    $0x1,%eax
  8027ee:	0f be 10             	movsbl (%eax),%edx
  8027f1:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  8027f8:	83 c0 01             	add    $0x1,%eax
  8027fb:	be 00 00 00 00       	mov    $0x0,%esi
  802800:	eb 03                	jmp    802805 <inet_aton+0x64>
  802802:	83 c0 01             	add    $0x1,%eax
  802805:	8d 78 ff             	lea    -0x1(%eax),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  802808:	89 d1                	mov    %edx,%ecx
  80280a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80280d:	80 fb 09             	cmp    $0x9,%bl
  802810:	77 0d                	ja     80281f <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  802812:	0f af 75 e0          	imul   -0x20(%ebp),%esi
  802816:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  80281a:	0f be 10             	movsbl (%eax),%edx
  80281d:	eb e3                	jmp    802802 <inet_aton+0x61>
      } else if (base == 16 && isxdigit(c)) {
  80281f:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  802823:	75 2b                	jne    802850 <inet_aton+0xaf>
  802825:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802828:	88 5d d3             	mov    %bl,-0x2d(%ebp)
  80282b:	80 fb 05             	cmp    $0x5,%bl
  80282e:	76 08                	jbe    802838 <inet_aton+0x97>
  802830:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802833:	80 fb 05             	cmp    $0x5,%bl
  802836:	77 18                	ja     802850 <inet_aton+0xaf>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802838:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80283c:	19 c9                	sbb    %ecx,%ecx
  80283e:	83 e1 20             	and    $0x20,%ecx
  802841:	c1 e6 04             	shl    $0x4,%esi
  802844:	29 ca                	sub    %ecx,%edx
  802846:	8d 52 c9             	lea    -0x37(%edx),%edx
  802849:	09 d6                	or     %edx,%esi
        c = *++cp;
  80284b:	0f be 10             	movsbl (%eax),%edx
  80284e:	eb b2                	jmp    802802 <inet_aton+0x61>
      } else
        break;
    }
    if (c == '.') {
  802850:	83 fa 2e             	cmp    $0x2e,%edx
  802853:	75 2c                	jne    802881 <inet_aton+0xe0>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802855:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802858:	39 55 d8             	cmp    %edx,-0x28(%ebp)
  80285b:	0f 83 0a 01 00 00    	jae    80296b <inet_aton+0x1ca>
        return (0);
      *pp++ = val;
  802861:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802864:	89 31                	mov    %esi,(%ecx)
      c = *++cp;
  802866:	8d 47 01             	lea    0x1(%edi),%eax
  802869:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80286c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80286f:	80 f9 09             	cmp    $0x9,%cl
  802872:	0f 87 f3 00 00 00    	ja     80296b <inet_aton+0x1ca>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  802878:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  80287c:	e9 47 ff ff ff       	jmp    8027c8 <inet_aton+0x27>
  802881:	89 f3                	mov    %esi,%ebx
  802883:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  802885:	85 d2                	test   %edx,%edx
  802887:	74 37                	je     8028c0 <inet_aton+0x11f>
  802889:	80 f9 1f             	cmp    $0x1f,%cl
  80288c:	0f 86 d9 00 00 00    	jbe    80296b <inet_aton+0x1ca>
  802892:	84 d2                	test   %dl,%dl
  802894:	0f 88 d1 00 00 00    	js     80296b <inet_aton+0x1ca>
  80289a:	83 fa 20             	cmp    $0x20,%edx
  80289d:	8d 76 00             	lea    0x0(%esi),%esi
  8028a0:	74 1e                	je     8028c0 <inet_aton+0x11f>
  8028a2:	83 fa 0c             	cmp    $0xc,%edx
  8028a5:	74 19                	je     8028c0 <inet_aton+0x11f>
  8028a7:	83 fa 0a             	cmp    $0xa,%edx
  8028aa:	74 14                	je     8028c0 <inet_aton+0x11f>
  8028ac:	83 fa 0d             	cmp    $0xd,%edx
  8028af:	90                   	nop
  8028b0:	74 0e                	je     8028c0 <inet_aton+0x11f>
  8028b2:	83 fa 09             	cmp    $0x9,%edx
  8028b5:	74 09                	je     8028c0 <inet_aton+0x11f>
  8028b7:	83 fa 0b             	cmp    $0xb,%edx
  8028ba:	0f 85 ab 00 00 00    	jne    80296b <inet_aton+0x1ca>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8028c0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8028c3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8028c6:	29 d1                	sub    %edx,%ecx
  8028c8:	89 ca                	mov    %ecx,%edx
  8028ca:	c1 fa 02             	sar    $0x2,%edx
  8028cd:	83 c2 01             	add    $0x1,%edx
  8028d0:	83 fa 02             	cmp    $0x2,%edx
  8028d3:	74 2d                	je     802902 <inet_aton+0x161>
  8028d5:	83 fa 02             	cmp    $0x2,%edx
  8028d8:	7f 10                	jg     8028ea <inet_aton+0x149>
  8028da:	85 d2                	test   %edx,%edx
  8028dc:	0f 84 89 00 00 00    	je     80296b <inet_aton+0x1ca>
  8028e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028e8:	eb 62                	jmp    80294c <inet_aton+0x1ab>
  8028ea:	83 fa 03             	cmp    $0x3,%edx
  8028ed:	8d 76 00             	lea    0x0(%esi),%esi
  8028f0:	74 22                	je     802914 <inet_aton+0x173>
  8028f2:	83 fa 04             	cmp    $0x4,%edx
  8028f5:	8d 76 00             	lea    0x0(%esi),%esi
  8028f8:	75 52                	jne    80294c <inet_aton+0x1ab>
  8028fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802900:	eb 2b                	jmp    80292d <inet_aton+0x18c>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  802902:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  802907:	90                   	nop
  802908:	77 61                	ja     80296b <inet_aton+0x1ca>
      return (0);
    val |= parts[0] << 24;
  80290a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80290d:	c1 e3 18             	shl    $0x18,%ebx
  802910:	09 c3                	or     %eax,%ebx
    break;
  802912:	eb 38                	jmp    80294c <inet_aton+0x1ab>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  802914:	3d ff ff 00 00       	cmp    $0xffff,%eax
  802919:	77 50                	ja     80296b <inet_aton+0x1ca>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80291b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  80291e:	c1 e3 10             	shl    $0x10,%ebx
  802921:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802924:	c1 e2 18             	shl    $0x18,%edx
  802927:	09 d3                	or     %edx,%ebx
  802929:	09 c3                	or     %eax,%ebx
    break;
  80292b:	eb 1f                	jmp    80294c <inet_aton+0x1ab>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80292d:	3d ff 00 00 00       	cmp    $0xff,%eax
  802932:	77 37                	ja     80296b <inet_aton+0x1ca>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  802934:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  802937:	c1 e3 10             	shl    $0x10,%ebx
  80293a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80293d:	c1 e2 18             	shl    $0x18,%edx
  802940:	09 d3                	or     %edx,%ebx
  802942:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802945:	c1 e2 08             	shl    $0x8,%edx
  802948:	09 d3                	or     %edx,%ebx
  80294a:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  80294c:	b8 01 00 00 00       	mov    $0x1,%eax
  802951:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802955:	74 19                	je     802970 <inet_aton+0x1cf>
    addr->s_addr = htonl(val);
  802957:	89 1c 24             	mov    %ebx,(%esp)
  80295a:	e8 16 fe ff ff       	call   802775 <htonl>
  80295f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802962:	89 03                	mov    %eax,(%ebx)
  802964:	b8 01 00 00 00       	mov    $0x1,%eax
  802969:	eb 05                	jmp    802970 <inet_aton+0x1cf>
  80296b:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  802970:	83 c4 28             	add    $0x28,%esp
  802973:	5b                   	pop    %ebx
  802974:	5e                   	pop    %esi
  802975:	5f                   	pop    %edi
  802976:	5d                   	pop    %ebp
  802977:	c3                   	ret    

00802978 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  802978:	55                   	push   %ebp
  802979:	89 e5                	mov    %esp,%ebp
  80297b:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80297e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802981:	89 44 24 04          	mov    %eax,0x4(%esp)
  802985:	8b 45 08             	mov    0x8(%ebp),%eax
  802988:	89 04 24             	mov    %eax,(%esp)
  80298b:	e8 11 fe ff ff       	call   8027a1 <inet_aton>
  802990:	83 f8 01             	cmp    $0x1,%eax
  802993:	19 c0                	sbb    %eax,%eax
  802995:	0b 45 fc             	or     -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  802998:	c9                   	leave  
  802999:	c3                   	ret    

0080299a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80299a:	55                   	push   %ebp
  80299b:	89 e5                	mov    %esp,%ebp
  80299d:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  8029a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8029a3:	89 04 24             	mov    %eax,(%esp)
  8029a6:	e8 ca fd ff ff       	call   802775 <htonl>
}
  8029ab:	c9                   	leave  
  8029ac:	c3                   	ret    
  8029ad:	00 00                	add    %al,(%eax)
	...

008029b0 <__udivdi3>:
  8029b0:	55                   	push   %ebp
  8029b1:	89 e5                	mov    %esp,%ebp
  8029b3:	57                   	push   %edi
  8029b4:	56                   	push   %esi
  8029b5:	83 ec 10             	sub    $0x10,%esp
  8029b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8029bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8029be:	8b 75 10             	mov    0x10(%ebp),%esi
  8029c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029c4:	85 c0                	test   %eax,%eax
  8029c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8029c9:	75 35                	jne    802a00 <__udivdi3+0x50>
  8029cb:	39 fe                	cmp    %edi,%esi
  8029cd:	77 61                	ja     802a30 <__udivdi3+0x80>
  8029cf:	85 f6                	test   %esi,%esi
  8029d1:	75 0b                	jne    8029de <__udivdi3+0x2e>
  8029d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8029d8:	31 d2                	xor    %edx,%edx
  8029da:	f7 f6                	div    %esi
  8029dc:	89 c6                	mov    %eax,%esi
  8029de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8029e1:	31 d2                	xor    %edx,%edx
  8029e3:	89 f8                	mov    %edi,%eax
  8029e5:	f7 f6                	div    %esi
  8029e7:	89 c7                	mov    %eax,%edi
  8029e9:	89 c8                	mov    %ecx,%eax
  8029eb:	f7 f6                	div    %esi
  8029ed:	89 c1                	mov    %eax,%ecx
  8029ef:	89 fa                	mov    %edi,%edx
  8029f1:	89 c8                	mov    %ecx,%eax
  8029f3:	83 c4 10             	add    $0x10,%esp
  8029f6:	5e                   	pop    %esi
  8029f7:	5f                   	pop    %edi
  8029f8:	5d                   	pop    %ebp
  8029f9:	c3                   	ret    
  8029fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a00:	39 f8                	cmp    %edi,%eax
  802a02:	77 1c                	ja     802a20 <__udivdi3+0x70>
  802a04:	0f bd d0             	bsr    %eax,%edx
  802a07:	83 f2 1f             	xor    $0x1f,%edx
  802a0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802a0d:	75 39                	jne    802a48 <__udivdi3+0x98>
  802a0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802a12:	0f 86 a0 00 00 00    	jbe    802ab8 <__udivdi3+0x108>
  802a18:	39 f8                	cmp    %edi,%eax
  802a1a:	0f 82 98 00 00 00    	jb     802ab8 <__udivdi3+0x108>
  802a20:	31 ff                	xor    %edi,%edi
  802a22:	31 c9                	xor    %ecx,%ecx
  802a24:	89 c8                	mov    %ecx,%eax
  802a26:	89 fa                	mov    %edi,%edx
  802a28:	83 c4 10             	add    $0x10,%esp
  802a2b:	5e                   	pop    %esi
  802a2c:	5f                   	pop    %edi
  802a2d:	5d                   	pop    %ebp
  802a2e:	c3                   	ret    
  802a2f:	90                   	nop
  802a30:	89 d1                	mov    %edx,%ecx
  802a32:	89 fa                	mov    %edi,%edx
  802a34:	89 c8                	mov    %ecx,%eax
  802a36:	31 ff                	xor    %edi,%edi
  802a38:	f7 f6                	div    %esi
  802a3a:	89 c1                	mov    %eax,%ecx
  802a3c:	89 fa                	mov    %edi,%edx
  802a3e:	89 c8                	mov    %ecx,%eax
  802a40:	83 c4 10             	add    $0x10,%esp
  802a43:	5e                   	pop    %esi
  802a44:	5f                   	pop    %edi
  802a45:	5d                   	pop    %ebp
  802a46:	c3                   	ret    
  802a47:	90                   	nop
  802a48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a4c:	89 f2                	mov    %esi,%edx
  802a4e:	d3 e0                	shl    %cl,%eax
  802a50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a53:	b8 20 00 00 00       	mov    $0x20,%eax
  802a58:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802a5b:	89 c1                	mov    %eax,%ecx
  802a5d:	d3 ea                	shr    %cl,%edx
  802a5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a63:	0b 55 ec             	or     -0x14(%ebp),%edx
  802a66:	d3 e6                	shl    %cl,%esi
  802a68:	89 c1                	mov    %eax,%ecx
  802a6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802a6d:	89 fe                	mov    %edi,%esi
  802a6f:	d3 ee                	shr    %cl,%esi
  802a71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a75:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a7b:	d3 e7                	shl    %cl,%edi
  802a7d:	89 c1                	mov    %eax,%ecx
  802a7f:	d3 ea                	shr    %cl,%edx
  802a81:	09 d7                	or     %edx,%edi
  802a83:	89 f2                	mov    %esi,%edx
  802a85:	89 f8                	mov    %edi,%eax
  802a87:	f7 75 ec             	divl   -0x14(%ebp)
  802a8a:	89 d6                	mov    %edx,%esi
  802a8c:	89 c7                	mov    %eax,%edi
  802a8e:	f7 65 e8             	mull   -0x18(%ebp)
  802a91:	39 d6                	cmp    %edx,%esi
  802a93:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a96:	72 30                	jb     802ac8 <__udivdi3+0x118>
  802a98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a9f:	d3 e2                	shl    %cl,%edx
  802aa1:	39 c2                	cmp    %eax,%edx
  802aa3:	73 05                	jae    802aaa <__udivdi3+0xfa>
  802aa5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802aa8:	74 1e                	je     802ac8 <__udivdi3+0x118>
  802aaa:	89 f9                	mov    %edi,%ecx
  802aac:	31 ff                	xor    %edi,%edi
  802aae:	e9 71 ff ff ff       	jmp    802a24 <__udivdi3+0x74>
  802ab3:	90                   	nop
  802ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ab8:	31 ff                	xor    %edi,%edi
  802aba:	b9 01 00 00 00       	mov    $0x1,%ecx
  802abf:	e9 60 ff ff ff       	jmp    802a24 <__udivdi3+0x74>
  802ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ac8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802acb:	31 ff                	xor    %edi,%edi
  802acd:	89 c8                	mov    %ecx,%eax
  802acf:	89 fa                	mov    %edi,%edx
  802ad1:	83 c4 10             	add    $0x10,%esp
  802ad4:	5e                   	pop    %esi
  802ad5:	5f                   	pop    %edi
  802ad6:	5d                   	pop    %ebp
  802ad7:	c3                   	ret    
	...

00802ae0 <__umoddi3>:
  802ae0:	55                   	push   %ebp
  802ae1:	89 e5                	mov    %esp,%ebp
  802ae3:	57                   	push   %edi
  802ae4:	56                   	push   %esi
  802ae5:	83 ec 20             	sub    $0x20,%esp
  802ae8:	8b 55 14             	mov    0x14(%ebp),%edx
  802aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802aee:	8b 7d 10             	mov    0x10(%ebp),%edi
  802af1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802af4:	85 d2                	test   %edx,%edx
  802af6:	89 c8                	mov    %ecx,%eax
  802af8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802afb:	75 13                	jne    802b10 <__umoddi3+0x30>
  802afd:	39 f7                	cmp    %esi,%edi
  802aff:	76 3f                	jbe    802b40 <__umoddi3+0x60>
  802b01:	89 f2                	mov    %esi,%edx
  802b03:	f7 f7                	div    %edi
  802b05:	89 d0                	mov    %edx,%eax
  802b07:	31 d2                	xor    %edx,%edx
  802b09:	83 c4 20             	add    $0x20,%esp
  802b0c:	5e                   	pop    %esi
  802b0d:	5f                   	pop    %edi
  802b0e:	5d                   	pop    %ebp
  802b0f:	c3                   	ret    
  802b10:	39 f2                	cmp    %esi,%edx
  802b12:	77 4c                	ja     802b60 <__umoddi3+0x80>
  802b14:	0f bd ca             	bsr    %edx,%ecx
  802b17:	83 f1 1f             	xor    $0x1f,%ecx
  802b1a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802b1d:	75 51                	jne    802b70 <__umoddi3+0x90>
  802b1f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802b22:	0f 87 e0 00 00 00    	ja     802c08 <__umoddi3+0x128>
  802b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b2b:	29 f8                	sub    %edi,%eax
  802b2d:	19 d6                	sbb    %edx,%esi
  802b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b35:	89 f2                	mov    %esi,%edx
  802b37:	83 c4 20             	add    $0x20,%esp
  802b3a:	5e                   	pop    %esi
  802b3b:	5f                   	pop    %edi
  802b3c:	5d                   	pop    %ebp
  802b3d:	c3                   	ret    
  802b3e:	66 90                	xchg   %ax,%ax
  802b40:	85 ff                	test   %edi,%edi
  802b42:	75 0b                	jne    802b4f <__umoddi3+0x6f>
  802b44:	b8 01 00 00 00       	mov    $0x1,%eax
  802b49:	31 d2                	xor    %edx,%edx
  802b4b:	f7 f7                	div    %edi
  802b4d:	89 c7                	mov    %eax,%edi
  802b4f:	89 f0                	mov    %esi,%eax
  802b51:	31 d2                	xor    %edx,%edx
  802b53:	f7 f7                	div    %edi
  802b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b58:	f7 f7                	div    %edi
  802b5a:	eb a9                	jmp    802b05 <__umoddi3+0x25>
  802b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b60:	89 c8                	mov    %ecx,%eax
  802b62:	89 f2                	mov    %esi,%edx
  802b64:	83 c4 20             	add    $0x20,%esp
  802b67:	5e                   	pop    %esi
  802b68:	5f                   	pop    %edi
  802b69:	5d                   	pop    %ebp
  802b6a:	c3                   	ret    
  802b6b:	90                   	nop
  802b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b74:	d3 e2                	shl    %cl,%edx
  802b76:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b79:	ba 20 00 00 00       	mov    $0x20,%edx
  802b7e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802b81:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802b84:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b88:	89 fa                	mov    %edi,%edx
  802b8a:	d3 ea                	shr    %cl,%edx
  802b8c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b90:	0b 55 f4             	or     -0xc(%ebp),%edx
  802b93:	d3 e7                	shl    %cl,%edi
  802b95:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b99:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b9c:	89 f2                	mov    %esi,%edx
  802b9e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802ba1:	89 c7                	mov    %eax,%edi
  802ba3:	d3 ea                	shr    %cl,%edx
  802ba5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802ba9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802bac:	89 c2                	mov    %eax,%edx
  802bae:	d3 e6                	shl    %cl,%esi
  802bb0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bb4:	d3 ea                	shr    %cl,%edx
  802bb6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bba:	09 d6                	or     %edx,%esi
  802bbc:	89 f0                	mov    %esi,%eax
  802bbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802bc1:	d3 e7                	shl    %cl,%edi
  802bc3:	89 f2                	mov    %esi,%edx
  802bc5:	f7 75 f4             	divl   -0xc(%ebp)
  802bc8:	89 d6                	mov    %edx,%esi
  802bca:	f7 65 e8             	mull   -0x18(%ebp)
  802bcd:	39 d6                	cmp    %edx,%esi
  802bcf:	72 2b                	jb     802bfc <__umoddi3+0x11c>
  802bd1:	39 c7                	cmp    %eax,%edi
  802bd3:	72 23                	jb     802bf8 <__umoddi3+0x118>
  802bd5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bd9:	29 c7                	sub    %eax,%edi
  802bdb:	19 d6                	sbb    %edx,%esi
  802bdd:	89 f0                	mov    %esi,%eax
  802bdf:	89 f2                	mov    %esi,%edx
  802be1:	d3 ef                	shr    %cl,%edi
  802be3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802be7:	d3 e0                	shl    %cl,%eax
  802be9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bed:	09 f8                	or     %edi,%eax
  802bef:	d3 ea                	shr    %cl,%edx
  802bf1:	83 c4 20             	add    $0x20,%esp
  802bf4:	5e                   	pop    %esi
  802bf5:	5f                   	pop    %edi
  802bf6:	5d                   	pop    %ebp
  802bf7:	c3                   	ret    
  802bf8:	39 d6                	cmp    %edx,%esi
  802bfa:	75 d9                	jne    802bd5 <__umoddi3+0xf5>
  802bfc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802bff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802c02:	eb d1                	jmp    802bd5 <__umoddi3+0xf5>
  802c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c08:	39 f2                	cmp    %esi,%edx
  802c0a:	0f 82 18 ff ff ff    	jb     802b28 <__umoddi3+0x48>
  802c10:	e9 1d ff ff ff       	jmp    802b32 <__umoddi3+0x52>
