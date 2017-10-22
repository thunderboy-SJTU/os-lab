
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 0b 06 00 00       	call   80063c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 20 33 80 00 	movl   $0x803320,(%esp)
  800051:	e8 0f 07 00 00       	call   800765 <cprintf>
	exit();
  800056:	e8 35 06 00 00       	call   800690 <exit>
}
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	81 ec 2c 02 00 00    	sub    $0x22c,%esp
  800069:	89 c3                	mov    %eax,%ebx
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  80006b:	8b 0d 10 40 80 00    	mov    0x804010,%ecx
  800071:	85 c9                	test   %ecx,%ecx
  800073:	0f 84 86 00 00 00    	je     8000ff <send_error+0xa2>
  800079:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  800080:	0f 84 89 00 00 00    	je     80010f <send_error+0xb2>
		if (e->code == code)
  800086:	b8 10 40 80 00       	mov    $0x804010,%eax
  80008b:	39 d1                	cmp    %edx,%ecx
  80008d:	75 06                	jne    800095 <send_error+0x38>
  80008f:	eb 15                	jmp    8000a6 <send_error+0x49>
  800091:	39 d1                	cmp    %edx,%ecx
  800093:	74 16                	je     8000ab <send_error+0x4e>
			break;
		e++;
  800095:	83 c0 08             	add    $0x8,%eax
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  800098:	8b 08                	mov    (%eax),%ecx
  80009a:	85 c9                	test   %ecx,%ecx
  80009c:	74 61                	je     8000ff <send_error+0xa2>
  80009e:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  8000a2:	75 ed                	jne    800091 <send_error+0x34>
  8000a4:	eb 09                	jmp    8000af <send_error+0x52>
  8000a6:	b8 10 40 80 00       	mov    $0x804010,%eax
		if (e->code == code)
			break;
		e++;
	}

	if (e->code == 0)
  8000ab:	85 c9                	test   %ecx,%ecx
  8000ad:	74 50                	je     8000ff <send_error+0xa2>
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  8000af:	8b 40 04             	mov    0x4(%eax),%eax
  8000b2:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000b6:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8000ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8000c2:	c7 44 24 08 fc 33 80 	movl   $0x8033fc,0x8(%esp)
  8000c9:	00 
  8000ca:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  8000d1:	00 
  8000d2:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 1f 0f 00 00       	call   800fff <snprintf>
  8000e0:	89 c7                	mov    %eax,%edi
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  8000e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ea:	8b 03                	mov    (%ebx),%eax
  8000ec:	89 04 24             	mov    %eax,(%esp)
  8000ef:	e8 f1 1c 00 00       	call   801de5 <write>
  8000f4:	89 c2                	mov    %eax,%edx
  8000f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fb:	39 d7                	cmp    %edx,%edi
  8000fd:	74 05                	je     800104 <send_error+0xa7>
  8000ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;

	return 0;
}
  800104:	81 c4 2c 02 00 00    	add    $0x22c,%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  80010f:	b8 10 40 80 00       	mov    $0x804010,%eax
  800114:	eb 99                	jmp    8000af <send_error+0x52>

00800116 <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	81 ec 6c 07 00 00    	sub    $0x76c,%esp
  800122:	89 c6                	mov    %eax,%esi
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  800124:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80012b:	00 
  80012c:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800132:	89 44 24 04          	mov    %eax,0x4(%esp)
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 30 1d 00 00       	call   801e6e <read>
  80013e:	85 c0                	test   %eax,%eax
  800140:	79 1c                	jns    80015e <handle_client+0x48>
			panic("failed to read");
  800142:	c7 44 24 08 24 33 80 	movl   $0x803324,0x8(%esp)
  800149:	00 
  80014a:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 33 33 80 00 	movl   $0x803333,(%esp)
  800159:	e8 4e 05 00 00       	call   8006ac <_panic>

		memset(req, 0, sizeof(req));
  80015e:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800165:	00 
  800166:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80016d:	00 
  80016e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 ad 10 00 00       	call   801226 <memset>

		req->sock = sock;
  800179:	89 75 dc             	mov    %esi,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  80017c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800183:	00 
  800184:	c7 44 24 04 40 33 80 	movl   $0x803340,0x4(%esp)
  80018b:	00 
  80018c:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800192:	89 04 24             	mov    %eax,(%esp)
  800195:	e8 ea 0f 00 00       	call   801184 <strncmp>
  80019a:	85 c0                	test   %eax,%eax
  80019c:	0f 85 ff 02 00 00    	jne    8004a1 <handle_client+0x38b>
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  8001a2:	0f b6 85 e0 fd ff ff 	movzbl -0x220(%ebp),%eax
  8001a9:	84 c0                	test   %al,%al
  8001ab:	74 0a                	je     8001b7 <handle_client+0xa1>
  8001ad:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  8001b3:	3c 20                	cmp    $0x20,%al
  8001b5:	75 08                	jne    8001bf <handle_client+0xa9>
  8001b7:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  8001bd:	eb 0e                	jmp    8001cd <handle_client+0xb7>
		request++;
  8001bf:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  8001c2:	0f b6 03             	movzbl (%ebx),%eax
  8001c5:	84 c0                	test   %al,%al
  8001c7:	74 04                	je     8001cd <handle_client+0xb7>
  8001c9:	3c 20                	cmp    $0x20,%al
  8001cb:	75 f2                	jne    8001bf <handle_client+0xa9>
		request++;
	url_len = request - url;
  8001cd:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
  8001d3:	89 85 a4 f8 ff ff    	mov    %eax,-0x75c(%ebp)
  8001d9:	89 df                	mov    %ebx,%edi
  8001db:	29 c7                	sub    %eax,%edi

	req->url = malloc(url_len + 1);
  8001dd:	8d 47 01             	lea    0x1(%edi),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 3b 28 00 00       	call   802a23 <malloc>
  8001e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  8001eb:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8001ef:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
  8001f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 84 10 00 00       	call   801285 <memmove>
	req->url[url_len] = '\0';
  800201:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800204:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)

	// skip space
	request++;
  800208:	83 c3 01             	add    $0x1,%ebx

	version = request;
	while (*request && *request != '\n')
  80020b:	0f b6 03             	movzbl (%ebx),%eax
  80020e:	84 c0                	test   %al,%al
  800210:	74 06                	je     800218 <handle_client+0x102>
  800212:	89 df                	mov    %ebx,%edi
  800214:	3c 0a                	cmp    $0xa,%al
  800216:	75 04                	jne    80021c <handle_client+0x106>
  800218:	89 df                	mov    %ebx,%edi
  80021a:	eb 0e                	jmp    80022a <handle_client+0x114>
		request++;
  80021c:	83 c7 01             	add    $0x1,%edi

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  80021f:	0f b6 07             	movzbl (%edi),%eax
  800222:	84 c0                	test   %al,%al
  800224:	74 04                	je     80022a <handle_client+0x114>
  800226:	3c 0a                	cmp    $0xa,%al
  800228:	75 f2                	jne    80021c <handle_client+0x106>
		request++;
	version_len = request - version;
  80022a:	29 df                	sub    %ebx,%edi

	req->version = malloc(version_len + 1);
  80022c:	8d 47 01             	lea    0x1(%edi),%eax
  80022f:	89 04 24             	mov    %eax,(%esp)
  800232:	e8 ec 27 00 00       	call   802a23 <malloc>
  800237:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  80023a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80023e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	e8 3b 10 00 00       	call   801285 <memmove>
	req->version[version_len] = '\0';
  80024a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024d:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
	//panic("send_file not implemented");
        fd = open(req->url,O_RDONLY);
  800251:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800258:	00 
  800259:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 33 21 00 00       	call   802397 <open>
  800264:	89 c7                	mov    %eax,%edi
        if(fd < 0)
  800266:	85 c0                	test   %eax,%eax
  800268:	79 12                	jns    80027c <handle_client+0x166>
           return send_error(req,404);
  80026a:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80026d:	ba 94 01 00 00       	mov    $0x194,%edx
  800272:	e8 e6 fd ff ff       	call   80005d <send_error>
  800277:	e9 fc 01 00 00       	jmp    800478 <handle_client+0x362>
        struct Stat stat;
        if((r = fstat(fd,&stat)) < 0 || stat.st_isdir)
  80027c:	8d 85 50 fd ff ff    	lea    -0x2b0(%ebp),%eax
  800282:	89 44 24 04          	mov    %eax,0x4(%esp)
  800286:	89 3c 24             	mov    %edi,(%esp)
  800289:	e8 5c 1a 00 00       	call   801cea <fstat>
  80028e:	85 c0                	test   %eax,%eax
  800290:	78 09                	js     80029b <handle_client+0x185>
  800292:	83 bd d4 fd ff ff 00 	cmpl   $0x0,-0x22c(%ebp)
  800299:	74 12                	je     8002ad <handle_client+0x197>
           return send_error(req,404);
  80029b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80029e:	ba 94 01 00 00       	mov    $0x194,%edx
  8002a3:	e8 b5 fd ff ff       	call   80005d <send_error>
  8002a8:	e9 cb 01 00 00       	jmp    800478 <handle_client+0x362>
        file_size = stat.st_size;
  8002ad:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  8002b3:	89 85 b4 f8 ff ff    	mov    %eax,-0x74c(%ebp)

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
  8002b9:	a1 00 40 80 00       	mov    0x804000,%eax
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 aa 01 00 00    	je     800470 <handle_client+0x35a>
  8002c6:	bb 00 40 80 00       	mov    $0x804000,%ebx
  8002cb:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8002d2:	74 29                	je     8002fd <handle_client+0x1e7>
		if (h->code == code)
  8002d4:	3d c8 00 00 00       	cmp    $0xc8,%eax
  8002d9:	75 0f                	jne    8002ea <handle_client+0x1d4>
  8002db:	eb 20                	jmp    8002fd <handle_client+0x1e7>
  8002dd:	3d c8 00 00 00       	cmp    $0xc8,%eax
  8002e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8002e8:	74 13                	je     8002fd <handle_client+0x1e7>
			break;
		h++;
  8002ea:	83 c3 08             	add    $0x8,%ebx

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
  8002ed:	8b 03                	mov    (%ebx),%eax
  8002ef:	85 c0                	test   %eax,%eax
  8002f1:	0f 84 79 01 00 00    	je     800470 <handle_client+0x35a>
  8002f7:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8002fb:	75 e0                	jne    8002dd <handle_client+0x1c7>
	}

	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
  8002fd:	8b 43 04             	mov    0x4(%ebx),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	e8 48 0d 00 00       	call   801050 <strlen>
  800308:	89 85 b0 f8 ff ff    	mov    %eax,-0x750(%ebp)
	if (write(req->sock, h->header, len) != len) {
  80030e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800312:	8b 43 04             	mov    0x4(%ebx),%eax
  800315:	89 44 24 04          	mov    %eax,0x4(%esp)
  800319:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	e8 c1 1a 00 00       	call   801de5 <write>
  800324:	39 85 b0 f8 ff ff    	cmp    %eax,-0x750(%ebp)
  80032a:	0f 84 80 01 00 00    	je     8004b0 <handle_client+0x39a>
		die("Failed to send bytes to client");
  800330:	b8 78 34 80 00       	mov    $0x803478,%eax
  800335:	e8 06 fd ff ff       	call   800040 <die>
  80033a:	e9 71 01 00 00       	jmp    8004b0 <handle_client+0x39a>
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
	if (r > 63)
		panic("buffer too small!");
  80033f:	c7 44 24 08 45 33 80 	movl   $0x803345,0x8(%esp)
  800346:	00 
  800347:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  80034e:	00 
  80034f:	c7 04 24 33 33 80 00 	movl   $0x803333,(%esp)
  800356:	e8 51 03 00 00       	call   8006ac <_panic>

	if (write(req->sock, buf, r) != r)
  80035b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80035f:	8d 85 c4 fc ff ff    	lea    -0x33c(%ebp),%eax
  800365:	89 44 24 04          	mov    %eax,0x4(%esp)
  800369:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	e8 71 1a 00 00       	call   801de5 <write>
  800374:	39 c3                	cmp    %eax,%ebx
  800376:	0f 85 f4 00 00 00    	jne    800470 <handle_client+0x35a>
  80037c:	e9 67 01 00 00       	jmp    8004e8 <handle_client+0x3d2>
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
	if (r > 127)
		panic("buffer too small!");
  800381:	c7 44 24 08 45 33 80 	movl   $0x803345,0x8(%esp)
  800388:	00 
  800389:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  800390:	00 
  800391:	c7 04 24 33 33 80 00 	movl   $0x803333,(%esp)
  800398:	e8 0f 03 00 00       	call   8006ac <_panic>

	if (write(req->sock, buf, r) != r)
  80039d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a1:	8d 85 c4 fc ff ff    	lea    -0x33c(%ebp),%eax
  8003a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	e8 2f 1a 00 00       	call   801de5 <write>
  8003b6:	39 c3                	cmp    %eax,%ebx
  8003b8:	0f 85 b2 00 00 00    	jne    800470 <handle_client+0x35a>

static int
send_header_fin(struct http_request *req)
{
	const char *fin = "\r\n";
	int fin_len = strlen(fin);
  8003be:	c7 04 24 a4 33 80 00 	movl   $0x8033a4,(%esp)
  8003c5:	e8 86 0c 00 00       	call   801050 <strlen>
  8003ca:	89 c3                	mov    %eax,%ebx

	if (write(req->sock, fin, fin_len) != fin_len)
  8003cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d0:	c7 44 24 04 a4 33 80 	movl   $0x8033a4,0x4(%esp)
  8003d7:	00 
  8003d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	e8 02 1a 00 00       	call   801de5 <write>
  8003e3:	39 c3                	cmp    %eax,%ebx
  8003e5:	0f 85 85 00 00 00    	jne    800470 <handle_client+0x35a>
  8003eb:	e9 2e 01 00 00       	jmp    80051e <handle_client+0x408>
	//panic("send_data not implemented");
        char buf[1024];
        int r;
        struct Stat stat;
        if((r = fstat(fd,&stat)) < 0){
           cprintf("read stat failed\n"); 
  8003f0:	c7 04 24 57 33 80 00 	movl   $0x803357,(%esp)
  8003f7:	e8 69 03 00 00       	call   800765 <cprintf>
  8003fc:	eb 72                	jmp    800470 <handle_client+0x35a>
           return -1;
        }
        if(stat.st_size > 1024){
  8003fe:	8b 85 44 fd ff ff    	mov    -0x2bc(%ebp),%eax
  800404:	3d 00 04 00 00       	cmp    $0x400,%eax
  800409:	7e 0e                	jle    800419 <handle_client+0x303>
           cprintf("file too large\n");
  80040b:	c7 04 24 69 33 80 00 	movl   $0x803369,(%esp)
  800412:	e8 4e 03 00 00       	call   800765 <cprintf>
  800417:	eb 57                	jmp    800470 <handle_client+0x35a>
           return -1;
        }
        if((r = readn(fd,buf,stat.st_size)) != stat.st_size){
  800419:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041d:	8d 85 c4 f8 ff ff    	lea    -0x73c(%ebp),%eax
  800423:	89 44 24 04          	mov    %eax,0x4(%esp)
  800427:	89 3c 24             	mov    %edi,(%esp)
  80042a:	e8 cd 1a 00 00       	call   801efc <readn>
  80042f:	89 c3                	mov    %eax,%ebx
  800431:	3b 85 44 fd ff ff    	cmp    -0x2bc(%ebp),%eax
  800437:	74 0e                	je     800447 <handle_client+0x331>
           cprintf("can't read entire file\n");
  800439:	c7 04 24 79 33 80 00 	movl   $0x803379,(%esp)
  800440:	e8 20 03 00 00       	call   800765 <cprintf>
  800445:	eb 29                	jmp    800470 <handle_client+0x35a>
           return -1;
        }
        if(write(req->sock,buf,r)!= r){
  800447:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044b:	8d 85 c4 f8 ff ff    	lea    -0x73c(%ebp),%eax
  800451:	89 44 24 04          	mov    %eax,0x4(%esp)
  800455:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 85 19 00 00       	call   801de5 <write>
  800460:	39 c3                	cmp    %eax,%ebx
  800462:	74 0c                	je     800470 <handle_client+0x35a>
           cprintf("can't write entire file to socket\n");
  800464:	c7 04 24 98 34 80 00 	movl   $0x803498,(%esp)
  80046b:	e8 f5 02 00 00       	call   800765 <cprintf>
		goto end;

	r = send_data(req, fd);

end:
	close(fd);
  800470:	89 3c 24             	mov    %edi,(%esp)
  800473:	e8 56 1b 00 00       	call   801fce <close>
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  800478:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	e8 cd 24 00 00       	call   802950 <free>
	free(req->version);
  800483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800486:	89 04 24             	mov    %eax,(%esp)
  800489:	e8 c2 24 00 00       	call   802950 <free>

		// no keep alive
		break;
	}

	close(sock);
  80048e:	89 34 24             	mov    %esi,(%esp)
  800491:	e8 38 1b 00 00       	call   801fce <close>
}
  800496:	81 c4 6c 07 00 00    	add    $0x76c,%esp
  80049c:	5b                   	pop    %ebx
  80049d:	5e                   	pop    %esi
  80049e:	5f                   	pop    %edi
  80049f:	5d                   	pop    %ebp
  8004a0:	c3                   	ret    

		req->sock = sock;

		r = http_request_parse(req, buffer);
		if (r == -E_BAD_REQ)
			send_error(req, 400);
  8004a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8004a4:	ba 90 01 00 00       	mov    $0x190,%edx
  8004a9:	e8 af fb ff ff       	call   80005d <send_error>
  8004ae:	eb c8                	jmp    800478 <handle_client+0x362>
send_size(struct http_request *req, off_t size)
{
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  8004b0:	8b 95 b4 f8 ff ff    	mov    -0x74c(%ebp),%edx
  8004b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ba:	c7 44 24 08 91 33 80 	movl   $0x803391,0x8(%esp)
  8004c1:	00 
  8004c2:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8004c9:	00 
  8004ca:	8d 85 c4 fc ff ff    	lea    -0x33c(%ebp),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	e8 27 0b 00 00       	call   800fff <snprintf>
  8004d8:	89 c3                	mov    %eax,%ebx
	if (r > 63)
  8004da:	83 f8 3f             	cmp    $0x3f,%eax
  8004dd:	0f 8e 78 fe ff ff    	jle    80035b <handle_client+0x245>
  8004e3:	e9 57 fe ff ff       	jmp    80033f <handle_client+0x229>

	type = mime_type(req->url);
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  8004e8:	c7 44 24 0c a7 33 80 	movl   $0x8033a7,0xc(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 08 b1 33 80 	movl   $0x8033b1,0x8(%esp)
  8004f7:	00 
  8004f8:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8004ff:	00 
  800500:	8d 85 c4 fc ff ff    	lea    -0x33c(%ebp),%eax
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	e8 f1 0a 00 00       	call   800fff <snprintf>
  80050e:	89 c3                	mov    %eax,%ebx
	if (r > 127)
  800510:	83 f8 7f             	cmp    $0x7f,%eax
  800513:	0f 8e 84 fe ff ff    	jle    80039d <handle_client+0x287>
  800519:	e9 63 fe ff ff       	jmp    800381 <handle_client+0x26b>
	// LAB 6: Your code here.
	//panic("send_data not implemented");
        char buf[1024];
        int r;
        struct Stat stat;
        if((r = fstat(fd,&stat)) < 0){
  80051e:	8d 85 c4 fc ff ff    	lea    -0x33c(%ebp),%eax
  800524:	89 44 24 04          	mov    %eax,0x4(%esp)
  800528:	89 3c 24             	mov    %edi,(%esp)
  80052b:	e8 ba 17 00 00       	call   801cea <fstat>
  800530:	85 c0                	test   %eax,%eax
  800532:	0f 89 c6 fe ff ff    	jns    8003fe <handle_client+0x2e8>
  800538:	e9 b3 fe ff ff       	jmp    8003f0 <handle_client+0x2da>

0080053d <umain>:
	close(sock);
}

void
umain(int argc, char **argv)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	57                   	push   %edi
  800541:	56                   	push   %esi
  800542:	53                   	push   %ebx
  800543:	83 ec 4c             	sub    $0x4c,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  800546:	c7 05 20 40 80 00 c4 	movl   $0x8033c4,0x804020
  80054d:	33 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800550:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800557:	00 
  800558:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80055f:	00 
  800560:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800567:	e8 f2 1f 00 00       	call   80255e <socket>
  80056c:	89 c6                	mov    %eax,%esi
  80056e:	85 c0                	test   %eax,%eax
  800570:	79 0a                	jns    80057c <umain+0x3f>
		die("Failed to create socket");
  800572:	b8 cb 33 80 00       	mov    $0x8033cb,%eax
  800577:	e8 c4 fa ff ff       	call   800040 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  80057c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800583:	00 
  800584:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80058b:	00 
  80058c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 8f 0c 00 00       	call   801226 <memset>
	server.sin_family = AF_INET;			// Internet/IP
  800597:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  80059b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a2:	e8 be 28 00 00       	call   802e65 <htonl>
  8005a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  8005aa:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  8005b1:	e8 8e 28 00 00       	call   802e44 <htons>
  8005b6:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  8005ba:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8005c1:	00 
  8005c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c6:	89 34 24             	mov    %esi,(%esp)
  8005c9:	e8 5a 20 00 00       	call   802628 <bind>
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	79 0a                	jns    8005dc <umain+0x9f>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  8005d2:	b8 bc 34 80 00       	mov    $0x8034bc,%eax
  8005d7:	e8 64 fa ff ff       	call   800040 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  8005dc:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  8005e3:	00 
  8005e4:	89 34 24             	mov    %esi,(%esp)
  8005e7:	e8 cc 1f 00 00       	call   8025b8 <listen>
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	79 0a                	jns    8005fa <umain+0xbd>
		die("Failed to listen on server socket");
  8005f0:	b8 e0 34 80 00       	mov    $0x8034e0,%eax
  8005f5:	e8 46 fa ff ff       	call   800040 <die>

	cprintf("Waiting for http connections...\n");
  8005fa:	c7 04 24 04 35 80 00 	movl   $0x803504,(%esp)
  800601:	e8 5f 01 00 00       	call   800765 <cprintf>

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800606:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  800609:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800610:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800614:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061b:	89 34 24             	mov    %esi,(%esp)
  80061e:	e8 2f 20 00 00       	call   802652 <accept>
  800623:	89 c3                	mov    %eax,%ebx
  800625:	85 c0                	test   %eax,%eax
  800627:	79 0a                	jns    800633 <umain+0xf6>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  800629:	b8 28 35 80 00       	mov    $0x803528,%eax
  80062e:	e8 0d fa ff ff       	call   800040 <die>
		}
		handle_client(clientsock);
  800633:	89 d8                	mov    %ebx,%eax
  800635:	e8 dc fa ff ff       	call   800116 <handle_client>
	}
  80063a:	eb cd                	jmp    800609 <umain+0xcc>

0080063c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
  80063f:	83 ec 18             	sub    $0x18,%esp
  800642:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800645:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800648:	8b 75 08             	mov    0x8(%ebp),%esi
  80064b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80064e:	e8 64 14 00 00       	call   801ab7 <sys_getenvid>
  800653:	25 ff 03 00 00       	and    $0x3ff,%eax
  800658:	89 c2                	mov    %eax,%edx
  80065a:	c1 e2 07             	shl    $0x7,%edx
  80065d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800664:	a3 1c 50 80 00       	mov    %eax,0x80501c
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800669:	85 f6                	test   %esi,%esi
  80066b:	7e 07                	jle    800674 <libmain+0x38>
		binaryname = argv[0];
  80066d:	8b 03                	mov    (%ebx),%eax
  80066f:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  800674:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800678:	89 34 24             	mov    %esi,(%esp)
  80067b:	e8 bd fe ff ff       	call   80053d <umain>

	// exit gracefully
	exit();
  800680:	e8 0b 00 00 00       	call   800690 <exit>
}
  800685:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800688:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80068b:	89 ec                	mov    %ebp,%esp
  80068d:	5d                   	pop    %ebp
  80068e:	c3                   	ret    
	...

00800690 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800696:	e8 b0 19 00 00       	call   80204b <close_all>
	sys_env_destroy(0);
  80069b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a2:	e8 50 14 00 00       	call   801af7 <sys_env_destroy>
}
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    
  8006a9:	00 00                	add    %al,(%eax)
	...

008006ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	56                   	push   %esi
  8006b0:	53                   	push   %ebx
  8006b1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8006b4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006b7:	8b 1d 20 40 80 00    	mov    0x804020,%ebx
  8006bd:	e8 f5 13 00 00       	call   801ab7 <sys_getenvid>
  8006c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006c5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	c7 04 24 7c 35 80 00 	movl   $0x80357c,(%esp)
  8006df:	e8 81 00 00 00       	call   800765 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	e8 11 00 00 00       	call   800704 <vcprintf>
	cprintf("\n");
  8006f3:	c7 04 24 a5 33 80 00 	movl   $0x8033a5,(%esp)
  8006fa:	e8 66 00 00 00       	call   800765 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006ff:	cc                   	int3   
  800700:	eb fd                	jmp    8006ff <_panic+0x53>
	...

00800704 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80070d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800714:	00 00 00 
	b.cnt = 0;
  800717:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80071e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
  800724:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800735:	89 44 24 04          	mov    %eax,0x4(%esp)
  800739:	c7 04 24 7f 07 80 00 	movl   $0x80077f,(%esp)
  800740:	e8 d7 01 00 00       	call   80091c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800745:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80074b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800755:	89 04 24             	mov    %eax,(%esp)
  800758:	e8 6f 0d 00 00       	call   8014cc <sys_cputs>

	return b.cnt;
}
  80075d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80076b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80076e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800772:	8b 45 08             	mov    0x8(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 87 ff ff ff       	call   800704 <vcprintf>
	va_end(ap);

	return cnt;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	83 ec 14             	sub    $0x14,%esp
  800786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800789:	8b 03                	mov    (%ebx),%eax
  80078b:	8b 55 08             	mov    0x8(%ebp),%edx
  80078e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800792:	83 c0 01             	add    $0x1,%eax
  800795:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800797:	3d ff 00 00 00       	cmp    $0xff,%eax
  80079c:	75 19                	jne    8007b7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80079e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8007a5:	00 
  8007a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8007a9:	89 04 24             	mov    %eax,(%esp)
  8007ac:	e8 1b 0d 00 00       	call   8014cc <sys_cputs>
		b->idx = 0;
  8007b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8007bb:	83 c4 14             	add    $0x14,%esp
  8007be:	5b                   	pop    %ebx
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    
	...

008007d0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	57                   	push   %edi
  8007d4:	56                   	push   %esi
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 4c             	sub    $0x4c,%esp
  8007d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007dc:	89 d6                	mov    %edx,%esi
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007f0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8007f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fb:	39 d1                	cmp    %edx,%ecx
  8007fd:	72 07                	jb     800806 <printnum_v2+0x36>
  8007ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800802:	39 d0                	cmp    %edx,%eax
  800804:	77 5f                	ja     800865 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800806:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80080a:	83 eb 01             	sub    $0x1,%ebx
  80080d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800811:	89 44 24 08          	mov    %eax,0x8(%esp)
  800815:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800819:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80081d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800820:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800823:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800826:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80082a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800831:	00 
  800832:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800835:	89 04 24             	mov    %eax,(%esp)
  800838:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80083b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083f:	e8 5c 28 00 00       	call   8030a0 <__udivdi3>
  800844:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800847:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80084a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80084e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800852:	89 04 24             	mov    %eax,(%esp)
  800855:	89 54 24 04          	mov    %edx,0x4(%esp)
  800859:	89 f2                	mov    %esi,%edx
  80085b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80085e:	e8 6d ff ff ff       	call   8007d0 <printnum_v2>
  800863:	eb 1e                	jmp    800883 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800865:	83 ff 2d             	cmp    $0x2d,%edi
  800868:	74 19                	je     800883 <printnum_v2+0xb3>
		while (--width > 0)
  80086a:	83 eb 01             	sub    $0x1,%ebx
  80086d:	85 db                	test   %ebx,%ebx
  80086f:	90                   	nop
  800870:	7e 11                	jle    800883 <printnum_v2+0xb3>
			putch(padc, putdat);
  800872:	89 74 24 04          	mov    %esi,0x4(%esp)
  800876:	89 3c 24             	mov    %edi,(%esp)
  800879:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80087c:	83 eb 01             	sub    $0x1,%ebx
  80087f:	85 db                	test   %ebx,%ebx
  800881:	7f ef                	jg     800872 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800883:	89 74 24 04          	mov    %esi,0x4(%esp)
  800887:	8b 74 24 04          	mov    0x4(%esp),%esi
  80088b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80088e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800892:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800899:	00 
  80089a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80089d:	89 14 24             	mov    %edx,(%esp)
  8008a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a7:	e8 24 29 00 00       	call   8031d0 <__umoddi3>
  8008ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b0:	0f be 80 9f 35 80 00 	movsbl 0x80359f(%eax),%eax
  8008b7:	89 04 24             	mov    %eax,(%esp)
  8008ba:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8008bd:	83 c4 4c             	add    $0x4c,%esp
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5f                   	pop    %edi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8008c8:	83 fa 01             	cmp    $0x1,%edx
  8008cb:	7e 0e                	jle    8008db <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8008cd:	8b 10                	mov    (%eax),%edx
  8008cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8008d2:	89 08                	mov    %ecx,(%eax)
  8008d4:	8b 02                	mov    (%edx),%eax
  8008d6:	8b 52 04             	mov    0x4(%edx),%edx
  8008d9:	eb 22                	jmp    8008fd <getuint+0x38>
	else if (lflag)
  8008db:	85 d2                	test   %edx,%edx
  8008dd:	74 10                	je     8008ef <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8008df:	8b 10                	mov    (%eax),%edx
  8008e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008e4:	89 08                	mov    %ecx,(%eax)
  8008e6:	8b 02                	mov    (%edx),%eax
  8008e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ed:	eb 0e                	jmp    8008fd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8008ef:	8b 10                	mov    (%eax),%edx
  8008f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008f4:	89 08                	mov    %ecx,(%eax)
  8008f6:	8b 02                	mov    (%edx),%eax
  8008f8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800905:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800909:	8b 10                	mov    (%eax),%edx
  80090b:	3b 50 04             	cmp    0x4(%eax),%edx
  80090e:	73 0a                	jae    80091a <sprintputch+0x1b>
		*b->buf++ = ch;
  800910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800913:	88 0a                	mov    %cl,(%edx)
  800915:	83 c2 01             	add    $0x1,%edx
  800918:	89 10                	mov    %edx,(%eax)
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	83 ec 6c             	sub    $0x6c,%esp
  800925:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800928:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80092f:	eb 1a                	jmp    80094b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800931:	85 c0                	test   %eax,%eax
  800933:	0f 84 66 06 00 00    	je     800f9f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	ff 55 08             	call   *0x8(%ebp)
  800946:	eb 03                	jmp    80094b <vprintfmt+0x2f>
  800948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80094b:	0f b6 07             	movzbl (%edi),%eax
  80094e:	83 c7 01             	add    $0x1,%edi
  800951:	83 f8 25             	cmp    $0x25,%eax
  800954:	75 db                	jne    800931 <vprintfmt+0x15>
  800956:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80095a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800966:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80096b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800972:	be 00 00 00 00       	mov    $0x0,%esi
  800977:	eb 06                	jmp    80097f <vprintfmt+0x63>
  800979:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80097d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097f:	0f b6 17             	movzbl (%edi),%edx
  800982:	0f b6 c2             	movzbl %dl,%eax
  800985:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800988:	8d 47 01             	lea    0x1(%edi),%eax
  80098b:	83 ea 23             	sub    $0x23,%edx
  80098e:	80 fa 55             	cmp    $0x55,%dl
  800991:	0f 87 60 05 00 00    	ja     800ef7 <vprintfmt+0x5db>
  800997:	0f b6 d2             	movzbl %dl,%edx
  80099a:	ff 24 95 80 37 80 00 	jmp    *0x803780(,%edx,4)
  8009a1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8009a6:	eb d5                	jmp    80097d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8009a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009ab:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8009ae:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8009b1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8009b4:	83 ff 09             	cmp    $0x9,%edi
  8009b7:	76 08                	jbe    8009c1 <vprintfmt+0xa5>
  8009b9:	eb 40                	jmp    8009fb <vprintfmt+0xdf>
  8009bb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8009bf:	eb bc                	jmp    80097d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009c1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8009c4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8009c7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8009cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8009ce:	8d 7a d0             	lea    -0x30(%edx),%edi
  8009d1:	83 ff 09             	cmp    $0x9,%edi
  8009d4:	76 eb                	jbe    8009c1 <vprintfmt+0xa5>
  8009d6:	eb 23                	jmp    8009fb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8009d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8009db:	8d 5a 04             	lea    0x4(%edx),%ebx
  8009de:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8009e1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8009e3:	eb 16                	jmp    8009fb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8009e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009e8:	c1 fa 1f             	sar    $0x1f,%edx
  8009eb:	f7 d2                	not    %edx
  8009ed:	21 55 d8             	and    %edx,-0x28(%ebp)
  8009f0:	eb 8b                	jmp    80097d <vprintfmt+0x61>
  8009f2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8009f9:	eb 82                	jmp    80097d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8009fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009ff:	0f 89 78 ff ff ff    	jns    80097d <vprintfmt+0x61>
  800a05:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800a08:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  800a0b:	e9 6d ff ff ff       	jmp    80097d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a10:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800a13:	e9 65 ff ff ff       	jmp    80097d <vprintfmt+0x61>
  800a18:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1e:	8d 50 04             	lea    0x4(%eax),%edx
  800a21:	89 55 14             	mov    %edx,0x14(%ebp)
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a27:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a2b:	8b 00                	mov    (%eax),%eax
  800a2d:	89 04 24             	mov    %eax,(%esp)
  800a30:	ff 55 08             	call   *0x8(%ebp)
  800a33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800a36:	e9 10 ff ff ff       	jmp    80094b <vprintfmt+0x2f>
  800a3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a41:	8d 50 04             	lea    0x4(%eax),%edx
  800a44:	89 55 14             	mov    %edx,0x14(%ebp)
  800a47:	8b 00                	mov    (%eax),%eax
  800a49:	89 c2                	mov    %eax,%edx
  800a4b:	c1 fa 1f             	sar    $0x1f,%edx
  800a4e:	31 d0                	xor    %edx,%eax
  800a50:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a52:	83 f8 0f             	cmp    $0xf,%eax
  800a55:	7f 0b                	jg     800a62 <vprintfmt+0x146>
  800a57:	8b 14 85 e0 38 80 00 	mov    0x8038e0(,%eax,4),%edx
  800a5e:	85 d2                	test   %edx,%edx
  800a60:	75 26                	jne    800a88 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800a62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a66:	c7 44 24 08 b0 35 80 	movl   $0x8035b0,0x8(%esp)
  800a6d:	00 
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a71:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a78:	89 1c 24             	mov    %ebx,(%esp)
  800a7b:	e8 a7 05 00 00       	call   801027 <printfmt>
  800a80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a83:	e9 c3 fe ff ff       	jmp    80094b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800a88:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a8c:	c7 44 24 08 fe 39 80 	movl   $0x8039fe,0x8(%esp)
  800a93:	00 
  800a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9e:	89 14 24             	mov    %edx,(%esp)
  800aa1:	e8 81 05 00 00       	call   801027 <printfmt>
  800aa6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aa9:	e9 9d fe ff ff       	jmp    80094b <vprintfmt+0x2f>
  800aae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	89 d9                	mov    %ebx,%ecx
  800ab5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ab8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800abb:	8b 45 14             	mov    0x14(%ebp),%eax
  800abe:	8d 50 04             	lea    0x4(%eax),%edx
  800ac1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac4:	8b 30                	mov    (%eax),%esi
  800ac6:	85 f6                	test   %esi,%esi
  800ac8:	75 05                	jne    800acf <vprintfmt+0x1b3>
  800aca:	be b9 35 80 00       	mov    $0x8035b9,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  800acf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800ad3:	7e 06                	jle    800adb <vprintfmt+0x1bf>
  800ad5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800ad9:	75 10                	jne    800aeb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800adb:	0f be 06             	movsbl (%esi),%eax
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	0f 85 a2 00 00 00    	jne    800b88 <vprintfmt+0x26c>
  800ae6:	e9 92 00 00 00       	jmp    800b7d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800aeb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800aef:	89 34 24             	mov    %esi,(%esp)
  800af2:	e8 74 05 00 00       	call   80106b <strnlen>
  800af7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800afa:	29 c2                	sub    %eax,%edx
  800afc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800aff:	85 d2                	test   %edx,%edx
  800b01:	7e d8                	jle    800adb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800b03:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800b07:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800b0a:	89 d3                	mov    %edx,%ebx
  800b0c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800b0f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800b12:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b15:	89 ce                	mov    %ecx,%esi
  800b17:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b1b:	89 34 24             	mov    %esi,(%esp)
  800b1e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b21:	83 eb 01             	sub    $0x1,%ebx
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	7f ef                	jg     800b17 <vprintfmt+0x1fb>
  800b28:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800b2b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800b2e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800b31:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800b38:	eb a1                	jmp    800adb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b3a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800b3e:	74 1b                	je     800b5b <vprintfmt+0x23f>
  800b40:	8d 50 e0             	lea    -0x20(%eax),%edx
  800b43:	83 fa 5e             	cmp    $0x5e,%edx
  800b46:	76 13                	jbe    800b5b <vprintfmt+0x23f>
					putch('?', putdat);
  800b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b56:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b59:	eb 0d                	jmp    800b68 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b62:	89 04 24             	mov    %eax,(%esp)
  800b65:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b68:	83 ef 01             	sub    $0x1,%edi
  800b6b:	0f be 06             	movsbl (%esi),%eax
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	74 05                	je     800b77 <vprintfmt+0x25b>
  800b72:	83 c6 01             	add    $0x1,%esi
  800b75:	eb 1a                	jmp    800b91 <vprintfmt+0x275>
  800b77:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800b7a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b7d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b81:	7f 1f                	jg     800ba2 <vprintfmt+0x286>
  800b83:	e9 c0 fd ff ff       	jmp    800948 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b88:	83 c6 01             	add    $0x1,%esi
  800b8b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800b8e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800b91:	85 db                	test   %ebx,%ebx
  800b93:	78 a5                	js     800b3a <vprintfmt+0x21e>
  800b95:	83 eb 01             	sub    $0x1,%ebx
  800b98:	79 a0                	jns    800b3a <vprintfmt+0x21e>
  800b9a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800b9d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800ba0:	eb db                	jmp    800b7d <vprintfmt+0x261>
  800ba2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800bab:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bae:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bb9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bbb:	83 eb 01             	sub    $0x1,%ebx
  800bbe:	85 db                	test   %ebx,%ebx
  800bc0:	7f ec                	jg     800bae <vprintfmt+0x292>
  800bc2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800bc5:	e9 81 fd ff ff       	jmp    80094b <vprintfmt+0x2f>
  800bca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bcd:	83 fe 01             	cmp    $0x1,%esi
  800bd0:	7e 10                	jle    800be2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800bd2:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd5:	8d 50 08             	lea    0x8(%eax),%edx
  800bd8:	89 55 14             	mov    %edx,0x14(%ebp)
  800bdb:	8b 18                	mov    (%eax),%ebx
  800bdd:	8b 70 04             	mov    0x4(%eax),%esi
  800be0:	eb 26                	jmp    800c08 <vprintfmt+0x2ec>
	else if (lflag)
  800be2:	85 f6                	test   %esi,%esi
  800be4:	74 12                	je     800bf8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800be6:	8b 45 14             	mov    0x14(%ebp),%eax
  800be9:	8d 50 04             	lea    0x4(%eax),%edx
  800bec:	89 55 14             	mov    %edx,0x14(%ebp)
  800bef:	8b 18                	mov    (%eax),%ebx
  800bf1:	89 de                	mov    %ebx,%esi
  800bf3:	c1 fe 1f             	sar    $0x1f,%esi
  800bf6:	eb 10                	jmp    800c08 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800bf8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfb:	8d 50 04             	lea    0x4(%eax),%edx
  800bfe:	89 55 14             	mov    %edx,0x14(%ebp)
  800c01:	8b 18                	mov    (%eax),%ebx
  800c03:	89 de                	mov    %ebx,%esi
  800c05:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800c08:	83 f9 01             	cmp    $0x1,%ecx
  800c0b:	75 1e                	jne    800c2b <vprintfmt+0x30f>
                               if((long long)num > 0){
  800c0d:	85 f6                	test   %esi,%esi
  800c0f:	78 1a                	js     800c2b <vprintfmt+0x30f>
  800c11:	85 f6                	test   %esi,%esi
  800c13:	7f 05                	jg     800c1a <vprintfmt+0x2fe>
  800c15:	83 fb 00             	cmp    $0x0,%ebx
  800c18:	76 11                	jbe    800c2b <vprintfmt+0x30f>
                                   putch('+',putdat);
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c21:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800c28:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  800c2b:	85 f6                	test   %esi,%esi
  800c2d:	78 13                	js     800c42 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c2f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800c32:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800c35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3d:	e9 da 00 00 00       	jmp    800d1c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800c42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c49:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c50:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c53:	89 da                	mov    %ebx,%edx
  800c55:	89 f1                	mov    %esi,%ecx
  800c57:	f7 da                	neg    %edx
  800c59:	83 d1 00             	adc    $0x0,%ecx
  800c5c:	f7 d9                	neg    %ecx
  800c5e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800c61:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800c64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6c:	e9 ab 00 00 00       	jmp    800d1c <vprintfmt+0x400>
  800c71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c74:	89 f2                	mov    %esi,%edx
  800c76:	8d 45 14             	lea    0x14(%ebp),%eax
  800c79:	e8 47 fc ff ff       	call   8008c5 <getuint>
  800c7e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800c81:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800c84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c87:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800c8c:	e9 8b 00 00 00       	jmp    800d1c <vprintfmt+0x400>
  800c91:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c9b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ca2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800ca5:	89 f2                	mov    %esi,%edx
  800ca7:	8d 45 14             	lea    0x14(%ebp),%eax
  800caa:	e8 16 fc ff ff       	call   8008c5 <getuint>
  800caf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800cb2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800cb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  800cbd:	eb 5d                	jmp    800d1c <vprintfmt+0x400>
  800cbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cd0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cde:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800ce1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce4:	8d 50 04             	lea    0x4(%eax),%edx
  800ce7:	89 55 14             	mov    %edx,0x14(%ebp)
  800cea:	8b 10                	mov    (%eax),%edx
  800cec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800cf4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800cf7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cfa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800cff:	eb 1b                	jmp    800d1c <vprintfmt+0x400>
  800d01:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d04:	89 f2                	mov    %esi,%edx
  800d06:	8d 45 14             	lea    0x14(%ebp),%eax
  800d09:	e8 b7 fb ff ff       	call   8008c5 <getuint>
  800d0e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800d11:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800d14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d17:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d1c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800d20:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800d23:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d26:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800d2a:	77 09                	ja     800d35 <vprintfmt+0x419>
  800d2c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800d2f:	0f 82 ac 00 00 00    	jb     800de1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800d35:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800d38:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800d3c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d3f:	83 ea 01             	sub    $0x1,%edx
  800d42:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d46:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4a:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d4e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d52:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800d55:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800d58:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800d5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d5f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d66:	00 
  800d67:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800d6a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800d6d:	89 0c 24             	mov    %ecx,(%esp)
  800d70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d74:	e8 27 23 00 00       	call   8030a0 <__udivdi3>
  800d79:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800d7c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800d7f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d83:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d87:	89 04 24             	mov    %eax,(%esp)
  800d8a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	e8 37 fa ff ff       	call   8007d0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800d99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800da7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800db2:	00 
  800db3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800db6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800db9:	89 14 24             	mov    %edx,(%esp)
  800dbc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800dc0:	e8 0b 24 00 00       	call   8031d0 <__umoddi3>
  800dc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc9:	0f be 80 9f 35 80 00 	movsbl 0x80359f(%eax),%eax
  800dd0:	89 04 24             	mov    %eax,(%esp)
  800dd3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800dd6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800dda:	74 54                	je     800e30 <vprintfmt+0x514>
  800ddc:	e9 67 fb ff ff       	jmp    800948 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800de1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800de5:	8d 76 00             	lea    0x0(%esi),%esi
  800de8:	0f 84 2a 01 00 00    	je     800f18 <vprintfmt+0x5fc>
		while (--width > 0)
  800dee:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800df1:	83 ef 01             	sub    $0x1,%edi
  800df4:	85 ff                	test   %edi,%edi
  800df6:	0f 8e 5e 01 00 00    	jle    800f5a <vprintfmt+0x63e>
  800dfc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800dff:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800e02:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800e05:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800e08:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800e0b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800e0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e12:	89 1c 24             	mov    %ebx,(%esp)
  800e15:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800e18:	83 ef 01             	sub    $0x1,%edi
  800e1b:	85 ff                	test   %edi,%edi
  800e1d:	7f ef                	jg     800e0e <vprintfmt+0x4f2>
  800e1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800e22:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800e25:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800e28:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800e2b:	e9 2a 01 00 00       	jmp    800f5a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800e30:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e33:	83 eb 01             	sub    $0x1,%ebx
  800e36:	85 db                	test   %ebx,%ebx
  800e38:	0f 8e 0a fb ff ff    	jle    800948 <vprintfmt+0x2c>
  800e3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e41:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800e44:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800e47:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e52:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800e54:	83 eb 01             	sub    $0x1,%ebx
  800e57:	85 db                	test   %ebx,%ebx
  800e59:	7f ec                	jg     800e47 <vprintfmt+0x52b>
  800e5b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800e5e:	e9 e8 fa ff ff       	jmp    80094b <vprintfmt+0x2f>
  800e63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800e66:	8b 45 14             	mov    0x14(%ebp),%eax
  800e69:	8d 50 04             	lea    0x4(%eax),%edx
  800e6c:	89 55 14             	mov    %edx,0x14(%ebp)
  800e6f:	8b 00                	mov    (%eax),%eax
  800e71:	85 c0                	test   %eax,%eax
  800e73:	75 2a                	jne    800e9f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800e75:	c7 44 24 0c d4 36 80 	movl   $0x8036d4,0xc(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 08 fe 39 80 	movl   $0x8039fe,0x8(%esp)
  800e84:	00 
  800e85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e88:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8f:	89 0c 24             	mov    %ecx,(%esp)
  800e92:	e8 90 01 00 00       	call   801027 <printfmt>
  800e97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e9a:	e9 ac fa ff ff       	jmp    80094b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800e9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea2:	8b 13                	mov    (%ebx),%edx
  800ea4:	83 fa 7f             	cmp    $0x7f,%edx
  800ea7:	7e 29                	jle    800ed2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800ea9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800eab:	c7 44 24 0c 0c 37 80 	movl   $0x80370c,0xc(%esp)
  800eb2:	00 
  800eb3:	c7 44 24 08 fe 39 80 	movl   $0x8039fe,0x8(%esp)
  800eba:	00 
  800ebb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	89 04 24             	mov    %eax,(%esp)
  800ec5:	e8 5d 01 00 00       	call   801027 <printfmt>
  800eca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ecd:	e9 79 fa ff ff       	jmp    80094b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800ed2:	88 10                	mov    %dl,(%eax)
  800ed4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ed7:	e9 6f fa ff ff       	jmp    80094b <vprintfmt+0x2f>
  800edc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800edf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ee9:	89 14 24             	mov    %edx,(%esp)
  800eec:	ff 55 08             	call   *0x8(%ebp)
  800eef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800ef2:	e9 54 fa ff ff       	jmp    80094b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ef7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800efa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800efe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800f05:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f08:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f0b:	80 38 25             	cmpb   $0x25,(%eax)
  800f0e:	0f 84 37 fa ff ff    	je     80094b <vprintfmt+0x2f>
  800f14:	89 c7                	mov    %eax,%edi
  800f16:	eb f0                	jmp    800f08 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f1f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f23:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800f26:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f2a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f31:	00 
  800f32:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800f35:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800f38:	89 04 24             	mov    %eax,(%esp)
  800f3b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f3f:	e8 8c 22 00 00       	call   8031d0 <__umoddi3>
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	0f be 80 9f 35 80 00 	movsbl 0x80359f(%eax),%eax
  800f4f:	89 04 24             	mov    %eax,(%esp)
  800f52:	ff 55 08             	call   *0x8(%ebp)
  800f55:	e9 d6 fe ff ff       	jmp    800e30 <vprintfmt+0x514>
  800f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f61:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f65:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f73:	00 
  800f74:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800f77:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800f7a:	89 04 24             	mov    %eax,(%esp)
  800f7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f81:	e8 4a 22 00 00       	call   8031d0 <__umoddi3>
  800f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8a:	0f be 80 9f 35 80 00 	movsbl 0x80359f(%eax),%eax
  800f91:	89 04 24             	mov    %eax,(%esp)
  800f94:	ff 55 08             	call   *0x8(%ebp)
  800f97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f9a:	e9 ac f9 ff ff       	jmp    80094b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800f9f:	83 c4 6c             	add    $0x6c,%esp
  800fa2:	5b                   	pop    %ebx
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 28             	sub    $0x28,%esp
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	74 04                	je     800fbb <vsnprintf+0x14>
  800fb7:	85 d2                	test   %edx,%edx
  800fb9:	7f 07                	jg     800fc2 <vsnprintf+0x1b>
  800fbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc0:	eb 3b                	jmp    800ffd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fc5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800fc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fcc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800fd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fda:	8b 45 10             	mov    0x10(%ebp),%eax
  800fdd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe8:	c7 04 24 ff 08 80 00 	movl   $0x8008ff,(%esp)
  800fef:	e8 28 f9 ff ff       	call   80091c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ff7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    

00800fff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801005:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801008:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80100c:	8b 45 10             	mov    0x10(%ebp),%eax
  80100f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801013:	8b 45 0c             	mov    0xc(%ebp),%eax
  801016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101a:	8b 45 08             	mov    0x8(%ebp),%eax
  80101d:	89 04 24             	mov    %eax,(%esp)
  801020:	e8 82 ff ff ff       	call   800fa7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80102d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801030:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801034:	8b 45 10             	mov    0x10(%ebp),%eax
  801037:	89 44 24 08          	mov    %eax,0x8(%esp)
  80103b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	89 04 24             	mov    %eax,(%esp)
  801048:	e8 cf f8 ff ff       	call   80091c <vprintfmt>
	va_end(ap);
}
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    
	...

00801050 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801056:	b8 00 00 00 00       	mov    $0x0,%eax
  80105b:	80 3a 00             	cmpb   $0x0,(%edx)
  80105e:	74 09                	je     801069 <strlen+0x19>
		n++;
  801060:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801063:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801067:	75 f7                	jne    801060 <strlen+0x10>
		n++;
	return n;
}
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	53                   	push   %ebx
  80106f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801072:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801075:	85 c9                	test   %ecx,%ecx
  801077:	74 19                	je     801092 <strnlen+0x27>
  801079:	80 3b 00             	cmpb   $0x0,(%ebx)
  80107c:	74 14                	je     801092 <strnlen+0x27>
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801083:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801086:	39 c8                	cmp    %ecx,%eax
  801088:	74 0d                	je     801097 <strnlen+0x2c>
  80108a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80108e:	75 f3                	jne    801083 <strnlen+0x18>
  801090:	eb 05                	jmp    801097 <strnlen+0x2c>
  801092:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801097:	5b                   	pop    %ebx
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	53                   	push   %ebx
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010a4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8010a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8010ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8010b0:	83 c2 01             	add    $0x1,%edx
  8010b3:	84 c9                	test   %cl,%cl
  8010b5:	75 f2                	jne    8010a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8010b7:	5b                   	pop    %ebx
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 08             	sub    $0x8,%esp
  8010c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8010c4:	89 1c 24             	mov    %ebx,(%esp)
  8010c7:	e8 84 ff ff ff       	call   801050 <strlen>
	strcpy(dst + len, src);
  8010cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010cf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010d3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8010d6:	89 04 24             	mov    %eax,(%esp)
  8010d9:	e8 bc ff ff ff       	call   80109a <strcpy>
	return dst;
}
  8010de:	89 d8                	mov    %ebx,%eax
  8010e0:	83 c4 08             	add    $0x8,%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010f4:	85 f6                	test   %esi,%esi
  8010f6:	74 18                	je     801110 <strncpy+0x2a>
  8010f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8010fd:	0f b6 1a             	movzbl (%edx),%ebx
  801100:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801103:	80 3a 01             	cmpb   $0x1,(%edx)
  801106:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801109:	83 c1 01             	add    $0x1,%ecx
  80110c:	39 ce                	cmp    %ecx,%esi
  80110e:	77 ed                	ja     8010fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
  801119:	8b 75 08             	mov    0x8(%ebp),%esi
  80111c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801122:	89 f0                	mov    %esi,%eax
  801124:	85 c9                	test   %ecx,%ecx
  801126:	74 27                	je     80114f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801128:	83 e9 01             	sub    $0x1,%ecx
  80112b:	74 1d                	je     80114a <strlcpy+0x36>
  80112d:	0f b6 1a             	movzbl (%edx),%ebx
  801130:	84 db                	test   %bl,%bl
  801132:	74 16                	je     80114a <strlcpy+0x36>
			*dst++ = *src++;
  801134:	88 18                	mov    %bl,(%eax)
  801136:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801139:	83 e9 01             	sub    $0x1,%ecx
  80113c:	74 0e                	je     80114c <strlcpy+0x38>
			*dst++ = *src++;
  80113e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801141:	0f b6 1a             	movzbl (%edx),%ebx
  801144:	84 db                	test   %bl,%bl
  801146:	75 ec                	jne    801134 <strlcpy+0x20>
  801148:	eb 02                	jmp    80114c <strlcpy+0x38>
  80114a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80114c:	c6 00 00             	movb   $0x0,(%eax)
  80114f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80115e:	0f b6 01             	movzbl (%ecx),%eax
  801161:	84 c0                	test   %al,%al
  801163:	74 15                	je     80117a <strcmp+0x25>
  801165:	3a 02                	cmp    (%edx),%al
  801167:	75 11                	jne    80117a <strcmp+0x25>
		p++, q++;
  801169:	83 c1 01             	add    $0x1,%ecx
  80116c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80116f:	0f b6 01             	movzbl (%ecx),%eax
  801172:	84 c0                	test   %al,%al
  801174:	74 04                	je     80117a <strcmp+0x25>
  801176:	3a 02                	cmp    (%edx),%al
  801178:	74 ef                	je     801169 <strcmp+0x14>
  80117a:	0f b6 c0             	movzbl %al,%eax
  80117d:	0f b6 12             	movzbl (%edx),%edx
  801180:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	53                   	push   %ebx
  801188:	8b 55 08             	mov    0x8(%ebp),%edx
  80118b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801191:	85 c0                	test   %eax,%eax
  801193:	74 23                	je     8011b8 <strncmp+0x34>
  801195:	0f b6 1a             	movzbl (%edx),%ebx
  801198:	84 db                	test   %bl,%bl
  80119a:	74 25                	je     8011c1 <strncmp+0x3d>
  80119c:	3a 19                	cmp    (%ecx),%bl
  80119e:	75 21                	jne    8011c1 <strncmp+0x3d>
  8011a0:	83 e8 01             	sub    $0x1,%eax
  8011a3:	74 13                	je     8011b8 <strncmp+0x34>
		n--, p++, q++;
  8011a5:	83 c2 01             	add    $0x1,%edx
  8011a8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8011ab:	0f b6 1a             	movzbl (%edx),%ebx
  8011ae:	84 db                	test   %bl,%bl
  8011b0:	74 0f                	je     8011c1 <strncmp+0x3d>
  8011b2:	3a 19                	cmp    (%ecx),%bl
  8011b4:	74 ea                	je     8011a0 <strncmp+0x1c>
  8011b6:	eb 09                	jmp    8011c1 <strncmp+0x3d>
  8011b8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8011bd:	5b                   	pop    %ebx
  8011be:	5d                   	pop    %ebp
  8011bf:	90                   	nop
  8011c0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8011c1:	0f b6 02             	movzbl (%edx),%eax
  8011c4:	0f b6 11             	movzbl (%ecx),%edx
  8011c7:	29 d0                	sub    %edx,%eax
  8011c9:	eb f2                	jmp    8011bd <strncmp+0x39>

008011cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8011d5:	0f b6 10             	movzbl (%eax),%edx
  8011d8:	84 d2                	test   %dl,%dl
  8011da:	74 18                	je     8011f4 <strchr+0x29>
		if (*s == c)
  8011dc:	38 ca                	cmp    %cl,%dl
  8011de:	75 0a                	jne    8011ea <strchr+0x1f>
  8011e0:	eb 17                	jmp    8011f9 <strchr+0x2e>
  8011e2:	38 ca                	cmp    %cl,%dl
  8011e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	74 0f                	je     8011f9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8011ea:	83 c0 01             	add    $0x1,%eax
  8011ed:	0f b6 10             	movzbl (%eax),%edx
  8011f0:	84 d2                	test   %dl,%dl
  8011f2:	75 ee                	jne    8011e2 <strchr+0x17>
  8011f4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801201:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801205:	0f b6 10             	movzbl (%eax),%edx
  801208:	84 d2                	test   %dl,%dl
  80120a:	74 18                	je     801224 <strfind+0x29>
		if (*s == c)
  80120c:	38 ca                	cmp    %cl,%dl
  80120e:	75 0a                	jne    80121a <strfind+0x1f>
  801210:	eb 12                	jmp    801224 <strfind+0x29>
  801212:	38 ca                	cmp    %cl,%dl
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	74 0a                	je     801224 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80121a:	83 c0 01             	add    $0x1,%eax
  80121d:	0f b6 10             	movzbl (%eax),%edx
  801220:	84 d2                	test   %dl,%dl
  801222:	75 ee                	jne    801212 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	83 ec 0c             	sub    $0xc,%esp
  80122c:	89 1c 24             	mov    %ebx,(%esp)
  80122f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801233:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801237:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801240:	85 c9                	test   %ecx,%ecx
  801242:	74 30                	je     801274 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801244:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80124a:	75 25                	jne    801271 <memset+0x4b>
  80124c:	f6 c1 03             	test   $0x3,%cl
  80124f:	75 20                	jne    801271 <memset+0x4b>
		c &= 0xFF;
  801251:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801254:	89 d3                	mov    %edx,%ebx
  801256:	c1 e3 08             	shl    $0x8,%ebx
  801259:	89 d6                	mov    %edx,%esi
  80125b:	c1 e6 18             	shl    $0x18,%esi
  80125e:	89 d0                	mov    %edx,%eax
  801260:	c1 e0 10             	shl    $0x10,%eax
  801263:	09 f0                	or     %esi,%eax
  801265:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801267:	09 d8                	or     %ebx,%eax
  801269:	c1 e9 02             	shr    $0x2,%ecx
  80126c:	fc                   	cld    
  80126d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80126f:	eb 03                	jmp    801274 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801271:	fc                   	cld    
  801272:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801274:	89 f8                	mov    %edi,%eax
  801276:	8b 1c 24             	mov    (%esp),%ebx
  801279:	8b 74 24 04          	mov    0x4(%esp),%esi
  80127d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801281:	89 ec                	mov    %ebp,%esp
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	89 34 24             	mov    %esi,(%esp)
  80128e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801298:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80129b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80129d:	39 c6                	cmp    %eax,%esi
  80129f:	73 35                	jae    8012d6 <memmove+0x51>
  8012a1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8012a4:	39 d0                	cmp    %edx,%eax
  8012a6:	73 2e                	jae    8012d6 <memmove+0x51>
		s += n;
		d += n;
  8012a8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012aa:	f6 c2 03             	test   $0x3,%dl
  8012ad:	75 1b                	jne    8012ca <memmove+0x45>
  8012af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012b5:	75 13                	jne    8012ca <memmove+0x45>
  8012b7:	f6 c1 03             	test   $0x3,%cl
  8012ba:	75 0e                	jne    8012ca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8012bc:	83 ef 04             	sub    $0x4,%edi
  8012bf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8012c2:	c1 e9 02             	shr    $0x2,%ecx
  8012c5:	fd                   	std    
  8012c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012c8:	eb 09                	jmp    8012d3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8012ca:	83 ef 01             	sub    $0x1,%edi
  8012cd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8012d0:	fd                   	std    
  8012d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8012d3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8012d4:	eb 20                	jmp    8012f6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8012dc:	75 15                	jne    8012f3 <memmove+0x6e>
  8012de:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012e4:	75 0d                	jne    8012f3 <memmove+0x6e>
  8012e6:	f6 c1 03             	test   $0x3,%cl
  8012e9:	75 08                	jne    8012f3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8012eb:	c1 e9 02             	shr    $0x2,%ecx
  8012ee:	fc                   	cld    
  8012ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012f1:	eb 03                	jmp    8012f6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8012f3:	fc                   	cld    
  8012f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8012f6:	8b 34 24             	mov    (%esp),%esi
  8012f9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012fd:	89 ec                	mov    %ebp,%esp
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801307:	8b 45 10             	mov    0x10(%ebp),%eax
  80130a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801311:	89 44 24 04          	mov    %eax,0x4(%esp)
  801315:	8b 45 08             	mov    0x8(%ebp),%eax
  801318:	89 04 24             	mov    %eax,(%esp)
  80131b:	e8 65 ff ff ff       	call   801285 <memmove>
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	8b 75 08             	mov    0x8(%ebp),%esi
  80132b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80132e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801331:	85 c9                	test   %ecx,%ecx
  801333:	74 36                	je     80136b <memcmp+0x49>
		if (*s1 != *s2)
  801335:	0f b6 06             	movzbl (%esi),%eax
  801338:	0f b6 1f             	movzbl (%edi),%ebx
  80133b:	38 d8                	cmp    %bl,%al
  80133d:	74 20                	je     80135f <memcmp+0x3d>
  80133f:	eb 14                	jmp    801355 <memcmp+0x33>
  801341:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801346:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80134b:	83 c2 01             	add    $0x1,%edx
  80134e:	83 e9 01             	sub    $0x1,%ecx
  801351:	38 d8                	cmp    %bl,%al
  801353:	74 12                	je     801367 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801355:	0f b6 c0             	movzbl %al,%eax
  801358:	0f b6 db             	movzbl %bl,%ebx
  80135b:	29 d8                	sub    %ebx,%eax
  80135d:	eb 11                	jmp    801370 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80135f:	83 e9 01             	sub    $0x1,%ecx
  801362:	ba 00 00 00 00       	mov    $0x0,%edx
  801367:	85 c9                	test   %ecx,%ecx
  801369:	75 d6                	jne    801341 <memcmp+0x1f>
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801380:	39 d0                	cmp    %edx,%eax
  801382:	73 15                	jae    801399 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801384:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801388:	38 08                	cmp    %cl,(%eax)
  80138a:	75 06                	jne    801392 <memfind+0x1d>
  80138c:	eb 0b                	jmp    801399 <memfind+0x24>
  80138e:	38 08                	cmp    %cl,(%eax)
  801390:	74 07                	je     801399 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801392:	83 c0 01             	add    $0x1,%eax
  801395:	39 c2                	cmp    %eax,%edx
  801397:	77 f5                	ja     80138e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	57                   	push   %edi
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013aa:	0f b6 02             	movzbl (%edx),%eax
  8013ad:	3c 20                	cmp    $0x20,%al
  8013af:	74 04                	je     8013b5 <strtol+0x1a>
  8013b1:	3c 09                	cmp    $0x9,%al
  8013b3:	75 0e                	jne    8013c3 <strtol+0x28>
		s++;
  8013b5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013b8:	0f b6 02             	movzbl (%edx),%eax
  8013bb:	3c 20                	cmp    $0x20,%al
  8013bd:	74 f6                	je     8013b5 <strtol+0x1a>
  8013bf:	3c 09                	cmp    $0x9,%al
  8013c1:	74 f2                	je     8013b5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013c3:	3c 2b                	cmp    $0x2b,%al
  8013c5:	75 0c                	jne    8013d3 <strtol+0x38>
		s++;
  8013c7:	83 c2 01             	add    $0x1,%edx
  8013ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8013d1:	eb 15                	jmp    8013e8 <strtol+0x4d>
	else if (*s == '-')
  8013d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8013da:	3c 2d                	cmp    $0x2d,%al
  8013dc:	75 0a                	jne    8013e8 <strtol+0x4d>
		s++, neg = 1;
  8013de:	83 c2 01             	add    $0x1,%edx
  8013e1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8013e8:	85 db                	test   %ebx,%ebx
  8013ea:	0f 94 c0             	sete   %al
  8013ed:	74 05                	je     8013f4 <strtol+0x59>
  8013ef:	83 fb 10             	cmp    $0x10,%ebx
  8013f2:	75 18                	jne    80140c <strtol+0x71>
  8013f4:	80 3a 30             	cmpb   $0x30,(%edx)
  8013f7:	75 13                	jne    80140c <strtol+0x71>
  8013f9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	75 0a                	jne    80140c <strtol+0x71>
		s += 2, base = 16;
  801402:	83 c2 02             	add    $0x2,%edx
  801405:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80140a:	eb 15                	jmp    801421 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80140c:	84 c0                	test   %al,%al
  80140e:	66 90                	xchg   %ax,%ax
  801410:	74 0f                	je     801421 <strtol+0x86>
  801412:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801417:	80 3a 30             	cmpb   $0x30,(%edx)
  80141a:	75 05                	jne    801421 <strtol+0x86>
		s++, base = 8;
  80141c:	83 c2 01             	add    $0x1,%edx
  80141f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801421:	b8 00 00 00 00       	mov    $0x0,%eax
  801426:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801428:	0f b6 0a             	movzbl (%edx),%ecx
  80142b:	89 cf                	mov    %ecx,%edi
  80142d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801430:	80 fb 09             	cmp    $0x9,%bl
  801433:	77 08                	ja     80143d <strtol+0xa2>
			dig = *s - '0';
  801435:	0f be c9             	movsbl %cl,%ecx
  801438:	83 e9 30             	sub    $0x30,%ecx
  80143b:	eb 1e                	jmp    80145b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80143d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801440:	80 fb 19             	cmp    $0x19,%bl
  801443:	77 08                	ja     80144d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801445:	0f be c9             	movsbl %cl,%ecx
  801448:	83 e9 57             	sub    $0x57,%ecx
  80144b:	eb 0e                	jmp    80145b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80144d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801450:	80 fb 19             	cmp    $0x19,%bl
  801453:	77 15                	ja     80146a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801455:	0f be c9             	movsbl %cl,%ecx
  801458:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80145b:	39 f1                	cmp    %esi,%ecx
  80145d:	7d 0b                	jge    80146a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80145f:	83 c2 01             	add    $0x1,%edx
  801462:	0f af c6             	imul   %esi,%eax
  801465:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801468:	eb be                	jmp    801428 <strtol+0x8d>
  80146a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80146c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801470:	74 05                	je     801477 <strtol+0xdc>
		*endptr = (char *) s;
  801472:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801475:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801477:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80147b:	74 04                	je     801481 <strtol+0xe6>
  80147d:	89 c8                	mov    %ecx,%eax
  80147f:	f7 d8                	neg    %eax
}
  801481:	83 c4 04             	add    $0x4,%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    
  801489:	00 00                	add    %al,(%eax)
	...

0080148c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	89 1c 24             	mov    %ebx,(%esp)
  801495:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801499:	ba 00 00 00 00       	mov    $0x0,%edx
  80149e:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a3:	89 d1                	mov    %edx,%ecx
  8014a5:	89 d3                	mov    %edx,%ebx
  8014a7:	89 d7                	mov    %edx,%edi
  8014a9:	51                   	push   %ecx
  8014aa:	52                   	push   %edx
  8014ab:	53                   	push   %ebx
  8014ac:	54                   	push   %esp
  8014ad:	55                   	push   %ebp
  8014ae:	56                   	push   %esi
  8014af:	57                   	push   %edi
  8014b0:	54                   	push   %esp
  8014b1:	5d                   	pop    %ebp
  8014b2:	8d 35 ba 14 80 00    	lea    0x8014ba,%esi
  8014b8:	0f 34                	sysenter 
  8014ba:	5f                   	pop    %edi
  8014bb:	5e                   	pop    %esi
  8014bc:	5d                   	pop    %ebp
  8014bd:	5c                   	pop    %esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5a                   	pop    %edx
  8014c0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014c1:	8b 1c 24             	mov    (%esp),%ebx
  8014c4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014c8:	89 ec                	mov    %ebp,%esp
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	89 1c 24             	mov    %ebx,(%esp)
  8014d5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	89 c7                	mov    %eax,%edi
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

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801500:	8b 1c 24             	mov    (%esp),%ebx
  801503:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801507:	89 ec                	mov    %ebp,%esp
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	89 1c 24             	mov    %ebx,(%esp)
  801514:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801518:	b9 00 00 00 00       	mov    $0x0,%ecx
  80151d:	b8 13 00 00 00       	mov    $0x13,%eax
  801522:	8b 55 08             	mov    0x8(%ebp),%edx
  801525:	89 cb                	mov    %ecx,%ebx
  801527:	89 cf                	mov    %ecx,%edi
  801529:	51                   	push   %ecx
  80152a:	52                   	push   %edx
  80152b:	53                   	push   %ebx
  80152c:	54                   	push   %esp
  80152d:	55                   	push   %ebp
  80152e:	56                   	push   %esi
  80152f:	57                   	push   %edi
  801530:	54                   	push   %esp
  801531:	5d                   	pop    %ebp
  801532:	8d 35 3a 15 80 00    	lea    0x80153a,%esi
  801538:	0f 34                	sysenter 
  80153a:	5f                   	pop    %edi
  80153b:	5e                   	pop    %esi
  80153c:	5d                   	pop    %ebp
  80153d:	5c                   	pop    %esp
  80153e:	5b                   	pop    %ebx
  80153f:	5a                   	pop    %edx
  801540:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801541:	8b 1c 24             	mov    (%esp),%ebx
  801544:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801548:	89 ec                	mov    %ebp,%esp
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	89 1c 24             	mov    %ebx,(%esp)
  801555:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801559:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155e:	b8 12 00 00 00       	mov    $0x12,%eax
  801563:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801566:	8b 55 08             	mov    0x8(%ebp),%edx
  801569:	89 df                	mov    %ebx,%edi
  80156b:	51                   	push   %ecx
  80156c:	52                   	push   %edx
  80156d:	53                   	push   %ebx
  80156e:	54                   	push   %esp
  80156f:	55                   	push   %ebp
  801570:	56                   	push   %esi
  801571:	57                   	push   %edi
  801572:	54                   	push   %esp
  801573:	5d                   	pop    %ebp
  801574:	8d 35 7c 15 80 00    	lea    0x80157c,%esi
  80157a:	0f 34                	sysenter 
  80157c:	5f                   	pop    %edi
  80157d:	5e                   	pop    %esi
  80157e:	5d                   	pop    %ebp
  80157f:	5c                   	pop    %esp
  801580:	5b                   	pop    %ebx
  801581:	5a                   	pop    %edx
  801582:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801583:	8b 1c 24             	mov    (%esp),%ebx
  801586:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80158a:	89 ec                	mov    %ebp,%esp
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	89 1c 24             	mov    %ebx,(%esp)
  801597:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80159b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a0:	b8 11 00 00 00       	mov    $0x11,%eax
  8015a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ab:	89 df                	mov    %ebx,%edi
  8015ad:	51                   	push   %ecx
  8015ae:	52                   	push   %edx
  8015af:	53                   	push   %ebx
  8015b0:	54                   	push   %esp
  8015b1:	55                   	push   %ebp
  8015b2:	56                   	push   %esi
  8015b3:	57                   	push   %edi
  8015b4:	54                   	push   %esp
  8015b5:	5d                   	pop    %ebp
  8015b6:	8d 35 be 15 80 00    	lea    0x8015be,%esi
  8015bc:	0f 34                	sysenter 
  8015be:	5f                   	pop    %edi
  8015bf:	5e                   	pop    %esi
  8015c0:	5d                   	pop    %ebp
  8015c1:	5c                   	pop    %esp
  8015c2:	5b                   	pop    %ebx
  8015c3:	5a                   	pop    %edx
  8015c4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8015c5:	8b 1c 24             	mov    (%esp),%ebx
  8015c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015cc:	89 ec                	mov    %ebp,%esp
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	89 1c 24             	mov    %ebx,(%esp)
  8015d9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ee:	51                   	push   %ecx
  8015ef:	52                   	push   %edx
  8015f0:	53                   	push   %ebx
  8015f1:	54                   	push   %esp
  8015f2:	55                   	push   %ebp
  8015f3:	56                   	push   %esi
  8015f4:	57                   	push   %edi
  8015f5:	54                   	push   %esp
  8015f6:	5d                   	pop    %ebp
  8015f7:	8d 35 ff 15 80 00    	lea    0x8015ff,%esi
  8015fd:	0f 34                	sysenter 
  8015ff:	5f                   	pop    %edi
  801600:	5e                   	pop    %esi
  801601:	5d                   	pop    %ebp
  801602:	5c                   	pop    %esp
  801603:	5b                   	pop    %ebx
  801604:	5a                   	pop    %edx
  801605:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801606:	8b 1c 24             	mov    (%esp),%ebx
  801609:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80160d:	89 ec                	mov    %ebp,%esp
  80160f:	5d                   	pop    %ebp
  801610:	c3                   	ret    

00801611 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	83 ec 28             	sub    $0x28,%esp
  801617:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80161a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80161d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801622:	b8 0f 00 00 00       	mov    $0xf,%eax
  801627:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162a:	8b 55 08             	mov    0x8(%ebp),%edx
  80162d:	89 df                	mov    %ebx,%edi
  80162f:	51                   	push   %ecx
  801630:	52                   	push   %edx
  801631:	53                   	push   %ebx
  801632:	54                   	push   %esp
  801633:	55                   	push   %ebp
  801634:	56                   	push   %esi
  801635:	57                   	push   %edi
  801636:	54                   	push   %esp
  801637:	5d                   	pop    %ebp
  801638:	8d 35 40 16 80 00    	lea    0x801640,%esi
  80163e:	0f 34                	sysenter 
  801640:	5f                   	pop    %edi
  801641:	5e                   	pop    %esi
  801642:	5d                   	pop    %ebp
  801643:	5c                   	pop    %esp
  801644:	5b                   	pop    %ebx
  801645:	5a                   	pop    %edx
  801646:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801647:	85 c0                	test   %eax,%eax
  801649:	7e 28                	jle    801673 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80164b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80164f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801656:	00 
  801657:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  80165e:	00 
  80165f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801666:	00 
  801667:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  80166e:	e8 39 f0 ff ff       	call   8006ac <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801673:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801676:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801679:	89 ec                	mov    %ebp,%esp
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	89 1c 24             	mov    %ebx,(%esp)
  801686:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80168a:	ba 00 00 00 00       	mov    $0x0,%edx
  80168f:	b8 15 00 00 00       	mov    $0x15,%eax
  801694:	89 d1                	mov    %edx,%ecx
  801696:	89 d3                	mov    %edx,%ebx
  801698:	89 d7                	mov    %edx,%edi
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

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8016b2:	8b 1c 24             	mov    (%esp),%ebx
  8016b5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016b9:	89 ec                	mov    %ebp,%esp
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	89 1c 24             	mov    %ebx,(%esp)
  8016c6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8016ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016cf:	b8 14 00 00 00       	mov    $0x14,%eax
  8016d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d7:	89 cb                	mov    %ecx,%ebx
  8016d9:	89 cf                	mov    %ecx,%edi
  8016db:	51                   	push   %ecx
  8016dc:	52                   	push   %edx
  8016dd:	53                   	push   %ebx
  8016de:	54                   	push   %esp
  8016df:	55                   	push   %ebp
  8016e0:	56                   	push   %esi
  8016e1:	57                   	push   %edi
  8016e2:	54                   	push   %esp
  8016e3:	5d                   	pop    %ebp
  8016e4:	8d 35 ec 16 80 00    	lea    0x8016ec,%esi
  8016ea:	0f 34                	sysenter 
  8016ec:	5f                   	pop    %edi
  8016ed:	5e                   	pop    %esi
  8016ee:	5d                   	pop    %ebp
  8016ef:	5c                   	pop    %esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5a                   	pop    %edx
  8016f2:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8016f3:	8b 1c 24             	mov    (%esp),%ebx
  8016f6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016fa:	89 ec                	mov    %ebp,%esp
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	83 ec 28             	sub    $0x28,%esp
  801704:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801707:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80170a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80170f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801714:	8b 55 08             	mov    0x8(%ebp),%edx
  801717:	89 cb                	mov    %ecx,%ebx
  801719:	89 cf                	mov    %ecx,%edi
  80171b:	51                   	push   %ecx
  80171c:	52                   	push   %edx
  80171d:	53                   	push   %ebx
  80171e:	54                   	push   %esp
  80171f:	55                   	push   %ebp
  801720:	56                   	push   %esi
  801721:	57                   	push   %edi
  801722:	54                   	push   %esp
  801723:	5d                   	pop    %ebp
  801724:	8d 35 2c 17 80 00    	lea    0x80172c,%esi
  80172a:	0f 34                	sysenter 
  80172c:	5f                   	pop    %edi
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	5c                   	pop    %esp
  801730:	5b                   	pop    %ebx
  801731:	5a                   	pop    %edx
  801732:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801733:	85 c0                	test   %eax,%eax
  801735:	7e 28                	jle    80175f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801737:	89 44 24 10          	mov    %eax,0x10(%esp)
  80173b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801742:	00 
  801743:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  80174a:	00 
  80174b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801752:	00 
  801753:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  80175a:	e8 4d ef ff ff       	call   8006ac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80175f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801762:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801765:	89 ec                	mov    %ebp,%esp
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	89 1c 24             	mov    %ebx,(%esp)
  801772:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801776:	b8 0d 00 00 00       	mov    $0xd,%eax
  80177b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80177e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801784:	8b 55 08             	mov    0x8(%ebp),%edx
  801787:	51                   	push   %ecx
  801788:	52                   	push   %edx
  801789:	53                   	push   %ebx
  80178a:	54                   	push   %esp
  80178b:	55                   	push   %ebp
  80178c:	56                   	push   %esi
  80178d:	57                   	push   %edi
  80178e:	54                   	push   %esp
  80178f:	5d                   	pop    %ebp
  801790:	8d 35 98 17 80 00    	lea    0x801798,%esi
  801796:	0f 34                	sysenter 
  801798:	5f                   	pop    %edi
  801799:	5e                   	pop    %esi
  80179a:	5d                   	pop    %ebp
  80179b:	5c                   	pop    %esp
  80179c:	5b                   	pop    %ebx
  80179d:	5a                   	pop    %edx
  80179e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80179f:	8b 1c 24             	mov    (%esp),%ebx
  8017a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017a6:	89 ec                	mov    %ebp,%esp
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 28             	sub    $0x28,%esp
  8017b0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017b3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8017b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017bb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8017c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c6:	89 df                	mov    %ebx,%edi
  8017c8:	51                   	push   %ecx
  8017c9:	52                   	push   %edx
  8017ca:	53                   	push   %ebx
  8017cb:	54                   	push   %esp
  8017cc:	55                   	push   %ebp
  8017cd:	56                   	push   %esi
  8017ce:	57                   	push   %edi
  8017cf:	54                   	push   %esp
  8017d0:	5d                   	pop    %ebp
  8017d1:	8d 35 d9 17 80 00    	lea    0x8017d9,%esi
  8017d7:	0f 34                	sysenter 
  8017d9:	5f                   	pop    %edi
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	5c                   	pop    %esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5a                   	pop    %edx
  8017df:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	7e 28                	jle    80180c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017e8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8017ef:	00 
  8017f0:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  8017f7:	00 
  8017f8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8017ff:	00 
  801800:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  801807:	e8 a0 ee ff ff       	call   8006ac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80180c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80180f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801812:	89 ec                	mov    %ebp,%esp
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	83 ec 28             	sub    $0x28,%esp
  80181c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80181f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801822:	bb 00 00 00 00       	mov    $0x0,%ebx
  801827:	b8 0a 00 00 00       	mov    $0xa,%eax
  80182c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182f:	8b 55 08             	mov    0x8(%ebp),%edx
  801832:	89 df                	mov    %ebx,%edi
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
  80184e:	7e 28                	jle    801878 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801850:	89 44 24 10          	mov    %eax,0x10(%esp)
  801854:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80185b:	00 
  80185c:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  801863:	00 
  801864:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80186b:	00 
  80186c:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  801873:	e8 34 ee ff ff       	call   8006ac <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801878:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80187b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80187e:	89 ec                	mov    %ebp,%esp
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	83 ec 28             	sub    $0x28,%esp
  801888:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80188b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80188e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801893:	b8 09 00 00 00       	mov    $0x9,%eax
  801898:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189b:	8b 55 08             	mov    0x8(%ebp),%edx
  80189e:	89 df                	mov    %ebx,%edi
  8018a0:	51                   	push   %ecx
  8018a1:	52                   	push   %edx
  8018a2:	53                   	push   %ebx
  8018a3:	54                   	push   %esp
  8018a4:	55                   	push   %ebp
  8018a5:	56                   	push   %esi
  8018a6:	57                   	push   %edi
  8018a7:	54                   	push   %esp
  8018a8:	5d                   	pop    %ebp
  8018a9:	8d 35 b1 18 80 00    	lea    0x8018b1,%esi
  8018af:	0f 34                	sysenter 
  8018b1:	5f                   	pop    %edi
  8018b2:	5e                   	pop    %esi
  8018b3:	5d                   	pop    %ebp
  8018b4:	5c                   	pop    %esp
  8018b5:	5b                   	pop    %ebx
  8018b6:	5a                   	pop    %edx
  8018b7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	7e 28                	jle    8018e4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018c0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8018c7:	00 
  8018c8:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  8018cf:	00 
  8018d0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8018d7:	00 
  8018d8:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  8018df:	e8 c8 ed ff ff       	call   8006ac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8018e4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018e7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018ea:	89 ec                	mov    %ebp,%esp
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	83 ec 28             	sub    $0x28,%esp
  8018f4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018f7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8018fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ff:	b8 07 00 00 00       	mov    $0x7,%eax
  801904:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801907:	8b 55 08             	mov    0x8(%ebp),%edx
  80190a:	89 df                	mov    %ebx,%edi
  80190c:	51                   	push   %ecx
  80190d:	52                   	push   %edx
  80190e:	53                   	push   %ebx
  80190f:	54                   	push   %esp
  801910:	55                   	push   %ebp
  801911:	56                   	push   %esi
  801912:	57                   	push   %edi
  801913:	54                   	push   %esp
  801914:	5d                   	pop    %ebp
  801915:	8d 35 1d 19 80 00    	lea    0x80191d,%esi
  80191b:	0f 34                	sysenter 
  80191d:	5f                   	pop    %edi
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	5c                   	pop    %esp
  801921:	5b                   	pop    %ebx
  801922:	5a                   	pop    %edx
  801923:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801924:	85 c0                	test   %eax,%eax
  801926:	7e 28                	jle    801950 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801928:	89 44 24 10          	mov    %eax,0x10(%esp)
  80192c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801933:	00 
  801934:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  80193b:	00 
  80193c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801943:	00 
  801944:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  80194b:	e8 5c ed ff ff       	call   8006ac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801950:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801953:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801956:	89 ec                	mov    %ebp,%esp
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 28             	sub    $0x28,%esp
  801960:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801963:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801966:	8b 7d 18             	mov    0x18(%ebp),%edi
  801969:	0b 7d 14             	or     0x14(%ebp),%edi
  80196c:	b8 06 00 00 00       	mov    $0x6,%eax
  801971:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801974:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801977:	8b 55 08             	mov    0x8(%ebp),%edx
  80197a:	51                   	push   %ecx
  80197b:	52                   	push   %edx
  80197c:	53                   	push   %ebx
  80197d:	54                   	push   %esp
  80197e:	55                   	push   %ebp
  80197f:	56                   	push   %esi
  801980:	57                   	push   %edi
  801981:	54                   	push   %esp
  801982:	5d                   	pop    %ebp
  801983:	8d 35 8b 19 80 00    	lea    0x80198b,%esi
  801989:	0f 34                	sysenter 
  80198b:	5f                   	pop    %edi
  80198c:	5e                   	pop    %esi
  80198d:	5d                   	pop    %ebp
  80198e:	5c                   	pop    %esp
  80198f:	5b                   	pop    %ebx
  801990:	5a                   	pop    %edx
  801991:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801992:	85 c0                	test   %eax,%eax
  801994:	7e 28                	jle    8019be <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801996:	89 44 24 10          	mov    %eax,0x10(%esp)
  80199a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8019a1:	00 
  8019a2:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  8019a9:	00 
  8019aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8019b1:	00 
  8019b2:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  8019b9:	e8 ee ec ff ff       	call   8006ac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8019be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019c4:	89 ec                	mov    %ebp,%esp
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 28             	sub    $0x28,%esp
  8019ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019d1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8019d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8019de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8019e7:	51                   	push   %ecx
  8019e8:	52                   	push   %edx
  8019e9:	53                   	push   %ebx
  8019ea:	54                   	push   %esp
  8019eb:	55                   	push   %ebp
  8019ec:	56                   	push   %esi
  8019ed:	57                   	push   %edi
  8019ee:	54                   	push   %esp
  8019ef:	5d                   	pop    %ebp
  8019f0:	8d 35 f8 19 80 00    	lea    0x8019f8,%esi
  8019f6:	0f 34                	sysenter 
  8019f8:	5f                   	pop    %edi
  8019f9:	5e                   	pop    %esi
  8019fa:	5d                   	pop    %ebp
  8019fb:	5c                   	pop    %esp
  8019fc:	5b                   	pop    %ebx
  8019fd:	5a                   	pop    %edx
  8019fe:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	7e 28                	jle    801a2b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801a03:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a07:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801a0e:	00 
  801a0f:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  801a16:	00 
  801a17:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801a1e:	00 
  801a1f:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  801a26:	e8 81 ec ff ff       	call   8006ac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801a2b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a31:	89 ec                	mov    %ebp,%esp
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	89 1c 24             	mov    %ebx,(%esp)
  801a3e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801a42:	ba 00 00 00 00       	mov    $0x0,%edx
  801a47:	b8 0c 00 00 00       	mov    $0xc,%eax
  801a4c:	89 d1                	mov    %edx,%ecx
  801a4e:	89 d3                	mov    %edx,%ebx
  801a50:	89 d7                	mov    %edx,%edi
  801a52:	51                   	push   %ecx
  801a53:	52                   	push   %edx
  801a54:	53                   	push   %ebx
  801a55:	54                   	push   %esp
  801a56:	55                   	push   %ebp
  801a57:	56                   	push   %esi
  801a58:	57                   	push   %edi
  801a59:	54                   	push   %esp
  801a5a:	5d                   	pop    %ebp
  801a5b:	8d 35 63 1a 80 00    	lea    0x801a63,%esi
  801a61:	0f 34                	sysenter 
  801a63:	5f                   	pop    %edi
  801a64:	5e                   	pop    %esi
  801a65:	5d                   	pop    %ebp
  801a66:	5c                   	pop    %esp
  801a67:	5b                   	pop    %ebx
  801a68:	5a                   	pop    %edx
  801a69:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801a6a:	8b 1c 24             	mov    (%esp),%ebx
  801a6d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a71:	89 ec                	mov    %ebp,%esp
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	83 ec 08             	sub    $0x8,%esp
  801a7b:	89 1c 24             	mov    %ebx,(%esp)
  801a7e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801a82:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a87:	b8 04 00 00 00       	mov    $0x4,%eax
  801a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  801a92:	89 df                	mov    %ebx,%edi
  801a94:	51                   	push   %ecx
  801a95:	52                   	push   %edx
  801a96:	53                   	push   %ebx
  801a97:	54                   	push   %esp
  801a98:	55                   	push   %ebp
  801a99:	56                   	push   %esi
  801a9a:	57                   	push   %edi
  801a9b:	54                   	push   %esp
  801a9c:	5d                   	pop    %ebp
  801a9d:	8d 35 a5 1a 80 00    	lea    0x801aa5,%esi
  801aa3:	0f 34                	sysenter 
  801aa5:	5f                   	pop    %edi
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	5c                   	pop    %esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5a                   	pop    %edx
  801aab:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801aac:	8b 1c 24             	mov    (%esp),%ebx
  801aaf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ab3:	89 ec                	mov    %ebp,%esp
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	89 1c 24             	mov    %ebx,(%esp)
  801ac0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	b8 02 00 00 00       	mov    $0x2,%eax
  801ace:	89 d1                	mov    %edx,%ecx
  801ad0:	89 d3                	mov    %edx,%ebx
  801ad2:	89 d7                	mov    %edx,%edi
  801ad4:	51                   	push   %ecx
  801ad5:	52                   	push   %edx
  801ad6:	53                   	push   %ebx
  801ad7:	54                   	push   %esp
  801ad8:	55                   	push   %ebp
  801ad9:	56                   	push   %esi
  801ada:	57                   	push   %edi
  801adb:	54                   	push   %esp
  801adc:	5d                   	pop    %ebp
  801add:	8d 35 e5 1a 80 00    	lea    0x801ae5,%esi
  801ae3:	0f 34                	sysenter 
  801ae5:	5f                   	pop    %edi
  801ae6:	5e                   	pop    %esi
  801ae7:	5d                   	pop    %ebp
  801ae8:	5c                   	pop    %esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5a                   	pop    %edx
  801aeb:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801aec:	8b 1c 24             	mov    (%esp),%ebx
  801aef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801af3:	89 ec                	mov    %ebp,%esp
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 28             	sub    $0x28,%esp
  801afd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b00:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801b03:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b08:	b8 03 00 00 00       	mov    $0x3,%eax
  801b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b10:	89 cb                	mov    %ecx,%ebx
  801b12:	89 cf                	mov    %ecx,%edi
  801b14:	51                   	push   %ecx
  801b15:	52                   	push   %edx
  801b16:	53                   	push   %ebx
  801b17:	54                   	push   %esp
  801b18:	55                   	push   %ebp
  801b19:	56                   	push   %esi
  801b1a:	57                   	push   %edi
  801b1b:	54                   	push   %esp
  801b1c:	5d                   	pop    %ebp
  801b1d:	8d 35 25 1b 80 00    	lea    0x801b25,%esi
  801b23:	0f 34                	sysenter 
  801b25:	5f                   	pop    %edi
  801b26:	5e                   	pop    %esi
  801b27:	5d                   	pop    %ebp
  801b28:	5c                   	pop    %esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5a                   	pop    %edx
  801b2b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	7e 28                	jle    801b58 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801b30:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b34:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801b3b:	00 
  801b3c:	c7 44 24 08 20 39 80 	movl   $0x803920,0x8(%esp)
  801b43:	00 
  801b44:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801b4b:	00 
  801b4c:	c7 04 24 3d 39 80 00 	movl   $0x80393d,(%esp)
  801b53:	e8 54 eb ff ff       	call   8006ac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801b58:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b5b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b5e:	89 ec                	mov    %ebp,%esp
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    
	...

00801b70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	8b 45 08             	mov    0x8(%ebp),%eax
  801b76:	05 00 00 00 30       	add    $0x30000000,%eax
  801b7b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	89 04 24             	mov    %eax,(%esp)
  801b8c:	e8 df ff ff ff       	call   801b70 <fd2num>
  801b91:	05 20 00 0d 00       	add    $0xd0020,%eax
  801b96:	c1 e0 0c             	shl    $0xc,%eax
}
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	57                   	push   %edi
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801ba4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801ba9:	a8 01                	test   $0x1,%al
  801bab:	74 36                	je     801be3 <fd_alloc+0x48>
  801bad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801bb2:	a8 01                	test   $0x1,%al
  801bb4:	74 2d                	je     801be3 <fd_alloc+0x48>
  801bb6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801bbb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801bc0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	89 c2                	mov    %eax,%edx
  801bc9:	c1 ea 16             	shr    $0x16,%edx
  801bcc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801bcf:	f6 c2 01             	test   $0x1,%dl
  801bd2:	74 14                	je     801be8 <fd_alloc+0x4d>
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	c1 ea 0c             	shr    $0xc,%edx
  801bd9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801bdc:	f6 c2 01             	test   $0x1,%dl
  801bdf:	75 10                	jne    801bf1 <fd_alloc+0x56>
  801be1:	eb 05                	jmp    801be8 <fd_alloc+0x4d>
  801be3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801be8:	89 1f                	mov    %ebx,(%edi)
  801bea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801bef:	eb 17                	jmp    801c08 <fd_alloc+0x6d>
  801bf1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801bf6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801bfb:	75 c8                	jne    801bc5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801bfd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801c03:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801c08:	5b                   	pop    %ebx
  801c09:	5e                   	pop    %esi
  801c0a:	5f                   	pop    %edi
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    

00801c0d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	83 f8 1f             	cmp    $0x1f,%eax
  801c16:	77 36                	ja     801c4e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c18:	05 00 00 0d 00       	add    $0xd0000,%eax
  801c1d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	c1 ea 16             	shr    $0x16,%edx
  801c25:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c2c:	f6 c2 01             	test   $0x1,%dl
  801c2f:	74 1d                	je     801c4e <fd_lookup+0x41>
  801c31:	89 c2                	mov    %eax,%edx
  801c33:	c1 ea 0c             	shr    $0xc,%edx
  801c36:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c3d:	f6 c2 01             	test   $0x1,%dl
  801c40:	74 0c                	je     801c4e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c45:	89 02                	mov    %eax,(%edx)
  801c47:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801c4c:	eb 05                	jmp    801c53 <fd_lookup+0x46>
  801c4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c5b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	89 04 24             	mov    %eax,(%esp)
  801c68:	e8 a0 ff ff ff       	call   801c0d <fd_lookup>
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 0e                	js     801c7f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c71:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c77:	89 50 04             	mov    %edx,0x4(%eax)
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c7f:	c9                   	leave  
  801c80:	c3                   	ret    

00801c81 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	56                   	push   %esi
  801c85:	53                   	push   %ebx
  801c86:	83 ec 10             	sub    $0x10,%esp
  801c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801c8f:	b8 24 40 80 00       	mov    $0x804024,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801c94:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c99:	be c8 39 80 00       	mov    $0x8039c8,%esi
		if (devtab[i]->dev_id == dev_id) {
  801c9e:	39 08                	cmp    %ecx,(%eax)
  801ca0:	75 10                	jne    801cb2 <dev_lookup+0x31>
  801ca2:	eb 04                	jmp    801ca8 <dev_lookup+0x27>
  801ca4:	39 08                	cmp    %ecx,(%eax)
  801ca6:	75 0a                	jne    801cb2 <dev_lookup+0x31>
			*dev = devtab[i];
  801ca8:	89 03                	mov    %eax,(%ebx)
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801caf:	90                   	nop
  801cb0:	eb 31                	jmp    801ce3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cb2:	83 c2 01             	add    $0x1,%edx
  801cb5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	75 e8                	jne    801ca4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cbc:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801cc1:	8b 40 48             	mov    0x48(%eax),%eax
  801cc4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccc:	c7 04 24 4c 39 80 00 	movl   $0x80394c,(%esp)
  801cd3:	e8 8d ea ff ff       	call   800765 <cprintf>
	*dev = 0;
  801cd8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	53                   	push   %ebx
  801cee:	83 ec 24             	sub    $0x24,%esp
  801cf1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cf4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	89 04 24             	mov    %eax,(%esp)
  801d01:	e8 07 ff ff ff       	call   801c0d <fd_lookup>
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 53                	js     801d5d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d14:	8b 00                	mov    (%eax),%eax
  801d16:	89 04 24             	mov    %eax,(%esp)
  801d19:	e8 63 ff ff ff       	call   801c81 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	78 3b                	js     801d5d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801d22:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d2a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801d2e:	74 2d                	je     801d5d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d30:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d33:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d3a:	00 00 00 
	stat->st_isdir = 0;
  801d3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d44:	00 00 00 
	stat->st_dev = dev;
  801d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d57:	89 14 24             	mov    %edx,(%esp)
  801d5a:	ff 50 14             	call   *0x14(%eax)
}
  801d5d:	83 c4 24             	add    $0x24,%esp
  801d60:	5b                   	pop    %ebx
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    

00801d63 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	53                   	push   %ebx
  801d67:	83 ec 24             	sub    $0x24,%esp
  801d6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d74:	89 1c 24             	mov    %ebx,(%esp)
  801d77:	e8 91 fe ff ff       	call   801c0d <fd_lookup>
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	78 5f                	js     801ddf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d8a:	8b 00                	mov    (%eax),%eax
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 ed fe ff ff       	call   801c81 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 47                	js     801ddf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d9b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801d9f:	75 23                	jne    801dc4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801da1:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801da6:	8b 40 48             	mov    0x48(%eax),%eax
  801da9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db1:	c7 04 24 6c 39 80 00 	movl   $0x80396c,(%esp)
  801db8:	e8 a8 e9 ff ff       	call   800765 <cprintf>
  801dbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801dc2:	eb 1b                	jmp    801ddf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc7:	8b 48 18             	mov    0x18(%eax),%ecx
  801dca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dcf:	85 c9                	test   %ecx,%ecx
  801dd1:	74 0c                	je     801ddf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dda:	89 14 24             	mov    %edx,(%esp)
  801ddd:	ff d1                	call   *%ecx
}
  801ddf:	83 c4 24             	add    $0x24,%esp
  801de2:	5b                   	pop    %ebx
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    

00801de5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	53                   	push   %ebx
  801de9:	83 ec 24             	sub    $0x24,%esp
  801dec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801def:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df6:	89 1c 24             	mov    %ebx,(%esp)
  801df9:	e8 0f fe ff ff       	call   801c0d <fd_lookup>
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 66                	js     801e68 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0c:	8b 00                	mov    (%eax),%eax
  801e0e:	89 04 24             	mov    %eax,(%esp)
  801e11:	e8 6b fe ff ff       	call   801c81 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 4e                	js     801e68 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e1d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801e21:	75 23                	jne    801e46 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801e23:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801e28:	8b 40 48             	mov    0x48(%eax),%eax
  801e2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e33:	c7 04 24 8d 39 80 00 	movl   $0x80398d,(%esp)
  801e3a:	e8 26 e9 ff ff       	call   800765 <cprintf>
  801e3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801e44:	eb 22                	jmp    801e68 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e49:	8b 48 0c             	mov    0xc(%eax),%ecx
  801e4c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e51:	85 c9                	test   %ecx,%ecx
  801e53:	74 13                	je     801e68 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801e55:	8b 45 10             	mov    0x10(%ebp),%eax
  801e58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e63:	89 14 24             	mov    %edx,(%esp)
  801e66:	ff d1                	call   *%ecx
}
  801e68:	83 c4 24             	add    $0x24,%esp
  801e6b:	5b                   	pop    %ebx
  801e6c:	5d                   	pop    %ebp
  801e6d:	c3                   	ret    

00801e6e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	53                   	push   %ebx
  801e72:	83 ec 24             	sub    $0x24,%esp
  801e75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7f:	89 1c 24             	mov    %ebx,(%esp)
  801e82:	e8 86 fd ff ff       	call   801c0d <fd_lookup>
  801e87:	85 c0                	test   %eax,%eax
  801e89:	78 6b                	js     801ef6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e95:	8b 00                	mov    (%eax),%eax
  801e97:	89 04 24             	mov    %eax,(%esp)
  801e9a:	e8 e2 fd ff ff       	call   801c81 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	78 53                	js     801ef6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ea3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ea6:	8b 42 08             	mov    0x8(%edx),%eax
  801ea9:	83 e0 03             	and    $0x3,%eax
  801eac:	83 f8 01             	cmp    $0x1,%eax
  801eaf:	75 23                	jne    801ed4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801eb1:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801eb6:	8b 40 48             	mov    0x48(%eax),%eax
  801eb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec1:	c7 04 24 aa 39 80 00 	movl   $0x8039aa,(%esp)
  801ec8:	e8 98 e8 ff ff       	call   800765 <cprintf>
  801ecd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801ed2:	eb 22                	jmp    801ef6 <read+0x88>
	}
	if (!dev->dev_read)
  801ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed7:	8b 48 08             	mov    0x8(%eax),%ecx
  801eda:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801edf:	85 c9                	test   %ecx,%ecx
  801ee1:	74 13                	je     801ef6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ee3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef1:	89 14 24             	mov    %edx,(%esp)
  801ef4:	ff d1                	call   *%ecx
}
  801ef6:	83 c4 24             	add    $0x24,%esp
  801ef9:	5b                   	pop    %ebx
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

00801efc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	57                   	push   %edi
  801f00:	56                   	push   %esi
  801f01:	53                   	push   %ebx
  801f02:	83 ec 1c             	sub    $0x1c,%esp
  801f05:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f08:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f10:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f15:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1a:	85 f6                	test   %esi,%esi
  801f1c:	74 29                	je     801f47 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f1e:	89 f0                	mov    %esi,%eax
  801f20:	29 d0                	sub    %edx,%eax
  801f22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f26:	03 55 0c             	add    0xc(%ebp),%edx
  801f29:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f2d:	89 3c 24             	mov    %edi,(%esp)
  801f30:	e8 39 ff ff ff       	call   801e6e <read>
		if (m < 0)
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 0e                	js     801f47 <readn+0x4b>
			return m;
		if (m == 0)
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	74 08                	je     801f45 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f3d:	01 c3                	add    %eax,%ebx
  801f3f:	89 da                	mov    %ebx,%edx
  801f41:	39 f3                	cmp    %esi,%ebx
  801f43:	72 d9                	jb     801f1e <readn+0x22>
  801f45:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f47:	83 c4 1c             	add    $0x1c,%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 20             	sub    $0x20,%esp
  801f57:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f5a:	89 34 24             	mov    %esi,(%esp)
  801f5d:	e8 0e fc ff ff       	call   801b70 <fd2num>
  801f62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f65:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f69:	89 04 24             	mov    %eax,(%esp)
  801f6c:	e8 9c fc ff ff       	call   801c0d <fd_lookup>
  801f71:	89 c3                	mov    %eax,%ebx
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 05                	js     801f7c <fd_close+0x2d>
  801f77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801f7a:	74 0c                	je     801f88 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801f7c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801f80:	19 c0                	sbb    %eax,%eax
  801f82:	f7 d0                	not    %eax
  801f84:	21 c3                	and    %eax,%ebx
  801f86:	eb 3d                	jmp    801fc5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8f:	8b 06                	mov    (%esi),%eax
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 e8 fc ff ff       	call   801c81 <dev_lookup>
  801f99:	89 c3                	mov    %eax,%ebx
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 16                	js     801fb5 <fd_close+0x66>
		if (dev->dev_close)
  801f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa2:	8b 40 10             	mov    0x10(%eax),%eax
  801fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801faa:	85 c0                	test   %eax,%eax
  801fac:	74 07                	je     801fb5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801fae:	89 34 24             	mov    %esi,(%esp)
  801fb1:	ff d0                	call   *%eax
  801fb3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801fb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc0:	e8 29 f9 ff ff       	call   8018ee <sys_page_unmap>
	return r;
}
  801fc5:	89 d8                	mov    %ebx,%eax
  801fc7:	83 c4 20             	add    $0x20,%esp
  801fca:	5b                   	pop    %ebx
  801fcb:	5e                   	pop    %esi
  801fcc:	5d                   	pop    %ebp
  801fcd:	c3                   	ret    

00801fce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	89 04 24             	mov    %eax,(%esp)
  801fe1:	e8 27 fc ff ff       	call   801c0d <fd_lookup>
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	78 13                	js     801ffd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801fea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ff1:	00 
  801ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff5:	89 04 24             	mov    %eax,(%esp)
  801ff8:	e8 52 ff ff ff       	call   801f4f <fd_close>
}
  801ffd:	c9                   	leave  
  801ffe:	c3                   	ret    

00801fff <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	83 ec 18             	sub    $0x18,%esp
  802005:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802008:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80200b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802012:	00 
  802013:	8b 45 08             	mov    0x8(%ebp),%eax
  802016:	89 04 24             	mov    %eax,(%esp)
  802019:	e8 79 03 00 00       	call   802397 <open>
  80201e:	89 c3                	mov    %eax,%ebx
  802020:	85 c0                	test   %eax,%eax
  802022:	78 1b                	js     80203f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802024:	8b 45 0c             	mov    0xc(%ebp),%eax
  802027:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202b:	89 1c 24             	mov    %ebx,(%esp)
  80202e:	e8 b7 fc ff ff       	call   801cea <fstat>
  802033:	89 c6                	mov    %eax,%esi
	close(fd);
  802035:	89 1c 24             	mov    %ebx,(%esp)
  802038:	e8 91 ff ff ff       	call   801fce <close>
  80203d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80203f:	89 d8                	mov    %ebx,%eax
  802041:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802044:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802047:	89 ec                	mov    %ebp,%esp
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    

0080204b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	53                   	push   %ebx
  80204f:	83 ec 14             	sub    $0x14,%esp
  802052:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  802057:	89 1c 24             	mov    %ebx,(%esp)
  80205a:	e8 6f ff ff ff       	call   801fce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80205f:	83 c3 01             	add    $0x1,%ebx
  802062:	83 fb 20             	cmp    $0x20,%ebx
  802065:	75 f0                	jne    802057 <close_all+0xc>
		close(i);
}
  802067:	83 c4 14             	add    $0x14,%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    

0080206d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 58             	sub    $0x58,%esp
  802073:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802076:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802079:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80207c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80207f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802082:	89 44 24 04          	mov    %eax,0x4(%esp)
  802086:	8b 45 08             	mov    0x8(%ebp),%eax
  802089:	89 04 24             	mov    %eax,(%esp)
  80208c:	e8 7c fb ff ff       	call   801c0d <fd_lookup>
  802091:	89 c3                	mov    %eax,%ebx
  802093:	85 c0                	test   %eax,%eax
  802095:	0f 88 e0 00 00 00    	js     80217b <dup+0x10e>
		return r;
	close(newfdnum);
  80209b:	89 3c 24             	mov    %edi,(%esp)
  80209e:	e8 2b ff ff ff       	call   801fce <close>

	newfd = INDEX2FD(newfdnum);
  8020a3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8020a9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8020ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020af:	89 04 24             	mov    %eax,(%esp)
  8020b2:	e8 c9 fa ff ff       	call   801b80 <fd2data>
  8020b7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8020b9:	89 34 24             	mov    %esi,(%esp)
  8020bc:	e8 bf fa ff ff       	call   801b80 <fd2data>
  8020c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8020c4:	89 da                	mov    %ebx,%edx
  8020c6:	89 d8                	mov    %ebx,%eax
  8020c8:	c1 e8 16             	shr    $0x16,%eax
  8020cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020d2:	a8 01                	test   $0x1,%al
  8020d4:	74 43                	je     802119 <dup+0xac>
  8020d6:	c1 ea 0c             	shr    $0xc,%edx
  8020d9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8020e0:	a8 01                	test   $0x1,%al
  8020e2:	74 35                	je     802119 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8020e4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8020eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8020f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8020f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802102:	00 
  802103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210e:	e8 47 f8 ff ff       	call   80195a <sys_page_map>
  802113:	89 c3                	mov    %eax,%ebx
  802115:	85 c0                	test   %eax,%eax
  802117:	78 3f                	js     802158 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802119:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80211c:	89 c2                	mov    %eax,%edx
  80211e:	c1 ea 0c             	shr    $0xc,%edx
  802121:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802128:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80212e:	89 54 24 10          	mov    %edx,0x10(%esp)
  802132:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802136:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80213d:	00 
  80213e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802149:	e8 0c f8 ff ff       	call   80195a <sys_page_map>
  80214e:	89 c3                	mov    %eax,%ebx
  802150:	85 c0                	test   %eax,%eax
  802152:	78 04                	js     802158 <dup+0xeb>
  802154:	89 fb                	mov    %edi,%ebx
  802156:	eb 23                	jmp    80217b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802158:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802163:	e8 86 f7 ff ff       	call   8018ee <sys_page_unmap>
	sys_page_unmap(0, nva);
  802168:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80216b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802176:	e8 73 f7 ff ff       	call   8018ee <sys_page_unmap>
	return r;
}
  80217b:	89 d8                	mov    %ebx,%eax
  80217d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802180:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802183:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802186:	89 ec                	mov    %ebp,%esp
  802188:	5d                   	pop    %ebp
  802189:	c3                   	ret    
	...

0080218c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 18             	sub    $0x18,%esp
  802192:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802195:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802198:	89 c3                	mov    %eax,%ebx
  80219a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80219c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8021a3:	75 11                	jne    8021b6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8021ac:	e8 4f 0a 00 00       	call   802c00 <ipc_find_env>
  8021b1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021b6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8021bd:	00 
  8021be:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8021c5:	00 
  8021c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021ca:	a1 00 50 80 00       	mov    0x805000,%eax
  8021cf:	89 04 24             	mov    %eax,(%esp)
  8021d2:	e8 74 0a 00 00       	call   802c4b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021de:	00 
  8021df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ea:	e8 da 0a 00 00       	call   802cc9 <ipc_recv>
}
  8021ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8021f2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021f5:	89 ec                	mov    %ebp,%esp
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    

008021f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802202:	8b 40 0c             	mov    0xc(%eax),%eax
  802205:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80220a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802212:	ba 00 00 00 00       	mov    $0x0,%edx
  802217:	b8 02 00 00 00       	mov    $0x2,%eax
  80221c:	e8 6b ff ff ff       	call   80218c <fsipc>
}
  802221:	c9                   	leave  
  802222:	c3                   	ret    

00802223 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802229:	8b 45 08             	mov    0x8(%ebp),%eax
  80222c:	8b 40 0c             	mov    0xc(%eax),%eax
  80222f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802234:	ba 00 00 00 00       	mov    $0x0,%edx
  802239:	b8 06 00 00 00       	mov    $0x6,%eax
  80223e:	e8 49 ff ff ff       	call   80218c <fsipc>
}
  802243:	c9                   	leave  
  802244:	c3                   	ret    

00802245 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80224b:	ba 00 00 00 00       	mov    $0x0,%edx
  802250:	b8 08 00 00 00       	mov    $0x8,%eax
  802255:	e8 32 ff ff ff       	call   80218c <fsipc>
}
  80225a:	c9                   	leave  
  80225b:	c3                   	ret    

0080225c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	53                   	push   %ebx
  802260:	83 ec 14             	sub    $0x14,%esp
  802263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802266:	8b 45 08             	mov    0x8(%ebp),%eax
  802269:	8b 40 0c             	mov    0xc(%eax),%eax
  80226c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802271:	ba 00 00 00 00       	mov    $0x0,%edx
  802276:	b8 05 00 00 00       	mov    $0x5,%eax
  80227b:	e8 0c ff ff ff       	call   80218c <fsipc>
  802280:	85 c0                	test   %eax,%eax
  802282:	78 2b                	js     8022af <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802284:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80228b:	00 
  80228c:	89 1c 24             	mov    %ebx,(%esp)
  80228f:	e8 06 ee ff ff       	call   80109a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802294:	a1 80 60 80 00       	mov    0x806080,%eax
  802299:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80229f:	a1 84 60 80 00       	mov    0x806084,%eax
  8022a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8022aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8022af:	83 c4 14             	add    $0x14,%esp
  8022b2:	5b                   	pop    %ebx
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    

008022b5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	83 ec 18             	sub    $0x18,%esp
  8022bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8022be:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8022c3:	76 05                	jbe    8022ca <devfile_write+0x15>
  8022c5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8022cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8022d0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  8022d6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  8022db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8022ed:	e8 93 ef ff ff       	call   801285 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  8022f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8022fc:	e8 8b fe ff ff       	call   80218c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802301:	c9                   	leave  
  802302:	c3                   	ret    

00802303 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802303:	55                   	push   %ebp
  802304:	89 e5                	mov    %esp,%ebp
  802306:	53                   	push   %ebx
  802307:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80230a:	8b 45 08             	mov    0x8(%ebp),%eax
  80230d:	8b 40 0c             	mov    0xc(%eax),%eax
  802310:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  802315:	8b 45 10             	mov    0x10(%ebp),%eax
  802318:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  80231d:	ba 00 00 00 00       	mov    $0x0,%edx
  802322:	b8 03 00 00 00       	mov    $0x3,%eax
  802327:	e8 60 fe ff ff       	call   80218c <fsipc>
  80232c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80232e:	85 c0                	test   %eax,%eax
  802330:	78 17                	js     802349 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802332:	89 44 24 08          	mov    %eax,0x8(%esp)
  802336:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80233d:	00 
  80233e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802341:	89 04 24             	mov    %eax,(%esp)
  802344:	e8 3c ef ff ff       	call   801285 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802349:	89 d8                	mov    %ebx,%eax
  80234b:	83 c4 14             	add    $0x14,%esp
  80234e:	5b                   	pop    %ebx
  80234f:	5d                   	pop    %ebp
  802350:	c3                   	ret    

00802351 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802351:	55                   	push   %ebp
  802352:	89 e5                	mov    %esp,%ebp
  802354:	53                   	push   %ebx
  802355:	83 ec 14             	sub    $0x14,%esp
  802358:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80235b:	89 1c 24             	mov    %ebx,(%esp)
  80235e:	e8 ed ec ff ff       	call   801050 <strlen>
  802363:	89 c2                	mov    %eax,%edx
  802365:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80236a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802370:	7f 1f                	jg     802391 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802372:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802376:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80237d:	e8 18 ed ff ff       	call   80109a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802382:	ba 00 00 00 00       	mov    $0x0,%edx
  802387:	b8 07 00 00 00       	mov    $0x7,%eax
  80238c:	e8 fb fd ff ff       	call   80218c <fsipc>
}
  802391:	83 c4 14             	add    $0x14,%esp
  802394:	5b                   	pop    %ebx
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    

00802397 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802397:	55                   	push   %ebp
  802398:	89 e5                	mov    %esp,%ebp
  80239a:	83 ec 28             	sub    $0x28,%esp
  80239d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8023a0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8023a3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  8023a6:	89 34 24             	mov    %esi,(%esp)
  8023a9:	e8 a2 ec ff ff       	call   801050 <strlen>
  8023ae:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8023b3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023b8:	7f 6d                	jg     802427 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8023ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023bd:	89 04 24             	mov    %eax,(%esp)
  8023c0:	e8 d6 f7 ff ff       	call   801b9b <fd_alloc>
  8023c5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8023c7:	85 c0                	test   %eax,%eax
  8023c9:	78 5c                	js     802427 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8023cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ce:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8023d3:	89 34 24             	mov    %esi,(%esp)
  8023d6:	e8 75 ec ff ff       	call   801050 <strlen>
  8023db:	83 c0 01             	add    $0x1,%eax
  8023de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8023ed:	e8 93 ee ff ff       	call   801285 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8023f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fa:	e8 8d fd ff ff       	call   80218c <fsipc>
  8023ff:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802401:	85 c0                	test   %eax,%eax
  802403:	79 15                	jns    80241a <open+0x83>
             fd_close(fd,0);
  802405:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80240c:	00 
  80240d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802410:	89 04 24             	mov    %eax,(%esp)
  802413:	e8 37 fb ff ff       	call   801f4f <fd_close>
             return r;
  802418:	eb 0d                	jmp    802427 <open+0x90>
        }
        return fd2num(fd);
  80241a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241d:	89 04 24             	mov    %eax,(%esp)
  802420:	e8 4b f7 ff ff       	call   801b70 <fd2num>
  802425:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802427:	89 d8                	mov    %ebx,%eax
  802429:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80242c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80242f:	89 ec                	mov    %ebp,%esp
  802431:	5d                   	pop    %ebp
  802432:	c3                   	ret    
	...

00802440 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802446:	c7 44 24 04 d4 39 80 	movl   $0x8039d4,0x4(%esp)
  80244d:	00 
  80244e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802451:	89 04 24             	mov    %eax,(%esp)
  802454:	e8 41 ec ff ff       	call   80109a <strcpy>
	return 0;
}
  802459:	b8 00 00 00 00       	mov    $0x0,%eax
  80245e:	c9                   	leave  
  80245f:	c3                   	ret    

00802460 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	53                   	push   %ebx
  802464:	83 ec 14             	sub    $0x14,%esp
  802467:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80246a:	89 1c 24             	mov    %ebx,(%esp)
  80246d:	e8 ca 08 00 00       	call   802d3c <pageref>
  802472:	89 c2                	mov    %eax,%edx
  802474:	b8 00 00 00 00       	mov    $0x0,%eax
  802479:	83 fa 01             	cmp    $0x1,%edx
  80247c:	75 0b                	jne    802489 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80247e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802481:	89 04 24             	mov    %eax,(%esp)
  802484:	e8 b9 02 00 00       	call   802742 <nsipc_close>
	else
		return 0;
}
  802489:	83 c4 14             	add    $0x14,%esp
  80248c:	5b                   	pop    %ebx
  80248d:	5d                   	pop    %ebp
  80248e:	c3                   	ret    

0080248f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80248f:	55                   	push   %ebp
  802490:	89 e5                	mov    %esp,%ebp
  802492:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802495:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80249c:	00 
  80249d:	8b 45 10             	mov    0x10(%ebp),%eax
  8024a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8024b1:	89 04 24             	mov    %eax,(%esp)
  8024b4:	e8 c5 02 00 00       	call   80277e <nsipc_send>
}
  8024b9:	c9                   	leave  
  8024ba:	c3                   	ret    

008024bb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8024bb:	55                   	push   %ebp
  8024bc:	89 e5                	mov    %esp,%ebp
  8024be:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8024c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8024c8:	00 
  8024c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8024cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024da:	8b 40 0c             	mov    0xc(%eax),%eax
  8024dd:	89 04 24             	mov    %eax,(%esp)
  8024e0:	e8 0c 03 00 00       	call   8027f1 <nsipc_recv>
}
  8024e5:	c9                   	leave  
  8024e6:	c3                   	ret    

008024e7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8024e7:	55                   	push   %ebp
  8024e8:	89 e5                	mov    %esp,%ebp
  8024ea:	56                   	push   %esi
  8024eb:	53                   	push   %ebx
  8024ec:	83 ec 20             	sub    $0x20,%esp
  8024ef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8024f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f4:	89 04 24             	mov    %eax,(%esp)
  8024f7:	e8 9f f6 ff ff       	call   801b9b <fd_alloc>
  8024fc:	89 c3                	mov    %eax,%ebx
  8024fe:	85 c0                	test   %eax,%eax
  802500:	78 21                	js     802523 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802502:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802509:	00 
  80250a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802511:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802518:	e8 ab f4 ff ff       	call   8019c8 <sys_page_alloc>
  80251d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80251f:	85 c0                	test   %eax,%eax
  802521:	79 0a                	jns    80252d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802523:	89 34 24             	mov    %esi,(%esp)
  802526:	e8 17 02 00 00       	call   802742 <nsipc_close>
		return r;
  80252b:	eb 28                	jmp    802555 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80252d:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802533:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802536:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802538:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802545:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80254b:	89 04 24             	mov    %eax,(%esp)
  80254e:	e8 1d f6 ff ff       	call   801b70 <fd2num>
  802553:	89 c3                	mov    %eax,%ebx
}
  802555:	89 d8                	mov    %ebx,%eax
  802557:	83 c4 20             	add    $0x20,%esp
  80255a:	5b                   	pop    %ebx
  80255b:	5e                   	pop    %esi
  80255c:	5d                   	pop    %ebp
  80255d:	c3                   	ret    

0080255e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802564:	8b 45 10             	mov    0x10(%ebp),%eax
  802567:	89 44 24 08          	mov    %eax,0x8(%esp)
  80256b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80256e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802572:	8b 45 08             	mov    0x8(%ebp),%eax
  802575:	89 04 24             	mov    %eax,(%esp)
  802578:	e8 79 01 00 00       	call   8026f6 <nsipc_socket>
  80257d:	85 c0                	test   %eax,%eax
  80257f:	78 05                	js     802586 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802581:	e8 61 ff ff ff       	call   8024e7 <alloc_sockfd>
}
  802586:	c9                   	leave  
  802587:	c3                   	ret    

00802588 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80258e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802591:	89 54 24 04          	mov    %edx,0x4(%esp)
  802595:	89 04 24             	mov    %eax,(%esp)
  802598:	e8 70 f6 ff ff       	call   801c0d <fd_lookup>
  80259d:	85 c0                	test   %eax,%eax
  80259f:	78 15                	js     8025b6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8025a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025a4:	8b 0a                	mov    (%edx),%ecx
  8025a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8025ab:	3b 0d 40 40 80 00    	cmp    0x804040,%ecx
  8025b1:	75 03                	jne    8025b6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8025b3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8025b6:	c9                   	leave  
  8025b7:	c3                   	ret    

008025b8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025be:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c1:	e8 c2 ff ff ff       	call   802588 <fd2sockid>
  8025c6:	85 c0                	test   %eax,%eax
  8025c8:	78 0f                	js     8025d9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8025ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025d1:	89 04 24             	mov    %eax,(%esp)
  8025d4:	e8 47 01 00 00       	call   802720 <nsipc_listen>
}
  8025d9:	c9                   	leave  
  8025da:	c3                   	ret    

008025db <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025db:	55                   	push   %ebp
  8025dc:	89 e5                	mov    %esp,%ebp
  8025de:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e4:	e8 9f ff ff ff       	call   802588 <fd2sockid>
  8025e9:	85 c0                	test   %eax,%eax
  8025eb:	78 16                	js     802603 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8025ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8025f0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025fb:	89 04 24             	mov    %eax,(%esp)
  8025fe:	e8 6e 02 00 00       	call   802871 <nsipc_connect>
}
  802603:	c9                   	leave  
  802604:	c3                   	ret    

00802605 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802605:	55                   	push   %ebp
  802606:	89 e5                	mov    %esp,%ebp
  802608:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80260b:	8b 45 08             	mov    0x8(%ebp),%eax
  80260e:	e8 75 ff ff ff       	call   802588 <fd2sockid>
  802613:	85 c0                	test   %eax,%eax
  802615:	78 0f                	js     802626 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802617:	8b 55 0c             	mov    0xc(%ebp),%edx
  80261a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80261e:	89 04 24             	mov    %eax,(%esp)
  802621:	e8 36 01 00 00       	call   80275c <nsipc_shutdown>
}
  802626:	c9                   	leave  
  802627:	c3                   	ret    

00802628 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802628:	55                   	push   %ebp
  802629:	89 e5                	mov    %esp,%ebp
  80262b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80262e:	8b 45 08             	mov    0x8(%ebp),%eax
  802631:	e8 52 ff ff ff       	call   802588 <fd2sockid>
  802636:	85 c0                	test   %eax,%eax
  802638:	78 16                	js     802650 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80263a:	8b 55 10             	mov    0x10(%ebp),%edx
  80263d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802641:	8b 55 0c             	mov    0xc(%ebp),%edx
  802644:	89 54 24 04          	mov    %edx,0x4(%esp)
  802648:	89 04 24             	mov    %eax,(%esp)
  80264b:	e8 60 02 00 00       	call   8028b0 <nsipc_bind>
}
  802650:	c9                   	leave  
  802651:	c3                   	ret    

00802652 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802652:	55                   	push   %ebp
  802653:	89 e5                	mov    %esp,%ebp
  802655:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802658:	8b 45 08             	mov    0x8(%ebp),%eax
  80265b:	e8 28 ff ff ff       	call   802588 <fd2sockid>
  802660:	85 c0                	test   %eax,%eax
  802662:	78 1f                	js     802683 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802664:	8b 55 10             	mov    0x10(%ebp),%edx
  802667:	89 54 24 08          	mov    %edx,0x8(%esp)
  80266b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80266e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802672:	89 04 24             	mov    %eax,(%esp)
  802675:	e8 75 02 00 00       	call   8028ef <nsipc_accept>
  80267a:	85 c0                	test   %eax,%eax
  80267c:	78 05                	js     802683 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80267e:	e8 64 fe ff ff       	call   8024e7 <alloc_sockfd>
}
  802683:	c9                   	leave  
  802684:	c3                   	ret    
	...

00802690 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802690:	55                   	push   %ebp
  802691:	89 e5                	mov    %esp,%ebp
  802693:	53                   	push   %ebx
  802694:	83 ec 14             	sub    $0x14,%esp
  802697:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802699:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8026a0:	75 11                	jne    8026b3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8026a2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8026a9:	e8 52 05 00 00       	call   802c00 <ipc_find_env>
  8026ae:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8026b3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8026ba:	00 
  8026bb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8026c2:	00 
  8026c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026c7:	a1 04 50 80 00       	mov    0x805004,%eax
  8026cc:	89 04 24             	mov    %eax,(%esp)
  8026cf:	e8 77 05 00 00       	call   802c4b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8026d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8026db:	00 
  8026dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8026e3:	00 
  8026e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026eb:	e8 d9 05 00 00       	call   802cc9 <ipc_recv>
}
  8026f0:	83 c4 14             	add    $0x14,%esp
  8026f3:	5b                   	pop    %ebx
  8026f4:	5d                   	pop    %ebp
  8026f5:	c3                   	ret    

008026f6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8026f6:	55                   	push   %ebp
  8026f7:	89 e5                	mov    %esp,%ebp
  8026f9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8026fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802704:	8b 45 0c             	mov    0xc(%ebp),%eax
  802707:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80270c:	8b 45 10             	mov    0x10(%ebp),%eax
  80270f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802714:	b8 09 00 00 00       	mov    $0x9,%eax
  802719:	e8 72 ff ff ff       	call   802690 <nsipc>
}
  80271e:	c9                   	leave  
  80271f:	c3                   	ret    

00802720 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802720:	55                   	push   %ebp
  802721:	89 e5                	mov    %esp,%ebp
  802723:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802726:	8b 45 08             	mov    0x8(%ebp),%eax
  802729:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80272e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802731:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802736:	b8 06 00 00 00       	mov    $0x6,%eax
  80273b:	e8 50 ff ff ff       	call   802690 <nsipc>
}
  802740:	c9                   	leave  
  802741:	c3                   	ret    

00802742 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802742:	55                   	push   %ebp
  802743:	89 e5                	mov    %esp,%ebp
  802745:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802748:	8b 45 08             	mov    0x8(%ebp),%eax
  80274b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802750:	b8 04 00 00 00       	mov    $0x4,%eax
  802755:	e8 36 ff ff ff       	call   802690 <nsipc>
}
  80275a:	c9                   	leave  
  80275b:	c3                   	ret    

0080275c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80275c:	55                   	push   %ebp
  80275d:	89 e5                	mov    %esp,%ebp
  80275f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802762:	8b 45 08             	mov    0x8(%ebp),%eax
  802765:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80276a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80276d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802772:	b8 03 00 00 00       	mov    $0x3,%eax
  802777:	e8 14 ff ff ff       	call   802690 <nsipc>
}
  80277c:	c9                   	leave  
  80277d:	c3                   	ret    

0080277e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80277e:	55                   	push   %ebp
  80277f:	89 e5                	mov    %esp,%ebp
  802781:	53                   	push   %ebx
  802782:	83 ec 14             	sub    $0x14,%esp
  802785:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802788:	8b 45 08             	mov    0x8(%ebp),%eax
  80278b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802790:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802796:	7e 24                	jle    8027bc <nsipc_send+0x3e>
  802798:	c7 44 24 0c e0 39 80 	movl   $0x8039e0,0xc(%esp)
  80279f:	00 
  8027a0:	c7 44 24 08 ec 39 80 	movl   $0x8039ec,0x8(%esp)
  8027a7:	00 
  8027a8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8027af:	00 
  8027b0:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  8027b7:	e8 f0 de ff ff       	call   8006ac <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8027bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027c7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8027ce:	e8 b2 ea ff ff       	call   801285 <memmove>
	nsipcbuf.send.req_size = size;
  8027d3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8027d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8027dc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8027e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8027e6:	e8 a5 fe ff ff       	call   802690 <nsipc>
}
  8027eb:	83 c4 14             	add    $0x14,%esp
  8027ee:	5b                   	pop    %ebx
  8027ef:	5d                   	pop    %ebp
  8027f0:	c3                   	ret    

008027f1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8027f1:	55                   	push   %ebp
  8027f2:	89 e5                	mov    %esp,%ebp
  8027f4:	56                   	push   %esi
  8027f5:	53                   	push   %ebx
  8027f6:	83 ec 10             	sub    $0x10,%esp
  8027f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8027fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802804:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80280a:	8b 45 14             	mov    0x14(%ebp),%eax
  80280d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802812:	b8 07 00 00 00       	mov    $0x7,%eax
  802817:	e8 74 fe ff ff       	call   802690 <nsipc>
  80281c:	89 c3                	mov    %eax,%ebx
  80281e:	85 c0                	test   %eax,%eax
  802820:	78 46                	js     802868 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802822:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802827:	7f 04                	jg     80282d <nsipc_recv+0x3c>
  802829:	39 c6                	cmp    %eax,%esi
  80282b:	7d 24                	jge    802851 <nsipc_recv+0x60>
  80282d:	c7 44 24 0c 0d 3a 80 	movl   $0x803a0d,0xc(%esp)
  802834:	00 
  802835:	c7 44 24 08 ec 39 80 	movl   $0x8039ec,0x8(%esp)
  80283c:	00 
  80283d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802844:	00 
  802845:	c7 04 24 01 3a 80 00 	movl   $0x803a01,(%esp)
  80284c:	e8 5b de ff ff       	call   8006ac <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802851:	89 44 24 08          	mov    %eax,0x8(%esp)
  802855:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80285c:	00 
  80285d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802860:	89 04 24             	mov    %eax,(%esp)
  802863:	e8 1d ea ff ff       	call   801285 <memmove>
	}

	return r;
}
  802868:	89 d8                	mov    %ebx,%eax
  80286a:	83 c4 10             	add    $0x10,%esp
  80286d:	5b                   	pop    %ebx
  80286e:	5e                   	pop    %esi
  80286f:	5d                   	pop    %ebp
  802870:	c3                   	ret    

00802871 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802871:	55                   	push   %ebp
  802872:	89 e5                	mov    %esp,%ebp
  802874:	53                   	push   %ebx
  802875:	83 ec 14             	sub    $0x14,%esp
  802878:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80287b:	8b 45 08             	mov    0x8(%ebp),%eax
  80287e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802883:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802887:	8b 45 0c             	mov    0xc(%ebp),%eax
  80288a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80288e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802895:	e8 eb e9 ff ff       	call   801285 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80289a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8028a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8028a5:	e8 e6 fd ff ff       	call   802690 <nsipc>
}
  8028aa:	83 c4 14             	add    $0x14,%esp
  8028ad:	5b                   	pop    %ebx
  8028ae:	5d                   	pop    %ebp
  8028af:	c3                   	ret    

008028b0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8028b0:	55                   	push   %ebp
  8028b1:	89 e5                	mov    %esp,%ebp
  8028b3:	53                   	push   %ebx
  8028b4:	83 ec 14             	sub    $0x14,%esp
  8028b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8028ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8028bd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8028c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028cd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8028d4:	e8 ac e9 ff ff       	call   801285 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8028d9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8028df:	b8 02 00 00 00       	mov    $0x2,%eax
  8028e4:	e8 a7 fd ff ff       	call   802690 <nsipc>
}
  8028e9:	83 c4 14             	add    $0x14,%esp
  8028ec:	5b                   	pop    %ebx
  8028ed:	5d                   	pop    %ebp
  8028ee:	c3                   	ret    

008028ef <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8028ef:	55                   	push   %ebp
  8028f0:	89 e5                	mov    %esp,%ebp
  8028f2:	83 ec 18             	sub    $0x18,%esp
  8028f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8028f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8028fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8028fe:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802903:	b8 01 00 00 00       	mov    $0x1,%eax
  802908:	e8 83 fd ff ff       	call   802690 <nsipc>
  80290d:	89 c3                	mov    %eax,%ebx
  80290f:	85 c0                	test   %eax,%eax
  802911:	78 25                	js     802938 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802913:	be 10 70 80 00       	mov    $0x807010,%esi
  802918:	8b 06                	mov    (%esi),%eax
  80291a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80291e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802925:	00 
  802926:	8b 45 0c             	mov    0xc(%ebp),%eax
  802929:	89 04 24             	mov    %eax,(%esp)
  80292c:	e8 54 e9 ff ff       	call   801285 <memmove>
		*addrlen = ret->ret_addrlen;
  802931:	8b 16                	mov    (%esi),%edx
  802933:	8b 45 10             	mov    0x10(%ebp),%eax
  802936:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802938:	89 d8                	mov    %ebx,%eax
  80293a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80293d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802940:	89 ec                	mov    %ebp,%esp
  802942:	5d                   	pop    %ebp
  802943:	c3                   	ret    
	...

00802950 <free>:
	return v;
}

void
free(void *v)
{
  802950:	55                   	push   %ebp
  802951:	89 e5                	mov    %esp,%ebp
  802953:	56                   	push   %esi
  802954:	53                   	push   %ebx
  802955:	83 ec 10             	sub    $0x10,%esp
  802958:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  80295b:	85 db                	test   %ebx,%ebx
  80295d:	0f 84 b9 00 00 00    	je     802a1c <free+0xcc>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  802963:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  802969:	76 08                	jbe    802973 <free+0x23>
  80296b:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  802971:	76 24                	jbe    802997 <free+0x47>
  802973:	c7 44 24 0c 24 3a 80 	movl   $0x803a24,0xc(%esp)
  80297a:	00 
  80297b:	c7 44 24 08 ec 39 80 	movl   $0x8039ec,0x8(%esp)
  802982:	00 
  802983:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80298a:	00 
  80298b:	c7 04 24 54 3a 80 00 	movl   $0x803a54,(%esp)
  802992:	e8 15 dd ff ff       	call   8006ac <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  802997:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (vpt[PGNUM(c)] & PTE_CONTINUED) {
  80299d:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8029a2:	eb 4a                	jmp    8029ee <free+0x9e>
		sys_page_unmap(0, c);
  8029a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8029a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029af:	e8 3a ef ff ff       	call   8018ee <sys_page_unmap>
		c += PGSIZE;
  8029b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  8029ba:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  8029c0:	76 08                	jbe    8029ca <free+0x7a>
  8029c2:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  8029c8:	76 24                	jbe    8029ee <free+0x9e>
  8029ca:	c7 44 24 0c 61 3a 80 	movl   $0x803a61,0xc(%esp)
  8029d1:	00 
  8029d2:	c7 44 24 08 ec 39 80 	movl   $0x8039ec,0x8(%esp)
  8029d9:	00 
  8029da:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  8029e1:	00 
  8029e2:	c7 04 24 54 3a 80 00 	movl   $0x803a54,(%esp)
  8029e9:	e8 be dc ff ff       	call   8006ac <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (vpt[PGNUM(c)] & PTE_CONTINUED) {
  8029ee:	89 d8                	mov    %ebx,%eax
  8029f0:	c1 e8 0c             	shr    $0xc,%eax
  8029f3:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8029f6:	f6 c4 04             	test   $0x4,%ah
  8029f9:	75 a9                	jne    8029a4 <free+0x54>

	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
  8029fb:	8d 93 fc 0f 00 00    	lea    0xffc(%ebx),%edx
	if (--(*ref) == 0)
  802a01:	8b 02                	mov    (%edx),%eax
  802a03:	83 e8 01             	sub    $0x1,%eax
  802a06:	89 02                	mov    %eax,(%edx)
  802a08:	85 c0                	test   %eax,%eax
  802a0a:	75 10                	jne    802a1c <free+0xcc>
		sys_page_unmap(0, c);
  802a0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802a10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a17:	e8 d2 ee ff ff       	call   8018ee <sys_page_unmap>
}
  802a1c:	83 c4 10             	add    $0x10,%esp
  802a1f:	5b                   	pop    %ebx
  802a20:	5e                   	pop    %esi
  802a21:	5d                   	pop    %ebp
  802a22:	c3                   	ret    

00802a23 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  802a23:	55                   	push   %ebp
  802a24:	89 e5                	mov    %esp,%ebp
  802a26:	57                   	push   %edi
  802a27:	56                   	push   %esi
  802a28:	53                   	push   %ebx
  802a29:	83 ec 3c             	sub    $0x3c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  802a2c:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  802a33:	75 0a                	jne    802a3f <malloc+0x1c>
		mptr = mbegin;
  802a35:	c7 05 08 50 80 00 00 	movl   $0x8000000,0x805008
  802a3c:	00 00 08 

	n = ROUNDUP(n, 4);
  802a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  802a42:	83 c0 03             	add    $0x3,%eax
  802a45:	83 e0 fc             	and    $0xfffffffc,%eax
  802a48:	89 45 d8             	mov    %eax,-0x28(%ebp)

	if (n >= MAXMALLOC)
  802a4b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  802a50:	0f 87 97 01 00 00    	ja     802bed <malloc+0x1ca>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  802a56:	a1 08 50 80 00       	mov    0x805008,%eax
  802a5b:	89 c2                	mov    %eax,%edx
  802a5d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  802a62:	74 4d                	je     802ab1 <malloc+0x8e>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  802a64:	89 c3                	mov    %eax,%ebx
  802a66:	c1 eb 0c             	shr    $0xc,%ebx
  802a69:	8b 75 d8             	mov    -0x28(%ebp),%esi
  802a6c:	8d 4c 30 03          	lea    0x3(%eax,%esi,1),%ecx
  802a70:	c1 e9 0c             	shr    $0xc,%ecx
  802a73:	39 cb                	cmp    %ecx,%ebx
  802a75:	75 1e                	jne    802a95 <malloc+0x72>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  802a77:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  802a7d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802a83:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  802a87:	8d 14 30             	lea    (%eax,%esi,1),%edx
  802a8a:	89 15 08 50 80 00    	mov    %edx,0x805008
			return v;
  802a90:	e9 5d 01 00 00       	jmp    802bf2 <malloc+0x1cf>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  802a95:	89 04 24             	mov    %eax,(%esp)
  802a98:	e8 b3 fe ff ff       	call   802950 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802a9d:	a1 08 50 80 00       	mov    0x805008,%eax
  802aa2:	05 00 10 00 00       	add    $0x1000,%eax
  802aa7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802aac:	a3 08 50 80 00       	mov    %eax,0x805008
  802ab1:	8b 3d 08 50 80 00    	mov    0x805008,%edi
  802ab7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			return 0;
	return 1;
}

void*
malloc(size_t n)
  802abe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802ac1:	83 c0 04             	add    $0x4,%eax
  802ac4:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
		    || ((vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P)))
  802ac7:	bb 00 d0 7b ef       	mov    $0xef7bd000,%ebx
  802acc:	be 00 00 40 ef       	mov    $0xef400000,%esi
			return 0;
	return 1;
}

void*
malloc(size_t n)
  802ad1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  802ad4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802ad7:	8d 0c 0f             	lea    (%edi,%ecx,1),%ecx
  802ada:	89 7d e4             	mov    %edi,-0x1c(%ebp)
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802add:	39 cf                	cmp    %ecx,%edi
  802adf:	0f 83 d7 00 00 00    	jae    802bbc <malloc+0x199>
		if (va >= (uintptr_t) mend
  802ae5:	89 f8                	mov    %edi,%eax
  802ae7:	81 ff ff ff ff 0f    	cmp    $0xfffffff,%edi
  802aed:	76 09                	jbe    802af8 <malloc+0xd5>
  802aef:	eb 38                	jmp    802b29 <malloc+0x106>
  802af1:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  802af6:	77 31                	ja     802b29 <malloc+0x106>
		    || ((vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P)))
  802af8:	89 c2                	mov    %eax,%edx
  802afa:	c1 ea 16             	shr    $0x16,%edx
  802afd:	8b 14 93             	mov    (%ebx,%edx,4),%edx
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
  802b00:	f6 c2 01             	test   $0x1,%dl
  802b03:	74 0d                	je     802b12 <malloc+0xef>
		    || ((vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P)))
  802b05:	89 c2                	mov    %eax,%edx
  802b07:	c1 ea 0c             	shr    $0xc,%edx
  802b0a:	8b 14 96             	mov    (%esi,%edx,4),%edx
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
  802b0d:	f6 c2 01             	test   $0x1,%dl
  802b10:	75 17                	jne    802b29 <malloc+0x106>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802b12:	05 00 10 00 00       	add    $0x1000,%eax
  802b17:	39 c8                	cmp    %ecx,%eax
  802b19:	72 d6                	jb     802af1 <malloc+0xce>
  802b1b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802b1e:	89 35 08 50 80 00    	mov    %esi,0x805008
  802b24:	e9 9b 00 00 00       	jmp    802bc4 <malloc+0x1a1>
  802b29:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802b2f:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  802b35:	81 ff 00 00 00 10    	cmp    $0x10000000,%edi
  802b3b:	75 9d                	jne    802ada <malloc+0xb7>
			mptr = mbegin;
			if (++nwrap == 2)
  802b3d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  802b41:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
  802b45:	74 07                	je     802b4e <malloc+0x12b>
  802b47:	bf 00 00 00 08       	mov    $0x8000000,%edi
  802b4c:	eb 83                	jmp    802ad1 <malloc+0xae>
  802b4e:	c7 05 08 50 80 00 00 	movl   $0x8000000,0x805008
  802b55:	00 00 08 
  802b58:	b8 00 00 00 00       	mov    $0x0,%eax
  802b5d:	e9 90 00 00 00       	jmp    802bf2 <malloc+0x1cf>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  802b62:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
  802b68:	39 fe                	cmp    %edi,%esi
  802b6a:	19 c0                	sbb    %eax,%eax
  802b6c:	25 00 04 00 00       	and    $0x400,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  802b71:	83 c8 07             	or     $0x7,%eax
  802b74:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b78:	03 15 08 50 80 00    	add    0x805008,%edx
  802b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b89:	e8 3a ee ff ff       	call   8019c8 <sys_page_alloc>
  802b8e:	85 c0                	test   %eax,%eax
  802b90:	78 04                	js     802b96 <malloc+0x173>
  802b92:	89 f3                	mov    %esi,%ebx
  802b94:	eb 36                	jmp    802bcc <malloc+0x1a9>
			for (; i >= 0; i -= PGSIZE)
  802b96:	85 db                	test   %ebx,%ebx
  802b98:	78 53                	js     802bed <malloc+0x1ca>
				sys_page_unmap(0, mptr + i);
  802b9a:	89 d8                	mov    %ebx,%eax
  802b9c:	03 05 08 50 80 00    	add    0x805008,%eax
  802ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ba6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bad:	e8 3c ed ff ff       	call   8018ee <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802bb2:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  802bb8:	79 e0                	jns    802b9a <malloc+0x177>
  802bba:	eb 31                	jmp    802bed <malloc+0x1ca>
  802bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bbf:	a3 08 50 80 00       	mov    %eax,0x805008
  802bc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bc9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  802bcc:	89 da                	mov    %ebx,%edx
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802bce:	39 fb                	cmp    %edi,%ebx
  802bd0:	72 90                	jb     802b62 <malloc+0x13f>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  802bd2:	a1 08 50 80 00       	mov    0x805008,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802bd7:	c7 44 18 fc 02 00 00 	movl   $0x2,-0x4(%eax,%ebx,1)
  802bde:	00 
	v = mptr;
	mptr += n;
  802bdf:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802be2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802be5:	89 15 08 50 80 00    	mov    %edx,0x805008
	return v;
  802beb:	eb 05                	jmp    802bf2 <malloc+0x1cf>
  802bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bf2:	83 c4 3c             	add    $0x3c,%esp
  802bf5:	5b                   	pop    %ebx
  802bf6:	5e                   	pop    %esi
  802bf7:	5f                   	pop    %edi
  802bf8:	5d                   	pop    %ebp
  802bf9:	c3                   	ret    
  802bfa:	00 00                	add    %al,(%eax)
  802bfc:	00 00                	add    %al,(%eax)
	...

00802c00 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c00:	55                   	push   %ebp
  802c01:	89 e5                	mov    %esp,%ebp
  802c03:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802c06:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  802c0c:	b8 01 00 00 00       	mov    $0x1,%eax
  802c11:	39 ca                	cmp    %ecx,%edx
  802c13:	75 04                	jne    802c19 <ipc_find_env+0x19>
  802c15:	b0 00                	mov    $0x0,%al
  802c17:	eb 12                	jmp    802c2b <ipc_find_env+0x2b>
  802c19:	89 c2                	mov    %eax,%edx
  802c1b:	c1 e2 07             	shl    $0x7,%edx
  802c1e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802c25:	8b 12                	mov    (%edx),%edx
  802c27:	39 ca                	cmp    %ecx,%edx
  802c29:	75 10                	jne    802c3b <ipc_find_env+0x3b>
			return envs[i].env_id;
  802c2b:	89 c2                	mov    %eax,%edx
  802c2d:	c1 e2 07             	shl    $0x7,%edx
  802c30:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802c37:	8b 00                	mov    (%eax),%eax
  802c39:	eb 0e                	jmp    802c49 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802c3b:	83 c0 01             	add    $0x1,%eax
  802c3e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c43:	75 d4                	jne    802c19 <ipc_find_env+0x19>
  802c45:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802c49:	5d                   	pop    %ebp
  802c4a:	c3                   	ret    

00802c4b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802c4b:	55                   	push   %ebp
  802c4c:	89 e5                	mov    %esp,%ebp
  802c4e:	57                   	push   %edi
  802c4f:	56                   	push   %esi
  802c50:	53                   	push   %ebx
  802c51:	83 ec 1c             	sub    $0x1c,%esp
  802c54:	8b 75 08             	mov    0x8(%ebp),%esi
  802c57:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  802c5d:	85 db                	test   %ebx,%ebx
  802c5f:	74 19                	je     802c7a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802c61:	8b 45 14             	mov    0x14(%ebp),%eax
  802c64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c6c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c70:	89 34 24             	mov    %esi,(%esp)
  802c73:	e8 f1 ea ff ff       	call   801769 <sys_ipc_try_send>
  802c78:	eb 1b                	jmp    802c95 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  802c7a:	8b 45 14             	mov    0x14(%ebp),%eax
  802c7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c81:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802c88:	ee 
  802c89:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c8d:	89 34 24             	mov    %esi,(%esp)
  802c90:	e8 d4 ea ff ff       	call   801769 <sys_ipc_try_send>
           if(ret == 0)
  802c95:	85 c0                	test   %eax,%eax
  802c97:	74 28                	je     802cc1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802c99:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802c9c:	74 1c                	je     802cba <ipc_send+0x6f>
              panic("ipc send error");
  802c9e:	c7 44 24 08 79 3a 80 	movl   $0x803a79,0x8(%esp)
  802ca5:	00 
  802ca6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  802cad:	00 
  802cae:	c7 04 24 88 3a 80 00 	movl   $0x803a88,(%esp)
  802cb5:	e8 f2 d9 ff ff       	call   8006ac <_panic>
           sys_yield();
  802cba:	e8 76 ed ff ff       	call   801a35 <sys_yield>
        }
  802cbf:	eb 9c                	jmp    802c5d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802cc1:	83 c4 1c             	add    $0x1c,%esp
  802cc4:	5b                   	pop    %ebx
  802cc5:	5e                   	pop    %esi
  802cc6:	5f                   	pop    %edi
  802cc7:	5d                   	pop    %ebp
  802cc8:	c3                   	ret    

00802cc9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802cc9:	55                   	push   %ebp
  802cca:	89 e5                	mov    %esp,%ebp
  802ccc:	56                   	push   %esi
  802ccd:	53                   	push   %ebx
  802cce:	83 ec 10             	sub    $0x10,%esp
  802cd1:	8b 75 08             	mov    0x8(%ebp),%esi
  802cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  802cda:	85 c0                	test   %eax,%eax
  802cdc:	75 0e                	jne    802cec <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  802cde:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802ce5:	e8 14 ea ff ff       	call   8016fe <sys_ipc_recv>
  802cea:	eb 08                	jmp    802cf4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  802cec:	89 04 24             	mov    %eax,(%esp)
  802cef:	e8 0a ea ff ff       	call   8016fe <sys_ipc_recv>
        if(ret == 0){
  802cf4:	85 c0                	test   %eax,%eax
  802cf6:	75 26                	jne    802d1e <ipc_recv+0x55>
           if(from_env_store)
  802cf8:	85 f6                	test   %esi,%esi
  802cfa:	74 0a                	je     802d06 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  802cfc:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802d01:	8b 40 78             	mov    0x78(%eax),%eax
  802d04:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802d06:	85 db                	test   %ebx,%ebx
  802d08:	74 0a                	je     802d14 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  802d0a:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802d0f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802d12:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802d14:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802d19:	8b 40 74             	mov    0x74(%eax),%eax
  802d1c:	eb 14                	jmp    802d32 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  802d1e:	85 f6                	test   %esi,%esi
  802d20:	74 06                	je     802d28 <ipc_recv+0x5f>
              *from_env_store = 0;
  802d22:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802d28:	85 db                	test   %ebx,%ebx
  802d2a:	74 06                	je     802d32 <ipc_recv+0x69>
              *perm_store = 0;
  802d2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802d32:	83 c4 10             	add    $0x10,%esp
  802d35:	5b                   	pop    %ebx
  802d36:	5e                   	pop    %esi
  802d37:	5d                   	pop    %ebp
  802d38:	c3                   	ret    
  802d39:	00 00                	add    %al,(%eax)
	...

00802d3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802d3c:	55                   	push   %ebp
  802d3d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  802d42:	89 c2                	mov    %eax,%edx
  802d44:	c1 ea 16             	shr    $0x16,%edx
  802d47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802d4e:	f6 c2 01             	test   $0x1,%dl
  802d51:	74 20                	je     802d73 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802d53:	c1 e8 0c             	shr    $0xc,%eax
  802d56:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802d5d:	a8 01                	test   $0x1,%al
  802d5f:	74 12                	je     802d73 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802d61:	c1 e8 0c             	shr    $0xc,%eax
  802d64:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802d69:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802d6e:	0f b7 c0             	movzwl %ax,%eax
  802d71:	eb 05                	jmp    802d78 <pageref+0x3c>
  802d73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d78:	5d                   	pop    %ebp
  802d79:	c3                   	ret    
  802d7a:	00 00                	add    %al,(%eax)
  802d7c:	00 00                	add    %al,(%eax)
	...

00802d80 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802d80:	55                   	push   %ebp
  802d81:	89 e5                	mov    %esp,%ebp
  802d83:	57                   	push   %edi
  802d84:	56                   	push   %esi
  802d85:	53                   	push   %ebx
  802d86:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802d89:	8b 45 08             	mov    0x8(%ebp),%eax
  802d8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  802d8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d92:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802d95:	8d 45 f3             	lea    -0xd(%ebp),%eax
  802d98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802d9b:	b9 0c 50 80 00       	mov    $0x80500c,%ecx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802da0:	ba cd ff ff ff       	mov    $0xffffffcd,%edx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802da8:	0f b6 18             	movzbl (%eax),%ebx
  802dab:	be 00 00 00 00       	mov    $0x0,%esi
  802db0:	89 f0                	mov    %esi,%eax
  802db2:	89 ce                	mov    %ecx,%esi
  802db4:	89 c1                	mov    %eax,%ecx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802db6:	89 d8                	mov    %ebx,%eax
  802db8:	f6 e2                	mul    %dl
  802dba:	66 c1 e8 08          	shr    $0x8,%ax
  802dbe:	c0 e8 03             	shr    $0x3,%al
  802dc1:	89 c7                	mov    %eax,%edi
  802dc3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  802dc6:	01 c0                	add    %eax,%eax
  802dc8:	28 c3                	sub    %al,%bl
  802dca:	89 d8                	mov    %ebx,%eax
      *ap /= (u8_t)10;
  802dcc:	89 fb                	mov    %edi,%ebx
      inv[i++] = '0' + rem;
  802dce:	0f b6 f9             	movzbl %cl,%edi
  802dd1:	83 c0 30             	add    $0x30,%eax
  802dd4:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
  802dd8:	83 c1 01             	add    $0x1,%ecx
    } while(*ap);
  802ddb:	84 db                	test   %bl,%bl
  802ddd:	75 d7                	jne    802db6 <inet_ntoa+0x36>
  802ddf:	89 c8                	mov    %ecx,%eax
  802de1:	89 f1                	mov    %esi,%ecx
  802de3:	89 c6                	mov    %eax,%esi
  802de5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802de8:	88 18                	mov    %bl,(%eax)
    while(i--)
  802dea:	89 f0                	mov    %esi,%eax
  802dec:	84 c0                	test   %al,%al
  802dee:	74 2c                	je     802e1c <inet_ntoa+0x9c>
  802df0:	8d 5e ff             	lea    -0x1(%esi),%ebx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802df3:	0f b6 c3             	movzbl %bl,%eax
  802df6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802df9:	8d 7c 01 01          	lea    0x1(%ecx,%eax,1),%edi
  802dfd:	89 c8                	mov    %ecx,%eax
  802dff:	89 ce                	mov    %ecx,%esi
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  802e01:	0f b6 cb             	movzbl %bl,%ecx
  802e04:	0f b6 4c 0d ed       	movzbl -0x13(%ebp,%ecx,1),%ecx
  802e09:	88 08                	mov    %cl,(%eax)
  802e0b:	83 c0 01             	add    $0x1,%eax
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  802e0e:	83 eb 01             	sub    $0x1,%ebx
  802e11:	39 f8                	cmp    %edi,%eax
  802e13:	75 ec                	jne    802e01 <inet_ntoa+0x81>
  802e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802e18:	8d 4c 06 01          	lea    0x1(%esi,%eax,1),%ecx
      *rp++ = inv[i];
    *rp++ = '.';
  802e1c:	c6 01 2e             	movb   $0x2e,(%ecx)
  802e1f:	83 c1 01             	add    $0x1,%ecx
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802e22:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802e25:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  802e28:	74 09                	je     802e33 <inet_ntoa+0xb3>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  802e2a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  802e2e:	e9 72 ff ff ff       	jmp    802da5 <inet_ntoa+0x25>
  }
  *--rp = 0;
  802e33:	c6 41 ff 00          	movb   $0x0,-0x1(%ecx)
  return str;
}
  802e37:	b8 0c 50 80 00       	mov    $0x80500c,%eax
  802e3c:	83 c4 1c             	add    $0x1c,%esp
  802e3f:	5b                   	pop    %ebx
  802e40:	5e                   	pop    %esi
  802e41:	5f                   	pop    %edi
  802e42:	5d                   	pop    %ebp
  802e43:	c3                   	ret    

00802e44 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  802e44:	55                   	push   %ebp
  802e45:	89 e5                	mov    %esp,%ebp
  802e47:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802e4b:	66 c1 c0 08          	rol    $0x8,%ax
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}
  802e4f:	5d                   	pop    %ebp
  802e50:	c3                   	ret    

00802e51 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802e51:	55                   	push   %ebp
  802e52:	89 e5                	mov    %esp,%ebp
  802e54:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  802e57:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802e5b:	89 04 24             	mov    %eax,(%esp)
  802e5e:	e8 e1 ff ff ff       	call   802e44 <htons>
}
  802e63:	c9                   	leave  
  802e64:	c3                   	ret    

00802e65 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  802e65:	55                   	push   %ebp
  802e66:	89 e5                	mov    %esp,%ebp
  802e68:	8b 55 08             	mov    0x8(%ebp),%edx
  802e6b:	89 d1                	mov    %edx,%ecx
  802e6d:	c1 e9 18             	shr    $0x18,%ecx
  802e70:	89 d0                	mov    %edx,%eax
  802e72:	c1 e0 18             	shl    $0x18,%eax
  802e75:	09 c8                	or     %ecx,%eax
  802e77:	89 d1                	mov    %edx,%ecx
  802e79:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  802e7f:	c1 e1 08             	shl    $0x8,%ecx
  802e82:	09 c8                	or     %ecx,%eax
  802e84:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  802e8a:	c1 ea 08             	shr    $0x8,%edx
  802e8d:	09 d0                	or     %edx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802e8f:	5d                   	pop    %ebp
  802e90:	c3                   	ret    

00802e91 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802e91:	55                   	push   %ebp
  802e92:	89 e5                	mov    %esp,%ebp
  802e94:	57                   	push   %edi
  802e95:	56                   	push   %esi
  802e96:	53                   	push   %ebx
  802e97:	83 ec 28             	sub    $0x28,%esp
  802e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  802e9d:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802ea0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802ea3:	80 f9 09             	cmp    $0x9,%cl
  802ea6:	0f 87 af 01 00 00    	ja     80305b <inet_aton+0x1ca>
  802eac:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  802eaf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802eb2:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  802eb5:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  802eb8:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  802ebf:	83 fa 30             	cmp    $0x30,%edx
  802ec2:	75 24                	jne    802ee8 <inet_aton+0x57>
      c = *++cp;
  802ec4:	83 c0 01             	add    $0x1,%eax
  802ec7:	0f be 10             	movsbl (%eax),%edx
      if (c == 'x' || c == 'X') {
  802eca:	83 fa 78             	cmp    $0x78,%edx
  802ecd:	74 0c                	je     802edb <inet_aton+0x4a>
  802ecf:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  802ed6:	83 fa 58             	cmp    $0x58,%edx
  802ed9:	75 0d                	jne    802ee8 <inet_aton+0x57>
        base = 16;
        c = *++cp;
  802edb:	83 c0 01             	add    $0x1,%eax
  802ede:	0f be 10             	movsbl (%eax),%edx
  802ee1:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  802ee8:	83 c0 01             	add    $0x1,%eax
  802eeb:	be 00 00 00 00       	mov    $0x0,%esi
  802ef0:	eb 03                	jmp    802ef5 <inet_aton+0x64>
  802ef2:	83 c0 01             	add    $0x1,%eax
  802ef5:	8d 78 ff             	lea    -0x1(%eax),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  802ef8:	89 d1                	mov    %edx,%ecx
  802efa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802efd:	80 fb 09             	cmp    $0x9,%bl
  802f00:	77 0d                	ja     802f0f <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  802f02:	0f af 75 e0          	imul   -0x20(%ebp),%esi
  802f06:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  802f0a:	0f be 10             	movsbl (%eax),%edx
  802f0d:	eb e3                	jmp    802ef2 <inet_aton+0x61>
      } else if (base == 16 && isxdigit(c)) {
  802f0f:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  802f13:	75 2b                	jne    802f40 <inet_aton+0xaf>
  802f15:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802f18:	88 5d d3             	mov    %bl,-0x2d(%ebp)
  802f1b:	80 fb 05             	cmp    $0x5,%bl
  802f1e:	76 08                	jbe    802f28 <inet_aton+0x97>
  802f20:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802f23:	80 fb 05             	cmp    $0x5,%bl
  802f26:	77 18                	ja     802f40 <inet_aton+0xaf>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802f28:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  802f2c:	19 c9                	sbb    %ecx,%ecx
  802f2e:	83 e1 20             	and    $0x20,%ecx
  802f31:	c1 e6 04             	shl    $0x4,%esi
  802f34:	29 ca                	sub    %ecx,%edx
  802f36:	8d 52 c9             	lea    -0x37(%edx),%edx
  802f39:	09 d6                	or     %edx,%esi
        c = *++cp;
  802f3b:	0f be 10             	movsbl (%eax),%edx
  802f3e:	eb b2                	jmp    802ef2 <inet_aton+0x61>
      } else
        break;
    }
    if (c == '.') {
  802f40:	83 fa 2e             	cmp    $0x2e,%edx
  802f43:	75 2c                	jne    802f71 <inet_aton+0xe0>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802f45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802f48:	39 55 d8             	cmp    %edx,-0x28(%ebp)
  802f4b:	0f 83 0a 01 00 00    	jae    80305b <inet_aton+0x1ca>
        return (0);
      *pp++ = val;
  802f51:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802f54:	89 31                	mov    %esi,(%ecx)
      c = *++cp;
  802f56:	8d 47 01             	lea    0x1(%edi),%eax
  802f59:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802f5c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802f5f:	80 f9 09             	cmp    $0x9,%cl
  802f62:	0f 87 f3 00 00 00    	ja     80305b <inet_aton+0x1ca>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  802f68:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  802f6c:	e9 47 ff ff ff       	jmp    802eb8 <inet_aton+0x27>
  802f71:	89 f3                	mov    %esi,%ebx
  802f73:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  802f75:	85 d2                	test   %edx,%edx
  802f77:	74 37                	je     802fb0 <inet_aton+0x11f>
  802f79:	80 f9 1f             	cmp    $0x1f,%cl
  802f7c:	0f 86 d9 00 00 00    	jbe    80305b <inet_aton+0x1ca>
  802f82:	84 d2                	test   %dl,%dl
  802f84:	0f 88 d1 00 00 00    	js     80305b <inet_aton+0x1ca>
  802f8a:	83 fa 20             	cmp    $0x20,%edx
  802f8d:	8d 76 00             	lea    0x0(%esi),%esi
  802f90:	74 1e                	je     802fb0 <inet_aton+0x11f>
  802f92:	83 fa 0c             	cmp    $0xc,%edx
  802f95:	74 19                	je     802fb0 <inet_aton+0x11f>
  802f97:	83 fa 0a             	cmp    $0xa,%edx
  802f9a:	74 14                	je     802fb0 <inet_aton+0x11f>
  802f9c:	83 fa 0d             	cmp    $0xd,%edx
  802f9f:	90                   	nop
  802fa0:	74 0e                	je     802fb0 <inet_aton+0x11f>
  802fa2:	83 fa 09             	cmp    $0x9,%edx
  802fa5:	74 09                	je     802fb0 <inet_aton+0x11f>
  802fa7:	83 fa 0b             	cmp    $0xb,%edx
  802faa:	0f 85 ab 00 00 00    	jne    80305b <inet_aton+0x1ca>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  802fb0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  802fb3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802fb6:	29 d1                	sub    %edx,%ecx
  802fb8:	89 ca                	mov    %ecx,%edx
  802fba:	c1 fa 02             	sar    $0x2,%edx
  802fbd:	83 c2 01             	add    $0x1,%edx
  802fc0:	83 fa 02             	cmp    $0x2,%edx
  802fc3:	74 2d                	je     802ff2 <inet_aton+0x161>
  802fc5:	83 fa 02             	cmp    $0x2,%edx
  802fc8:	7f 10                	jg     802fda <inet_aton+0x149>
  802fca:	85 d2                	test   %edx,%edx
  802fcc:	0f 84 89 00 00 00    	je     80305b <inet_aton+0x1ca>
  802fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802fd8:	eb 62                	jmp    80303c <inet_aton+0x1ab>
  802fda:	83 fa 03             	cmp    $0x3,%edx
  802fdd:	8d 76 00             	lea    0x0(%esi),%esi
  802fe0:	74 22                	je     803004 <inet_aton+0x173>
  802fe2:	83 fa 04             	cmp    $0x4,%edx
  802fe5:	8d 76 00             	lea    0x0(%esi),%esi
  802fe8:	75 52                	jne    80303c <inet_aton+0x1ab>
  802fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ff0:	eb 2b                	jmp    80301d <inet_aton+0x18c>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  802ff2:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  802ff7:	90                   	nop
  802ff8:	77 61                	ja     80305b <inet_aton+0x1ca>
      return (0);
    val |= parts[0] << 24;
  802ffa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802ffd:	c1 e3 18             	shl    $0x18,%ebx
  803000:	09 c3                	or     %eax,%ebx
    break;
  803002:	eb 38                	jmp    80303c <inet_aton+0x1ab>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  803004:	3d ff ff 00 00       	cmp    $0xffff,%eax
  803009:	77 50                	ja     80305b <inet_aton+0x1ca>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80300b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  80300e:	c1 e3 10             	shl    $0x10,%ebx
  803011:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803014:	c1 e2 18             	shl    $0x18,%edx
  803017:	09 d3                	or     %edx,%ebx
  803019:	09 c3                	or     %eax,%ebx
    break;
  80301b:	eb 1f                	jmp    80303c <inet_aton+0x1ab>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80301d:	3d ff 00 00 00       	cmp    $0xff,%eax
  803022:	77 37                	ja     80305b <inet_aton+0x1ca>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  803024:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  803027:	c1 e3 10             	shl    $0x10,%ebx
  80302a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80302d:	c1 e2 18             	shl    $0x18,%edx
  803030:	09 d3                	or     %edx,%ebx
  803032:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803035:	c1 e2 08             	shl    $0x8,%edx
  803038:	09 d3                	or     %edx,%ebx
  80303a:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  80303c:	b8 01 00 00 00       	mov    $0x1,%eax
  803041:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803045:	74 19                	je     803060 <inet_aton+0x1cf>
    addr->s_addr = htonl(val);
  803047:	89 1c 24             	mov    %ebx,(%esp)
  80304a:	e8 16 fe ff ff       	call   802e65 <htonl>
  80304f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  803052:	89 03                	mov    %eax,(%ebx)
  803054:	b8 01 00 00 00       	mov    $0x1,%eax
  803059:	eb 05                	jmp    803060 <inet_aton+0x1cf>
  80305b:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  803060:	83 c4 28             	add    $0x28,%esp
  803063:	5b                   	pop    %ebx
  803064:	5e                   	pop    %esi
  803065:	5f                   	pop    %edi
  803066:	5d                   	pop    %ebp
  803067:	c3                   	ret    

00803068 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  803068:	55                   	push   %ebp
  803069:	89 e5                	mov    %esp,%ebp
  80306b:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80306e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  803071:	89 44 24 04          	mov    %eax,0x4(%esp)
  803075:	8b 45 08             	mov    0x8(%ebp),%eax
  803078:	89 04 24             	mov    %eax,(%esp)
  80307b:	e8 11 fe ff ff       	call   802e91 <inet_aton>
  803080:	83 f8 01             	cmp    $0x1,%eax
  803083:	19 c0                	sbb    %eax,%eax
  803085:	0b 45 fc             	or     -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  803088:	c9                   	leave  
  803089:	c3                   	ret    

0080308a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80308a:	55                   	push   %ebp
  80308b:	89 e5                	mov    %esp,%ebp
  80308d:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  803090:	8b 45 08             	mov    0x8(%ebp),%eax
  803093:	89 04 24             	mov    %eax,(%esp)
  803096:	e8 ca fd ff ff       	call   802e65 <htonl>
}
  80309b:	c9                   	leave  
  80309c:	c3                   	ret    
  80309d:	00 00                	add    %al,(%eax)
	...

008030a0 <__udivdi3>:
  8030a0:	55                   	push   %ebp
  8030a1:	89 e5                	mov    %esp,%ebp
  8030a3:	57                   	push   %edi
  8030a4:	56                   	push   %esi
  8030a5:	83 ec 10             	sub    $0x10,%esp
  8030a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8030ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8030ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8030b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8030b4:	85 c0                	test   %eax,%eax
  8030b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8030b9:	75 35                	jne    8030f0 <__udivdi3+0x50>
  8030bb:	39 fe                	cmp    %edi,%esi
  8030bd:	77 61                	ja     803120 <__udivdi3+0x80>
  8030bf:	85 f6                	test   %esi,%esi
  8030c1:	75 0b                	jne    8030ce <__udivdi3+0x2e>
  8030c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8030c8:	31 d2                	xor    %edx,%edx
  8030ca:	f7 f6                	div    %esi
  8030cc:	89 c6                	mov    %eax,%esi
  8030ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8030d1:	31 d2                	xor    %edx,%edx
  8030d3:	89 f8                	mov    %edi,%eax
  8030d5:	f7 f6                	div    %esi
  8030d7:	89 c7                	mov    %eax,%edi
  8030d9:	89 c8                	mov    %ecx,%eax
  8030db:	f7 f6                	div    %esi
  8030dd:	89 c1                	mov    %eax,%ecx
  8030df:	89 fa                	mov    %edi,%edx
  8030e1:	89 c8                	mov    %ecx,%eax
  8030e3:	83 c4 10             	add    $0x10,%esp
  8030e6:	5e                   	pop    %esi
  8030e7:	5f                   	pop    %edi
  8030e8:	5d                   	pop    %ebp
  8030e9:	c3                   	ret    
  8030ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8030f0:	39 f8                	cmp    %edi,%eax
  8030f2:	77 1c                	ja     803110 <__udivdi3+0x70>
  8030f4:	0f bd d0             	bsr    %eax,%edx
  8030f7:	83 f2 1f             	xor    $0x1f,%edx
  8030fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8030fd:	75 39                	jne    803138 <__udivdi3+0x98>
  8030ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  803102:	0f 86 a0 00 00 00    	jbe    8031a8 <__udivdi3+0x108>
  803108:	39 f8                	cmp    %edi,%eax
  80310a:	0f 82 98 00 00 00    	jb     8031a8 <__udivdi3+0x108>
  803110:	31 ff                	xor    %edi,%edi
  803112:	31 c9                	xor    %ecx,%ecx
  803114:	89 c8                	mov    %ecx,%eax
  803116:	89 fa                	mov    %edi,%edx
  803118:	83 c4 10             	add    $0x10,%esp
  80311b:	5e                   	pop    %esi
  80311c:	5f                   	pop    %edi
  80311d:	5d                   	pop    %ebp
  80311e:	c3                   	ret    
  80311f:	90                   	nop
  803120:	89 d1                	mov    %edx,%ecx
  803122:	89 fa                	mov    %edi,%edx
  803124:	89 c8                	mov    %ecx,%eax
  803126:	31 ff                	xor    %edi,%edi
  803128:	f7 f6                	div    %esi
  80312a:	89 c1                	mov    %eax,%ecx
  80312c:	89 fa                	mov    %edi,%edx
  80312e:	89 c8                	mov    %ecx,%eax
  803130:	83 c4 10             	add    $0x10,%esp
  803133:	5e                   	pop    %esi
  803134:	5f                   	pop    %edi
  803135:	5d                   	pop    %ebp
  803136:	c3                   	ret    
  803137:	90                   	nop
  803138:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80313c:	89 f2                	mov    %esi,%edx
  80313e:	d3 e0                	shl    %cl,%eax
  803140:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803143:	b8 20 00 00 00       	mov    $0x20,%eax
  803148:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80314b:	89 c1                	mov    %eax,%ecx
  80314d:	d3 ea                	shr    %cl,%edx
  80314f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803153:	0b 55 ec             	or     -0x14(%ebp),%edx
  803156:	d3 e6                	shl    %cl,%esi
  803158:	89 c1                	mov    %eax,%ecx
  80315a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80315d:	89 fe                	mov    %edi,%esi
  80315f:	d3 ee                	shr    %cl,%esi
  803161:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803165:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803168:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80316b:	d3 e7                	shl    %cl,%edi
  80316d:	89 c1                	mov    %eax,%ecx
  80316f:	d3 ea                	shr    %cl,%edx
  803171:	09 d7                	or     %edx,%edi
  803173:	89 f2                	mov    %esi,%edx
  803175:	89 f8                	mov    %edi,%eax
  803177:	f7 75 ec             	divl   -0x14(%ebp)
  80317a:	89 d6                	mov    %edx,%esi
  80317c:	89 c7                	mov    %eax,%edi
  80317e:	f7 65 e8             	mull   -0x18(%ebp)
  803181:	39 d6                	cmp    %edx,%esi
  803183:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803186:	72 30                	jb     8031b8 <__udivdi3+0x118>
  803188:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80318b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80318f:	d3 e2                	shl    %cl,%edx
  803191:	39 c2                	cmp    %eax,%edx
  803193:	73 05                	jae    80319a <__udivdi3+0xfa>
  803195:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  803198:	74 1e                	je     8031b8 <__udivdi3+0x118>
  80319a:	89 f9                	mov    %edi,%ecx
  80319c:	31 ff                	xor    %edi,%edi
  80319e:	e9 71 ff ff ff       	jmp    803114 <__udivdi3+0x74>
  8031a3:	90                   	nop
  8031a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031a8:	31 ff                	xor    %edi,%edi
  8031aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8031af:	e9 60 ff ff ff       	jmp    803114 <__udivdi3+0x74>
  8031b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8031bb:	31 ff                	xor    %edi,%edi
  8031bd:	89 c8                	mov    %ecx,%eax
  8031bf:	89 fa                	mov    %edi,%edx
  8031c1:	83 c4 10             	add    $0x10,%esp
  8031c4:	5e                   	pop    %esi
  8031c5:	5f                   	pop    %edi
  8031c6:	5d                   	pop    %ebp
  8031c7:	c3                   	ret    
	...

008031d0 <__umoddi3>:
  8031d0:	55                   	push   %ebp
  8031d1:	89 e5                	mov    %esp,%ebp
  8031d3:	57                   	push   %edi
  8031d4:	56                   	push   %esi
  8031d5:	83 ec 20             	sub    $0x20,%esp
  8031d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8031db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8031de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8031e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8031e4:	85 d2                	test   %edx,%edx
  8031e6:	89 c8                	mov    %ecx,%eax
  8031e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8031eb:	75 13                	jne    803200 <__umoddi3+0x30>
  8031ed:	39 f7                	cmp    %esi,%edi
  8031ef:	76 3f                	jbe    803230 <__umoddi3+0x60>
  8031f1:	89 f2                	mov    %esi,%edx
  8031f3:	f7 f7                	div    %edi
  8031f5:	89 d0                	mov    %edx,%eax
  8031f7:	31 d2                	xor    %edx,%edx
  8031f9:	83 c4 20             	add    $0x20,%esp
  8031fc:	5e                   	pop    %esi
  8031fd:	5f                   	pop    %edi
  8031fe:	5d                   	pop    %ebp
  8031ff:	c3                   	ret    
  803200:	39 f2                	cmp    %esi,%edx
  803202:	77 4c                	ja     803250 <__umoddi3+0x80>
  803204:	0f bd ca             	bsr    %edx,%ecx
  803207:	83 f1 1f             	xor    $0x1f,%ecx
  80320a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80320d:	75 51                	jne    803260 <__umoddi3+0x90>
  80320f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  803212:	0f 87 e0 00 00 00    	ja     8032f8 <__umoddi3+0x128>
  803218:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80321b:	29 f8                	sub    %edi,%eax
  80321d:	19 d6                	sbb    %edx,%esi
  80321f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803225:	89 f2                	mov    %esi,%edx
  803227:	83 c4 20             	add    $0x20,%esp
  80322a:	5e                   	pop    %esi
  80322b:	5f                   	pop    %edi
  80322c:	5d                   	pop    %ebp
  80322d:	c3                   	ret    
  80322e:	66 90                	xchg   %ax,%ax
  803230:	85 ff                	test   %edi,%edi
  803232:	75 0b                	jne    80323f <__umoddi3+0x6f>
  803234:	b8 01 00 00 00       	mov    $0x1,%eax
  803239:	31 d2                	xor    %edx,%edx
  80323b:	f7 f7                	div    %edi
  80323d:	89 c7                	mov    %eax,%edi
  80323f:	89 f0                	mov    %esi,%eax
  803241:	31 d2                	xor    %edx,%edx
  803243:	f7 f7                	div    %edi
  803245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803248:	f7 f7                	div    %edi
  80324a:	eb a9                	jmp    8031f5 <__umoddi3+0x25>
  80324c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803250:	89 c8                	mov    %ecx,%eax
  803252:	89 f2                	mov    %esi,%edx
  803254:	83 c4 20             	add    $0x20,%esp
  803257:	5e                   	pop    %esi
  803258:	5f                   	pop    %edi
  803259:	5d                   	pop    %ebp
  80325a:	c3                   	ret    
  80325b:	90                   	nop
  80325c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803260:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803264:	d3 e2                	shl    %cl,%edx
  803266:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803269:	ba 20 00 00 00       	mov    $0x20,%edx
  80326e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  803271:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803274:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803278:	89 fa                	mov    %edi,%edx
  80327a:	d3 ea                	shr    %cl,%edx
  80327c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803280:	0b 55 f4             	or     -0xc(%ebp),%edx
  803283:	d3 e7                	shl    %cl,%edi
  803285:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803289:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80328c:	89 f2                	mov    %esi,%edx
  80328e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  803291:	89 c7                	mov    %eax,%edi
  803293:	d3 ea                	shr    %cl,%edx
  803295:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803299:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80329c:	89 c2                	mov    %eax,%edx
  80329e:	d3 e6                	shl    %cl,%esi
  8032a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8032a4:	d3 ea                	shr    %cl,%edx
  8032a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8032aa:	09 d6                	or     %edx,%esi
  8032ac:	89 f0                	mov    %esi,%eax
  8032ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8032b1:	d3 e7                	shl    %cl,%edi
  8032b3:	89 f2                	mov    %esi,%edx
  8032b5:	f7 75 f4             	divl   -0xc(%ebp)
  8032b8:	89 d6                	mov    %edx,%esi
  8032ba:	f7 65 e8             	mull   -0x18(%ebp)
  8032bd:	39 d6                	cmp    %edx,%esi
  8032bf:	72 2b                	jb     8032ec <__umoddi3+0x11c>
  8032c1:	39 c7                	cmp    %eax,%edi
  8032c3:	72 23                	jb     8032e8 <__umoddi3+0x118>
  8032c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8032c9:	29 c7                	sub    %eax,%edi
  8032cb:	19 d6                	sbb    %edx,%esi
  8032cd:	89 f0                	mov    %esi,%eax
  8032cf:	89 f2                	mov    %esi,%edx
  8032d1:	d3 ef                	shr    %cl,%edi
  8032d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8032d7:	d3 e0                	shl    %cl,%eax
  8032d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8032dd:	09 f8                	or     %edi,%eax
  8032df:	d3 ea                	shr    %cl,%edx
  8032e1:	83 c4 20             	add    $0x20,%esp
  8032e4:	5e                   	pop    %esi
  8032e5:	5f                   	pop    %edi
  8032e6:	5d                   	pop    %ebp
  8032e7:	c3                   	ret    
  8032e8:	39 d6                	cmp    %edx,%esi
  8032ea:	75 d9                	jne    8032c5 <__umoddi3+0xf5>
  8032ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8032ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8032f2:	eb d1                	jmp    8032c5 <__umoddi3+0xf5>
  8032f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8032f8:	39 f2                	cmp    %esi,%edx
  8032fa:	0f 82 18 ff ff ff    	jb     803218 <__umoddi3+0x48>
  803300:	e9 1d ff ff ff       	jmp    803222 <__umoddi3+0x52>
