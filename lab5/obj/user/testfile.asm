
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 4f 07 00 00       	call   800780 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  800048:	e8 8d 11 00 00       	call   8011da <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80005a:	e8 41 1b 00 00       	call   801ba0 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 6c 1b 00 00       	call   801beb <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 ce 1b 00 00       	call   801c69 <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec dc 02 00 00    	sub    $0x2dc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 20 28 80 00       	mov    $0x802820,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 2b 28 80 	movl   $0x80282b,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8000e0:	e8 0b 07 00 00       	call   8007f0 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8000fc:	e8 ef 06 00 00       	call   8007f0 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 55 28 80 00       	mov    $0x802855,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 5e 28 80 	movl   $0x80285e,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80012f:	e8 bc 06 00 00       	call   8007f0 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 04 2a 80 	movl   $0x802a04,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800166:	e8 85 06 00 00       	call   8007f0 <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 76 28 80 00 	movl   $0x802876,(%esp)
  800172:	e8 32 07 00 00       	call   8008a9 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 40 80 00    	call   *0x80401c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8001ad:	e8 3e 06 00 00       	call   8007f0 <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 40 80 00       	mov    0x804000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 d1 0f 00 00       	call   801190 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 40 80 00       	mov    0x804000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 bf 0f 00 00       	call   801190 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 34 2a 80 	movl   $0x802a34,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8001f3:	e8 f8 05 00 00       	call   8007f0 <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 98 28 80 00 	movl   $0x802898,(%esp)
  8001ff:	e8 a5 06 00 00       	call   8008a9 <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 44 11 00 00       	call   801366 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 40 80 00    	call   *0x804010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 ab 28 80 	movl   $0x8028ab,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80025a:	e8 91 05 00 00       	call   8007f0 <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 40 80 00       	mov    0x804000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 1f 10 00 00       	call   801295 <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 b9 28 80 	movl   $0x8028b9,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800291:	e8 5a 05 00 00       	call   8007f0 <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 d7 28 80 00 	movl   $0x8028d7,(%esp)
  80029d:	e8 07 06 00 00       	call   8008a9 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 40 80 00    	call   *0x804018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 ea 28 80 	movl   $0x8028ea,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8002ce:	e8 1d 05 00 00       	call   8007f0 <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 f9 28 80 00 	movl   $0x8028f9,(%esp)
  8002da:	e8 ca 05 00 00       	call   8008a9 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	b8 00 c0 cc cc       	mov    $0xccccc000,%eax
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8002e9:	8b 50 04             	mov    0x4(%eax),%edx
  8002ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002ef:	8b 50 08             	mov    0x8(%eax),%edx
  8002f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8002f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8002fb:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800302:	cc 
  800303:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80030a:	e8 1a 16 00 00       	call   801929 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80030f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800316:	00 
  800317:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 15 10 40 80 00    	call   *0x804010
  80032d:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800330:	74 20                	je     800352 <umain+0x2b1>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800336:	c7 44 24 08 5c 2a 80 	movl   $0x802a5c,0x8(%esp)
  80033d:	00 
  80033e:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800345:	00 
  800346:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80034d:	e8 9e 04 00 00       	call   8007f0 <_panic>
	cprintf("stale fileid is good\n");
  800352:	c7 04 24 0d 29 80 00 	movl   $0x80290d,(%esp)
  800359:	e8 4b 05 00 00       	call   8008a9 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  80035e:	ba 02 01 00 00       	mov    $0x102,%edx
  800363:	b8 23 29 80 00       	mov    $0x802923,%eax
  800368:	e8 c7 fc ff ff       	call   800034 <xopen>
  80036d:	85 c0                	test   %eax,%eax
  80036f:	79 20                	jns    800391 <umain+0x2f0>
		panic("serve_open /new-file: %e", r);
  800371:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800375:	c7 44 24 08 2d 29 80 	movl   $0x80292d,0x8(%esp)
  80037c:	00 
  80037d:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800384:	00 
  800385:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80038c:	e8 5f 04 00 00       	call   8007f0 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800391:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  800397:	a1 00 40 80 00       	mov    0x804000,%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 ec 0d 00 00       	call   801190 <strlen>
  8003a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a8:	a1 00 40 80 00       	mov    0x804000,%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003b8:	ff d3                	call   *%ebx
  8003ba:	89 c3                	mov    %eax,%ebx
  8003bc:	a1 00 40 80 00       	mov    0x804000,%eax
  8003c1:	89 04 24             	mov    %eax,(%esp)
  8003c4:	e8 c7 0d 00 00       	call   801190 <strlen>
  8003c9:	39 c3                	cmp    %eax,%ebx
  8003cb:	74 20                	je     8003ed <umain+0x34c>
		panic("file_write: %e", r);
  8003cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d1:	c7 44 24 08 46 29 80 	movl   $0x802946,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8003e8:	e8 03 04 00 00       	call   8007f0 <_panic>
	cprintf("file_write is good\n");
  8003ed:	c7 04 24 55 29 80 00 	movl   $0x802955,(%esp)
  8003f4:	e8 b0 04 00 00       	call   8008a9 <cprintf>

	FVA->fd_offset = 0;
  8003f9:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800400:	00 00 00 
	memset(buf, 0, sizeof buf);
  800403:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80040a:	00 
  80040b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800412:	00 
  800413:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800419:	89 1c 24             	mov    %ebx,(%esp)
  80041c:	e8 45 0f 00 00       	call   801366 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800421:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800428:	00 
  800429:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042d:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800434:	ff 15 10 40 80 00    	call   *0x804010
  80043a:	89 c3                	mov    %eax,%ebx
  80043c:	85 c0                	test   %eax,%eax
  80043e:	79 20                	jns    800460 <umain+0x3bf>
		panic("file_read after file_write: %e", r);
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	c7 44 24 08 94 2a 80 	movl   $0x802a94,0x8(%esp)
  80044b:	00 
  80044c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800453:	00 
  800454:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80045b:	e8 90 03 00 00       	call   8007f0 <_panic>
	if (r != strlen(msg))
  800460:	a1 00 40 80 00       	mov    0x804000,%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	e8 23 0d 00 00       	call   801190 <strlen>
  80046d:	39 c3                	cmp    %eax,%ebx
  80046f:	74 20                	je     800491 <umain+0x3f0>
		panic("file_read after file_write returned wrong length: %d", r);
  800471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800475:	c7 44 24 08 b4 2a 80 	movl   $0x802ab4,0x8(%esp)
  80047c:	00 
  80047d:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800484:	00 
  800485:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80048c:	e8 5f 03 00 00       	call   8007f0 <_panic>
	if (strcmp(buf, msg) != 0)
  800491:	a1 00 40 80 00       	mov    0x804000,%eax
  800496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 ed 0d 00 00       	call   801295 <strcmp>
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	74 1c                	je     8004c8 <umain+0x427>
		panic("file_read after file_write returned wrong data");
  8004ac:	c7 44 24 08 ec 2a 80 	movl   $0x802aec,0x8(%esp)
  8004b3:	00 
  8004b4:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004bb:	00 
  8004bc:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8004c3:	e8 28 03 00 00       	call   8007f0 <_panic>
	cprintf("file_read after file_write is good\n");
  8004c8:	c7 04 24 1c 2b 80 00 	movl   $0x802b1c,(%esp)
  8004cf:	e8 d5 03 00 00       	call   8008a9 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004db:	00 
  8004dc:	c7 04 24 20 28 80 00 	movl   $0x802820,(%esp)
  8004e3:	e8 1f 20 00 00       	call   802507 <open>
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	79 25                	jns    800511 <umain+0x470>
  8004ec:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004ef:	74 3c                	je     80052d <umain+0x48c>
		panic("open /not-found: %e", r);
  8004f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f5:	c7 44 24 08 31 28 80 	movl   $0x802831,0x8(%esp)
  8004fc:	00 
  8004fd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800504:	00 
  800505:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80050c:	e8 df 02 00 00       	call   8007f0 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800511:	c7 44 24 08 69 29 80 	movl   $0x802969,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800528:	e8 c3 02 00 00       	call   8007f0 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80052d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800534:	00 
  800535:	c7 04 24 55 28 80 00 	movl   $0x802855,(%esp)
  80053c:	e8 c6 1f 00 00       	call   802507 <open>
  800541:	85 c0                	test   %eax,%eax
  800543:	79 20                	jns    800565 <umain+0x4c4>
		panic("open /newmotd: %e", r);
  800545:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800549:	c7 44 24 08 64 28 80 	movl   $0x802864,0x8(%esp)
  800550:	00 
  800551:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  800558:	00 
  800559:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800560:	e8 8b 02 00 00       	call   8007f0 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800565:	05 00 00 0d 00       	add    $0xd0000,%eax
  80056a:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80056d:	83 38 66             	cmpl   $0x66,(%eax)
  800570:	75 0c                	jne    80057e <umain+0x4dd>
  800572:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800576:	75 06                	jne    80057e <umain+0x4dd>
  800578:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80057c:	74 1c                	je     80059a <umain+0x4f9>
		panic("open did not fill struct Fd correctly\n");
  80057e:	c7 44 24 08 40 2b 80 	movl   $0x802b40,0x8(%esp)
  800585:	00 
  800586:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80058d:	00 
  80058e:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800595:	e8 56 02 00 00       	call   8007f0 <_panic>
	cprintf("open is good\n");
  80059a:	c7 04 24 7c 28 80 00 	movl   $0x80287c,(%esp)
  8005a1:	e8 03 03 00 00       	call   8008a9 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8005a6:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005ad:	00 
  8005ae:	c7 04 24 84 29 80 00 	movl   $0x802984,(%esp)
  8005b5:	e8 4d 1f 00 00       	call   802507 <open>
  8005ba:	89 85 44 fd ff ff    	mov    %eax,-0x2bc(%ebp)
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	79 20                	jns    8005e4 <umain+0x543>
		panic("creat /big: %e", f);
  8005c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c8:	c7 44 24 08 89 29 80 	movl   $0x802989,0x8(%esp)
  8005cf:	00 
  8005d0:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005d7:	00 
  8005d8:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8005df:	e8 0c 02 00 00       	call   8007f0 <_panic>
	memset(buf, 0, sizeof(buf));
  8005e4:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005eb:	00 
  8005ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005f3:	00 
  8005f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 64 0d 00 00       	call   801366 <memset>
  800602:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800607:	8d b5 4c fd ff ff    	lea    -0x2b4(%ebp),%esi
  80060d:	89 f7                	mov    %esi,%edi
  80060f:	89 1e                	mov    %ebx,(%esi)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800611:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800618:	00 
  800619:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061d:	8b 85 44 fd ff ff    	mov    -0x2bc(%ebp),%eax
  800623:	89 04 24             	mov    %eax,(%esp)
  800626:	e8 2a 19 00 00       	call   801f55 <write>
  80062b:	85 c0                	test   %eax,%eax
  80062d:	79 24                	jns    800653 <umain+0x5b2>
			panic("write /big@%d: %e", i, r);
  80062f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800633:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800637:	c7 44 24 08 98 29 80 	movl   $0x802998,0x8(%esp)
  80063e:	00 
  80063f:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800646:	00 
  800647:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80064e:	e8 9d 01 00 00       	call   8007f0 <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  800653:	81 c3 00 02 00 00    	add    $0x200,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800659:	81 fb 00 e0 01 00    	cmp    $0x1e000,%ebx
  80065f:	75 ac                	jne    80060d <umain+0x56c>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800661:	8b 85 44 fd ff ff    	mov    -0x2bc(%ebp),%eax
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	e8 cf 1a 00 00       	call   80213e <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80066f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800676:	00 
  800677:	c7 04 24 84 29 80 00 	movl   $0x802984,(%esp)
  80067e:	e8 84 1e 00 00       	call   802507 <open>
  800683:	89 c6                	mov    %eax,%esi
  800685:	85 c0                	test   %eax,%eax
  800687:	79 20                	jns    8006a9 <umain+0x608>
		panic("open /big: %e", f);
  800689:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068d:	c7 44 24 08 aa 29 80 	movl   $0x8029aa,0x8(%esp)
  800694:	00 
  800695:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  80069c:	00 
  80069d:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8006a4:	e8 47 01 00 00       	call   8007f0 <_panic>
  8006a9:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8006ae:	89 1f                	mov    %ebx,(%edi)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006b0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006b7:	00 
  8006b8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8006be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c2:	89 34 24             	mov    %esi,(%esp)
  8006c5:	e8 a2 19 00 00       	call   80206c <readn>
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	79 24                	jns    8006f2 <umain+0x651>
			panic("read /big@%d: %e", i, r);
  8006ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d6:	c7 44 24 08 b8 29 80 	movl   $0x8029b8,0x8(%esp)
  8006dd:	00 
  8006de:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006e5:	00 
  8006e6:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  8006ed:	e8 fe 00 00 00       	call   8007f0 <_panic>
		if (r != sizeof(buf))
  8006f2:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006f7:	74 2c                	je     800725 <umain+0x684>
			panic("read /big from %d returned %d < %d bytes",
  8006f9:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  800700:	00 
  800701:	89 44 24 10          	mov    %eax,0x10(%esp)
  800705:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800709:	c7 44 24 08 68 2b 80 	movl   $0x802b68,0x8(%esp)
  800710:	00 
  800711:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800718:	00 
  800719:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  800720:	e8 cb 00 00 00       	call   8007f0 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800725:	8b 07                	mov    (%edi),%eax
  800727:	39 d8                	cmp    %ebx,%eax
  800729:	74 24                	je     80074f <umain+0x6ae>
			panic("read /big from %d returned bad data %d",
  80072b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80072f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800733:	c7 44 24 08 94 2b 80 	movl   $0x802b94,0x8(%esp)
  80073a:	00 
  80073b:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800742:	00 
  800743:	c7 04 24 45 28 80 00 	movl   $0x802845,(%esp)
  80074a:	e8 a1 00 00 00       	call   8007f0 <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80074f:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  800755:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  80075b:	0f 8e 4d ff ff ff    	jle    8006ae <umain+0x60d>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800761:	89 34 24             	mov    %esi,(%esp)
  800764:	e8 d5 19 00 00       	call   80213e <close>
	cprintf("large file is good\n");
  800769:	c7 04 24 c9 29 80 00 	movl   $0x8029c9,(%esp)
  800770:	e8 34 01 00 00       	call   8008a9 <cprintf>
}
  800775:	81 c4 dc 02 00 00    	add    $0x2dc,%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 18             	sub    $0x18,%esp
  800786:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800789:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800792:	e8 5b 13 00 00       	call   801af2 <sys_getenvid>
  800797:	25 ff 03 00 00       	and    $0x3ff,%eax
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	c1 e2 07             	shl    $0x7,%edx
  8007a1:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8007a8:	a3 04 50 80 00       	mov    %eax,0x805004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007ad:	85 f6                	test   %esi,%esi
  8007af:	7e 07                	jle    8007b8 <libmain+0x38>
		binaryname = argv[0];
  8007b1:	8b 03                	mov    (%ebx),%eax
  8007b3:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  8007b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bc:	89 34 24             	mov    %esi,(%esp)
  8007bf:	e8 dd f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007c4:	e8 0b 00 00 00       	call   8007d4 <exit>
}
  8007c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8007cc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8007cf:	89 ec                	mov    %ebp,%esp
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    
	...

008007d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007da:	e8 dc 19 00 00       	call   8021bb <close_all>
	sys_env_destroy(0);
  8007df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007e6:	e8 47 13 00 00       	call   801b32 <sys_env_destroy>
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
  8007ed:	00 00                	add    %al,(%eax)
	...

008007f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8007f8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007fb:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  800801:	e8 ec 12 00 00       	call   801af2 <sys_getenvid>
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	89 54 24 10          	mov    %edx,0x10(%esp)
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
  800810:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800814:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	c7 04 24 ec 2b 80 00 	movl   $0x802bec,(%esp)
  800823:	e8 81 00 00 00       	call   8008a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800828:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082c:	8b 45 10             	mov    0x10(%ebp),%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 11 00 00 00       	call   800848 <vcprintf>
	cprintf("\n");
  800837:	c7 04 24 e8 28 80 00 	movl   $0x8028e8,(%esp)
  80083e:	e8 66 00 00 00       	call   8008a9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800843:	cc                   	int3   
  800844:	eb fd                	jmp    800843 <_panic+0x53>
	...

00800848 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800851:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800858:	00 00 00 
	b.cnt = 0;
  80085b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800862:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800865:	8b 45 0c             	mov    0xc(%ebp),%eax
  800868:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800873:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087d:	c7 04 24 c3 08 80 00 	movl   $0x8008c3,(%esp)
  800884:	e8 d3 01 00 00       	call   800a5c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800889:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800899:	89 04 24             	mov    %eax,(%esp)
  80089c:	e8 6b 0d 00 00       	call   80160c <sys_cputs>

	return b.cnt;
}
  8008a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8008af:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8008b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	89 04 24             	mov    %eax,(%esp)
  8008bc:	e8 87 ff ff ff       	call   800848 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	83 ec 14             	sub    $0x14,%esp
  8008ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8008cd:	8b 03                	mov    (%ebx),%eax
  8008cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8008db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008e0:	75 19                	jne    8008fb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8008e2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8008e9:	00 
  8008ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	e8 17 0d 00 00       	call   80160c <sys_cputs>
		b->idx = 0;
  8008f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8008fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8008ff:	83 c4 14             	add    $0x14,%esp
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    
	...

00800910 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	83 ec 4c             	sub    $0x4c,%esp
  800919:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091c:	89 d6                	mov    %edx,%esi
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
  800927:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80092a:	8b 45 10             	mov    0x10(%ebp),%eax
  80092d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800930:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800933:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800936:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093b:	39 d1                	cmp    %edx,%ecx
  80093d:	72 07                	jb     800946 <printnum_v2+0x36>
  80093f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800942:	39 d0                	cmp    %edx,%eax
  800944:	77 5f                	ja     8009a5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800946:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80094a:	83 eb 01             	sub    $0x1,%ebx
  80094d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800951:	89 44 24 08          	mov    %eax,0x8(%esp)
  800955:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800959:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80095d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800960:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800963:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800966:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80096a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800971:	00 
  800972:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800975:	89 04 24             	mov    %eax,(%esp)
  800978:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80097b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80097f:	e8 2c 1c 00 00       	call   8025b0 <__udivdi3>
  800984:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800987:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80098a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80098e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800992:	89 04 24             	mov    %eax,(%esp)
  800995:	89 54 24 04          	mov    %edx,0x4(%esp)
  800999:	89 f2                	mov    %esi,%edx
  80099b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80099e:	e8 6d ff ff ff       	call   800910 <printnum_v2>
  8009a3:	eb 1e                	jmp    8009c3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8009a5:	83 ff 2d             	cmp    $0x2d,%edi
  8009a8:	74 19                	je     8009c3 <printnum_v2+0xb3>
		while (--width > 0)
  8009aa:	83 eb 01             	sub    $0x1,%ebx
  8009ad:	85 db                	test   %ebx,%ebx
  8009af:	90                   	nop
  8009b0:	7e 11                	jle    8009c3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8009b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b6:	89 3c 24             	mov    %edi,(%esp)
  8009b9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8009bc:	83 eb 01             	sub    $0x1,%ebx
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	7f ef                	jg     8009b2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009d9:	00 
  8009da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009dd:	89 14 24             	mov    %edx,(%esp)
  8009e0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009e3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e7:	e8 f4 1c 00 00       	call   8026e0 <__umoddi3>
  8009ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f0:	0f be 80 0f 2c 80 00 	movsbl 0x802c0f(%eax),%eax
  8009f7:	89 04 24             	mov    %eax,(%esp)
  8009fa:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8009fd:	83 c4 4c             	add    $0x4c,%esp
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5f                   	pop    %edi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800a08:	83 fa 01             	cmp    $0x1,%edx
  800a0b:	7e 0e                	jle    800a1b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800a0d:	8b 10                	mov    (%eax),%edx
  800a0f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800a12:	89 08                	mov    %ecx,(%eax)
  800a14:	8b 02                	mov    (%edx),%eax
  800a16:	8b 52 04             	mov    0x4(%edx),%edx
  800a19:	eb 22                	jmp    800a3d <getuint+0x38>
	else if (lflag)
  800a1b:	85 d2                	test   %edx,%edx
  800a1d:	74 10                	je     800a2f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800a1f:	8b 10                	mov    (%eax),%edx
  800a21:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a24:	89 08                	mov    %ecx,(%eax)
  800a26:	8b 02                	mov    (%edx),%eax
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2d:	eb 0e                	jmp    800a3d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a2f:	8b 10                	mov    (%eax),%edx
  800a31:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a34:	89 08                	mov    %ecx,(%eax)
  800a36:	8b 02                	mov    (%edx),%eax
  800a38:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a45:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a49:	8b 10                	mov    (%eax),%edx
  800a4b:	3b 50 04             	cmp    0x4(%eax),%edx
  800a4e:	73 0a                	jae    800a5a <sprintputch+0x1b>
		*b->buf++ = ch;
  800a50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a53:	88 0a                	mov    %cl,(%edx)
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	89 10                	mov    %edx,(%eax)
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	83 ec 6c             	sub    $0x6c,%esp
  800a65:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800a68:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800a6f:	eb 1a                	jmp    800a8b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a71:	85 c0                	test   %eax,%eax
  800a73:	0f 84 66 06 00 00    	je     8010df <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a80:	89 04 24             	mov    %eax,(%esp)
  800a83:	ff 55 08             	call   *0x8(%ebp)
  800a86:	eb 03                	jmp    800a8b <vprintfmt+0x2f>
  800a88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a8b:	0f b6 07             	movzbl (%edi),%eax
  800a8e:	83 c7 01             	add    $0x1,%edi
  800a91:	83 f8 25             	cmp    $0x25,%eax
  800a94:	75 db                	jne    800a71 <vprintfmt+0x15>
  800a96:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  800a9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800aa6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  800aab:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800ab2:	be 00 00 00 00       	mov    $0x0,%esi
  800ab7:	eb 06                	jmp    800abf <vprintfmt+0x63>
  800ab9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800abd:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800abf:	0f b6 17             	movzbl (%edi),%edx
  800ac2:	0f b6 c2             	movzbl %dl,%eax
  800ac5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ac8:	8d 47 01             	lea    0x1(%edi),%eax
  800acb:	83 ea 23             	sub    $0x23,%edx
  800ace:	80 fa 55             	cmp    $0x55,%dl
  800ad1:	0f 87 60 05 00 00    	ja     801037 <vprintfmt+0x5db>
  800ad7:	0f b6 d2             	movzbl %dl,%edx
  800ada:	ff 24 95 00 2e 80 00 	jmp    *0x802e00(,%edx,4)
  800ae1:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ae6:	eb d5                	jmp    800abd <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ae8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800aeb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  800aee:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800af1:	8d 7a d0             	lea    -0x30(%edx),%edi
  800af4:	83 ff 09             	cmp    $0x9,%edi
  800af7:	76 08                	jbe    800b01 <vprintfmt+0xa5>
  800af9:	eb 40                	jmp    800b3b <vprintfmt+0xdf>
  800afb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  800aff:	eb bc                	jmp    800abd <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800b01:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800b04:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800b07:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  800b0b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800b0e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800b11:	83 ff 09             	cmp    $0x9,%edi
  800b14:	76 eb                	jbe    800b01 <vprintfmt+0xa5>
  800b16:	eb 23                	jmp    800b3b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b18:	8b 55 14             	mov    0x14(%ebp),%edx
  800b1b:	8d 5a 04             	lea    0x4(%edx),%ebx
  800b1e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800b21:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800b23:	eb 16                	jmp    800b3b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800b25:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b28:	c1 fa 1f             	sar    $0x1f,%edx
  800b2b:	f7 d2                	not    %edx
  800b2d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800b30:	eb 8b                	jmp    800abd <vprintfmt+0x61>
  800b32:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800b39:	eb 82                	jmp    800abd <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  800b3b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b3f:	0f 89 78 ff ff ff    	jns    800abd <vprintfmt+0x61>
  800b45:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800b48:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  800b4b:	e9 6d ff ff ff       	jmp    800abd <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b50:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800b53:	e9 65 ff ff ff       	jmp    800abd <vprintfmt+0x61>
  800b58:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5e:	8d 50 04             	lea    0x4(%eax),%edx
  800b61:	89 55 14             	mov    %edx,0x14(%ebp)
  800b64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b67:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b6b:	8b 00                	mov    (%eax),%eax
  800b6d:	89 04 24             	mov    %eax,(%esp)
  800b70:	ff 55 08             	call   *0x8(%ebp)
  800b73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800b76:	e9 10 ff ff ff       	jmp    800a8b <vprintfmt+0x2f>
  800b7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b81:	8d 50 04             	lea    0x4(%eax),%edx
  800b84:	89 55 14             	mov    %edx,0x14(%ebp)
  800b87:	8b 00                	mov    (%eax),%eax
  800b89:	89 c2                	mov    %eax,%edx
  800b8b:	c1 fa 1f             	sar    $0x1f,%edx
  800b8e:	31 d0                	xor    %edx,%eax
  800b90:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b92:	83 f8 0f             	cmp    $0xf,%eax
  800b95:	7f 0b                	jg     800ba2 <vprintfmt+0x146>
  800b97:	8b 14 85 60 2f 80 00 	mov    0x802f60(,%eax,4),%edx
  800b9e:	85 d2                	test   %edx,%edx
  800ba0:	75 26                	jne    800bc8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800ba2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba6:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  800bad:	00 
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bb8:	89 1c 24             	mov    %ebx,(%esp)
  800bbb:	e8 a7 05 00 00       	call   801167 <printfmt>
  800bc0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800bc3:	e9 c3 fe ff ff       	jmp    800a8b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800bc8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bcc:	c7 44 24 08 29 2c 80 	movl   $0x802c29,0x8(%esp)
  800bd3:	00 
  800bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	89 14 24             	mov    %edx,(%esp)
  800be1:	e8 81 05 00 00       	call   801167 <printfmt>
  800be6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800be9:	e9 9d fe ff ff       	jmp    800a8b <vprintfmt+0x2f>
  800bee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bf1:	89 c7                	mov    %eax,%edi
  800bf3:	89 d9                	mov    %ebx,%ecx
  800bf5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800bf8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800bfb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfe:	8d 50 04             	lea    0x4(%eax),%edx
  800c01:	89 55 14             	mov    %edx,0x14(%ebp)
  800c04:	8b 30                	mov    (%eax),%esi
  800c06:	85 f6                	test   %esi,%esi
  800c08:	75 05                	jne    800c0f <vprintfmt+0x1b3>
  800c0a:	be 2c 2c 80 00       	mov    $0x802c2c,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  800c0f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800c13:	7e 06                	jle    800c1b <vprintfmt+0x1bf>
  800c15:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800c19:	75 10                	jne    800c2b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c1b:	0f be 06             	movsbl (%esi),%eax
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	0f 85 a2 00 00 00    	jne    800cc8 <vprintfmt+0x26c>
  800c26:	e9 92 00 00 00       	jmp    800cbd <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c2b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c2f:	89 34 24             	mov    %esi,(%esp)
  800c32:	e8 74 05 00 00       	call   8011ab <strnlen>
  800c37:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800c3a:	29 c2                	sub    %eax,%edx
  800c3c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800c3f:	85 d2                	test   %edx,%edx
  800c41:	7e d8                	jle    800c1b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800c43:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800c47:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800c4a:	89 d3                	mov    %edx,%ebx
  800c4c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800c4f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800c52:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c55:	89 ce                	mov    %ecx,%esi
  800c57:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c5b:	89 34 24             	mov    %esi,(%esp)
  800c5e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c61:	83 eb 01             	sub    $0x1,%ebx
  800c64:	85 db                	test   %ebx,%ebx
  800c66:	7f ef                	jg     800c57 <vprintfmt+0x1fb>
  800c68:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800c6b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800c6e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800c71:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c78:	eb a1                	jmp    800c1b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c7a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800c7e:	74 1b                	je     800c9b <vprintfmt+0x23f>
  800c80:	8d 50 e0             	lea    -0x20(%eax),%edx
  800c83:	83 fa 5e             	cmp    $0x5e,%edx
  800c86:	76 13                	jbe    800c9b <vprintfmt+0x23f>
					putch('?', putdat);
  800c88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c96:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c99:	eb 0d                	jmp    800ca8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ca2:	89 04 24             	mov    %eax,(%esp)
  800ca5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ca8:	83 ef 01             	sub    $0x1,%edi
  800cab:	0f be 06             	movsbl (%esi),%eax
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	74 05                	je     800cb7 <vprintfmt+0x25b>
  800cb2:	83 c6 01             	add    $0x1,%esi
  800cb5:	eb 1a                	jmp    800cd1 <vprintfmt+0x275>
  800cb7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800cba:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800cbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800cc1:	7f 1f                	jg     800ce2 <vprintfmt+0x286>
  800cc3:	e9 c0 fd ff ff       	jmp    800a88 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cc8:	83 c6 01             	add    $0x1,%esi
  800ccb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800cce:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800cd1:	85 db                	test   %ebx,%ebx
  800cd3:	78 a5                	js     800c7a <vprintfmt+0x21e>
  800cd5:	83 eb 01             	sub    $0x1,%ebx
  800cd8:	79 a0                	jns    800c7a <vprintfmt+0x21e>
  800cda:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800cdd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800ce0:	eb db                	jmp    800cbd <vprintfmt+0x261>
  800ce2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800ceb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800cee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800cf9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800cfb:	83 eb 01             	sub    $0x1,%ebx
  800cfe:	85 db                	test   %ebx,%ebx
  800d00:	7f ec                	jg     800cee <vprintfmt+0x292>
  800d02:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d05:	e9 81 fd ff ff       	jmp    800a8b <vprintfmt+0x2f>
  800d0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d0d:	83 fe 01             	cmp    $0x1,%esi
  800d10:	7e 10                	jle    800d22 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800d12:	8b 45 14             	mov    0x14(%ebp),%eax
  800d15:	8d 50 08             	lea    0x8(%eax),%edx
  800d18:	89 55 14             	mov    %edx,0x14(%ebp)
  800d1b:	8b 18                	mov    (%eax),%ebx
  800d1d:	8b 70 04             	mov    0x4(%eax),%esi
  800d20:	eb 26                	jmp    800d48 <vprintfmt+0x2ec>
	else if (lflag)
  800d22:	85 f6                	test   %esi,%esi
  800d24:	74 12                	je     800d38 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800d26:	8b 45 14             	mov    0x14(%ebp),%eax
  800d29:	8d 50 04             	lea    0x4(%eax),%edx
  800d2c:	89 55 14             	mov    %edx,0x14(%ebp)
  800d2f:	8b 18                	mov    (%eax),%ebx
  800d31:	89 de                	mov    %ebx,%esi
  800d33:	c1 fe 1f             	sar    $0x1f,%esi
  800d36:	eb 10                	jmp    800d48 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800d38:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3b:	8d 50 04             	lea    0x4(%eax),%edx
  800d3e:	89 55 14             	mov    %edx,0x14(%ebp)
  800d41:	8b 18                	mov    (%eax),%ebx
  800d43:	89 de                	mov    %ebx,%esi
  800d45:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800d48:	83 f9 01             	cmp    $0x1,%ecx
  800d4b:	75 1e                	jne    800d6b <vprintfmt+0x30f>
                               if((long long)num > 0){
  800d4d:	85 f6                	test   %esi,%esi
  800d4f:	78 1a                	js     800d6b <vprintfmt+0x30f>
  800d51:	85 f6                	test   %esi,%esi
  800d53:	7f 05                	jg     800d5a <vprintfmt+0x2fe>
  800d55:	83 fb 00             	cmp    $0x0,%ebx
  800d58:	76 11                	jbe    800d6b <vprintfmt+0x30f>
                                   putch('+',putdat);
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d61:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800d68:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  800d6b:	85 f6                	test   %esi,%esi
  800d6d:	78 13                	js     800d82 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d6f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800d72:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800d75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7d:	e9 da 00 00 00       	jmp    800e5c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800d82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d89:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800d90:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800d93:	89 da                	mov    %ebx,%edx
  800d95:	89 f1                	mov    %esi,%ecx
  800d97:	f7 da                	neg    %edx
  800d99:	83 d1 00             	adc    $0x0,%ecx
  800d9c:	f7 d9                	neg    %ecx
  800d9e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800da1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800da4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800da7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dac:	e9 ab 00 00 00       	jmp    800e5c <vprintfmt+0x400>
  800db1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800db4:	89 f2                	mov    %esi,%edx
  800db6:	8d 45 14             	lea    0x14(%ebp),%eax
  800db9:	e8 47 fc ff ff       	call   800a05 <getuint>
  800dbe:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800dc1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800dc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800dc7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800dcc:	e9 8b 00 00 00       	jmp    800e5c <vprintfmt+0x400>
  800dd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ddb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800de2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800de5:	89 f2                	mov    %esi,%edx
  800de7:	8d 45 14             	lea    0x14(%ebp),%eax
  800dea:	e8 16 fc ff ff       	call   800a05 <getuint>
  800def:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800df2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800df5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800df8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  800dfd:	eb 5d                	jmp    800e5c <vprintfmt+0x400>
  800dff:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800e02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e09:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e10:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e17:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e1e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800e21:	8b 45 14             	mov    0x14(%ebp),%eax
  800e24:	8d 50 04             	lea    0x4(%eax),%edx
  800e27:	89 55 14             	mov    %edx,0x14(%ebp)
  800e2a:	8b 10                	mov    (%eax),%edx
  800e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e31:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800e34:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800e37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e3a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800e3f:	eb 1b                	jmp    800e5c <vprintfmt+0x400>
  800e41:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e44:	89 f2                	mov    %esi,%edx
  800e46:	8d 45 14             	lea    0x14(%ebp),%eax
  800e49:	e8 b7 fb ff ff       	call   800a05 <getuint>
  800e4e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800e51:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800e54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e57:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e5c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800e60:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e63:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800e66:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800e6a:	77 09                	ja     800e75 <vprintfmt+0x419>
  800e6c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800e6f:	0f 82 ac 00 00 00    	jb     800f21 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800e75:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800e78:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e7c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800e7f:	83 ea 01             	sub    $0x1,%edx
  800e82:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e86:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e8a:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e8e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800e92:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800e95:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800e98:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e9f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea6:	00 
  800ea7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800eaa:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800ead:	89 0c 24             	mov    %ecx,(%esp)
  800eb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eb4:	e8 f7 16 00 00       	call   8025b0 <__udivdi3>
  800eb9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800ebc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800ebf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ec7:	89 04 24             	mov    %eax,(%esp)
  800eca:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ece:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed4:	e8 37 fa ff ff       	call   800910 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ed9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800edc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ee0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ee4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ee7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eeb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ef2:	00 
  800ef3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800ef6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800ef9:	89 14 24             	mov    %edx,(%esp)
  800efc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f00:	e8 db 17 00 00       	call   8026e0 <__umoddi3>
  800f05:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f09:	0f be 80 0f 2c 80 00 	movsbl 0x802c0f(%eax),%eax
  800f10:	89 04 24             	mov    %eax,(%esp)
  800f13:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800f16:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800f1a:	74 54                	je     800f70 <vprintfmt+0x514>
  800f1c:	e9 67 fb ff ff       	jmp    800a88 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800f21:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	0f 84 2a 01 00 00    	je     801058 <vprintfmt+0x5fc>
		while (--width > 0)
  800f2e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800f31:	83 ef 01             	sub    $0x1,%edi
  800f34:	85 ff                	test   %edi,%edi
  800f36:	0f 8e 5e 01 00 00    	jle    80109a <vprintfmt+0x63e>
  800f3c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800f3f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800f42:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800f45:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800f48:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800f4b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800f4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f52:	89 1c 24             	mov    %ebx,(%esp)
  800f55:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800f58:	83 ef 01             	sub    $0x1,%edi
  800f5b:	85 ff                	test   %edi,%edi
  800f5d:	7f ef                	jg     800f4e <vprintfmt+0x4f2>
  800f5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f62:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f65:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800f68:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800f6b:	e9 2a 01 00 00       	jmp    80109a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800f70:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800f73:	83 eb 01             	sub    $0x1,%ebx
  800f76:	85 db                	test   %ebx,%ebx
  800f78:	0f 8e 0a fb ff ff    	jle    800a88 <vprintfmt+0x2c>
  800f7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f81:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800f84:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800f87:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800f92:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800f94:	83 eb 01             	sub    $0x1,%ebx
  800f97:	85 db                	test   %ebx,%ebx
  800f99:	7f ec                	jg     800f87 <vprintfmt+0x52b>
  800f9b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800f9e:	e9 e8 fa ff ff       	jmp    800a8b <vprintfmt+0x2f>
  800fa3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800fa6:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa9:	8d 50 04             	lea    0x4(%eax),%edx
  800fac:	89 55 14             	mov    %edx,0x14(%ebp)
  800faf:	8b 00                	mov    (%eax),%eax
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	75 2a                	jne    800fdf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800fb5:	c7 44 24 0c 48 2d 80 	movl   $0x802d48,0xc(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 08 29 2c 80 	movl   $0x802c29,0x8(%esp)
  800fc4:	00 
  800fc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fcf:	89 0c 24             	mov    %ecx,(%esp)
  800fd2:	e8 90 01 00 00       	call   801167 <printfmt>
  800fd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fda:	e9 ac fa ff ff       	jmp    800a8b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800fdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fe2:	8b 13                	mov    (%ebx),%edx
  800fe4:	83 fa 7f             	cmp    $0x7f,%edx
  800fe7:	7e 29                	jle    801012 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800fe9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800feb:	c7 44 24 0c 80 2d 80 	movl   $0x802d80,0xc(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 08 29 2c 80 	movl   $0x802c29,0x8(%esp)
  800ffa:	00 
  800ffb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fff:	8b 45 08             	mov    0x8(%ebp),%eax
  801002:	89 04 24             	mov    %eax,(%esp)
  801005:	e8 5d 01 00 00       	call   801167 <printfmt>
  80100a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80100d:	e9 79 fa ff ff       	jmp    800a8b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801012:	88 10                	mov    %dl,(%eax)
  801014:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801017:	e9 6f fa ff ff       	jmp    800a8b <vprintfmt+0x2f>
  80101c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80101f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801022:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801025:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801029:	89 14 24             	mov    %edx,(%esp)
  80102c:	ff 55 08             	call   *0x8(%ebp)
  80102f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801032:	e9 54 fa ff ff       	jmp    800a8b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801037:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80103a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80103e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801045:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801048:	8d 47 ff             	lea    -0x1(%edi),%eax
  80104b:	80 38 25             	cmpb   $0x25,(%eax)
  80104e:	0f 84 37 fa ff ff    	je     800a8b <vprintfmt+0x2f>
  801054:	89 c7                	mov    %eax,%edi
  801056:	eb f0                	jmp    801048 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801058:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80105f:	8b 74 24 04          	mov    0x4(%esp),%esi
  801063:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801066:	89 54 24 08          	mov    %edx,0x8(%esp)
  80106a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801071:	00 
  801072:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801075:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801078:	89 04 24             	mov    %eax,(%esp)
  80107b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80107f:	e8 5c 16 00 00       	call   8026e0 <__umoddi3>
  801084:	89 74 24 04          	mov    %esi,0x4(%esp)
  801088:	0f be 80 0f 2c 80 00 	movsbl 0x802c0f(%eax),%eax
  80108f:	89 04 24             	mov    %eax,(%esp)
  801092:	ff 55 08             	call   *0x8(%ebp)
  801095:	e9 d6 fe ff ff       	jmp    800f70 <vprintfmt+0x514>
  80109a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80109d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010a1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010a5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8010a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010b3:	00 
  8010b4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8010b7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8010ba:	89 04 24             	mov    %eax,(%esp)
  8010bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010c1:	e8 1a 16 00 00       	call   8026e0 <__umoddi3>
  8010c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ca:	0f be 80 0f 2c 80 00 	movsbl 0x802c0f(%eax),%eax
  8010d1:	89 04 24             	mov    %eax,(%esp)
  8010d4:	ff 55 08             	call   *0x8(%ebp)
  8010d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010da:	e9 ac f9 ff ff       	jmp    800a8b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8010df:	83 c4 6c             	add    $0x6c,%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5f                   	pop    %edi
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	83 ec 28             	sub    $0x28,%esp
  8010ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 04                	je     8010fb <vsnprintf+0x14>
  8010f7:	85 d2                	test   %edx,%edx
  8010f9:	7f 07                	jg     801102 <vsnprintf+0x1b>
  8010fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801100:	eb 3b                	jmp    80113d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801102:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801105:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801109:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80110c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801113:	8b 45 14             	mov    0x14(%ebp),%eax
  801116:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111a:	8b 45 10             	mov    0x10(%ebp),%eax
  80111d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801121:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801124:	89 44 24 04          	mov    %eax,0x4(%esp)
  801128:	c7 04 24 3f 0a 80 00 	movl   $0x800a3f,(%esp)
  80112f:	e8 28 f9 ff ff       	call   800a5c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801134:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801137:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801145:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801148:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114c:	8b 45 10             	mov    0x10(%ebp),%eax
  80114f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801153:	8b 45 0c             	mov    0xc(%ebp),%eax
  801156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115a:	8b 45 08             	mov    0x8(%ebp),%eax
  80115d:	89 04 24             	mov    %eax,(%esp)
  801160:	e8 82 ff ff ff       	call   8010e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80116d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801170:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801174:	8b 45 10             	mov    0x10(%ebp),%eax
  801177:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 cf f8 ff ff       	call   800a5c <vprintfmt>
	va_end(ap);
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    
	...

00801190 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801196:	b8 00 00 00 00       	mov    $0x0,%eax
  80119b:	80 3a 00             	cmpb   $0x0,(%edx)
  80119e:	74 09                	je     8011a9 <strlen+0x19>
		n++;
  8011a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011a7:	75 f7                	jne    8011a0 <strlen+0x10>
		n++;
	return n;
}
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	53                   	push   %ebx
  8011af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011b5:	85 c9                	test   %ecx,%ecx
  8011b7:	74 19                	je     8011d2 <strnlen+0x27>
  8011b9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8011bc:	74 14                	je     8011d2 <strnlen+0x27>
  8011be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8011c3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011c6:	39 c8                	cmp    %ecx,%eax
  8011c8:	74 0d                	je     8011d7 <strnlen+0x2c>
  8011ca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8011ce:	75 f3                	jne    8011c3 <strnlen+0x18>
  8011d0:	eb 05                	jmp    8011d7 <strnlen+0x2c>
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8011d7:	5b                   	pop    %ebx
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	53                   	push   %ebx
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011e9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8011ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011f0:	83 c2 01             	add    $0x1,%edx
  8011f3:	84 c9                	test   %cl,%cl
  8011f5:	75 f2                	jne    8011e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011f7:	5b                   	pop    %ebx
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801204:	89 1c 24             	mov    %ebx,(%esp)
  801207:	e8 84 ff ff ff       	call   801190 <strlen>
	strcpy(dst + len, src);
  80120c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801213:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801216:	89 04 24             	mov    %eax,(%esp)
  801219:	e8 bc ff ff ff       	call   8011da <strcpy>
	return dst;
}
  80121e:	89 d8                	mov    %ebx,%eax
  801220:	83 c4 08             	add    $0x8,%esp
  801223:	5b                   	pop    %ebx
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	56                   	push   %esi
  80122a:	53                   	push   %ebx
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801231:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801234:	85 f6                	test   %esi,%esi
  801236:	74 18                	je     801250 <strncpy+0x2a>
  801238:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80123d:	0f b6 1a             	movzbl (%edx),%ebx
  801240:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801243:	80 3a 01             	cmpb   $0x1,(%edx)
  801246:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801249:	83 c1 01             	add    $0x1,%ecx
  80124c:	39 ce                	cmp    %ecx,%esi
  80124e:	77 ed                	ja     80123d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	8b 75 08             	mov    0x8(%ebp),%esi
  80125c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801262:	89 f0                	mov    %esi,%eax
  801264:	85 c9                	test   %ecx,%ecx
  801266:	74 27                	je     80128f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801268:	83 e9 01             	sub    $0x1,%ecx
  80126b:	74 1d                	je     80128a <strlcpy+0x36>
  80126d:	0f b6 1a             	movzbl (%edx),%ebx
  801270:	84 db                	test   %bl,%bl
  801272:	74 16                	je     80128a <strlcpy+0x36>
			*dst++ = *src++;
  801274:	88 18                	mov    %bl,(%eax)
  801276:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801279:	83 e9 01             	sub    $0x1,%ecx
  80127c:	74 0e                	je     80128c <strlcpy+0x38>
			*dst++ = *src++;
  80127e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801281:	0f b6 1a             	movzbl (%edx),%ebx
  801284:	84 db                	test   %bl,%bl
  801286:	75 ec                	jne    801274 <strlcpy+0x20>
  801288:	eb 02                	jmp    80128c <strlcpy+0x38>
  80128a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80128c:	c6 00 00             	movb   $0x0,(%eax)
  80128f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801291:	5b                   	pop    %ebx
  801292:	5e                   	pop    %esi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80129e:	0f b6 01             	movzbl (%ecx),%eax
  8012a1:	84 c0                	test   %al,%al
  8012a3:	74 15                	je     8012ba <strcmp+0x25>
  8012a5:	3a 02                	cmp    (%edx),%al
  8012a7:	75 11                	jne    8012ba <strcmp+0x25>
		p++, q++;
  8012a9:	83 c1 01             	add    $0x1,%ecx
  8012ac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012af:	0f b6 01             	movzbl (%ecx),%eax
  8012b2:	84 c0                	test   %al,%al
  8012b4:	74 04                	je     8012ba <strcmp+0x25>
  8012b6:	3a 02                	cmp    (%edx),%al
  8012b8:	74 ef                	je     8012a9 <strcmp+0x14>
  8012ba:	0f b6 c0             	movzbl %al,%eax
  8012bd:	0f b6 12             	movzbl (%edx),%edx
  8012c0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	74 23                	je     8012f8 <strncmp+0x34>
  8012d5:	0f b6 1a             	movzbl (%edx),%ebx
  8012d8:	84 db                	test   %bl,%bl
  8012da:	74 25                	je     801301 <strncmp+0x3d>
  8012dc:	3a 19                	cmp    (%ecx),%bl
  8012de:	75 21                	jne    801301 <strncmp+0x3d>
  8012e0:	83 e8 01             	sub    $0x1,%eax
  8012e3:	74 13                	je     8012f8 <strncmp+0x34>
		n--, p++, q++;
  8012e5:	83 c2 01             	add    $0x1,%edx
  8012e8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012eb:	0f b6 1a             	movzbl (%edx),%ebx
  8012ee:	84 db                	test   %bl,%bl
  8012f0:	74 0f                	je     801301 <strncmp+0x3d>
  8012f2:	3a 19                	cmp    (%ecx),%bl
  8012f4:	74 ea                	je     8012e0 <strncmp+0x1c>
  8012f6:	eb 09                	jmp    801301 <strncmp+0x3d>
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012fd:	5b                   	pop    %ebx
  8012fe:	5d                   	pop    %ebp
  8012ff:	90                   	nop
  801300:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801301:	0f b6 02             	movzbl (%edx),%eax
  801304:	0f b6 11             	movzbl (%ecx),%edx
  801307:	29 d0                	sub    %edx,%eax
  801309:	eb f2                	jmp    8012fd <strncmp+0x39>

0080130b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	8b 45 08             	mov    0x8(%ebp),%eax
  801311:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801315:	0f b6 10             	movzbl (%eax),%edx
  801318:	84 d2                	test   %dl,%dl
  80131a:	74 18                	je     801334 <strchr+0x29>
		if (*s == c)
  80131c:	38 ca                	cmp    %cl,%dl
  80131e:	75 0a                	jne    80132a <strchr+0x1f>
  801320:	eb 17                	jmp    801339 <strchr+0x2e>
  801322:	38 ca                	cmp    %cl,%dl
  801324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801328:	74 0f                	je     801339 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80132a:	83 c0 01             	add    $0x1,%eax
  80132d:	0f b6 10             	movzbl (%eax),%edx
  801330:	84 d2                	test   %dl,%dl
  801332:	75 ee                	jne    801322 <strchr+0x17>
  801334:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    

0080133b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	8b 45 08             	mov    0x8(%ebp),%eax
  801341:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801345:	0f b6 10             	movzbl (%eax),%edx
  801348:	84 d2                	test   %dl,%dl
  80134a:	74 18                	je     801364 <strfind+0x29>
		if (*s == c)
  80134c:	38 ca                	cmp    %cl,%dl
  80134e:	75 0a                	jne    80135a <strfind+0x1f>
  801350:	eb 12                	jmp    801364 <strfind+0x29>
  801352:	38 ca                	cmp    %cl,%dl
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	74 0a                	je     801364 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80135a:	83 c0 01             	add    $0x1,%eax
  80135d:	0f b6 10             	movzbl (%eax),%edx
  801360:	84 d2                	test   %dl,%dl
  801362:	75 ee                	jne    801352 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	89 1c 24             	mov    %ebx,(%esp)
  80136f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801373:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801377:	8b 7d 08             	mov    0x8(%ebp),%edi
  80137a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801380:	85 c9                	test   %ecx,%ecx
  801382:	74 30                	je     8013b4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801384:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80138a:	75 25                	jne    8013b1 <memset+0x4b>
  80138c:	f6 c1 03             	test   $0x3,%cl
  80138f:	75 20                	jne    8013b1 <memset+0x4b>
		c &= 0xFF;
  801391:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801394:	89 d3                	mov    %edx,%ebx
  801396:	c1 e3 08             	shl    $0x8,%ebx
  801399:	89 d6                	mov    %edx,%esi
  80139b:	c1 e6 18             	shl    $0x18,%esi
  80139e:	89 d0                	mov    %edx,%eax
  8013a0:	c1 e0 10             	shl    $0x10,%eax
  8013a3:	09 f0                	or     %esi,%eax
  8013a5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8013a7:	09 d8                	or     %ebx,%eax
  8013a9:	c1 e9 02             	shr    $0x2,%ecx
  8013ac:	fc                   	cld    
  8013ad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8013af:	eb 03                	jmp    8013b4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8013b1:	fc                   	cld    
  8013b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013b4:	89 f8                	mov    %edi,%eax
  8013b6:	8b 1c 24             	mov    (%esp),%ebx
  8013b9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013bd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013c1:	89 ec                	mov    %ebp,%esp
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	89 34 24             	mov    %esi,(%esp)
  8013ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8013d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8013db:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8013dd:	39 c6                	cmp    %eax,%esi
  8013df:	73 35                	jae    801416 <memmove+0x51>
  8013e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013e4:	39 d0                	cmp    %edx,%eax
  8013e6:	73 2e                	jae    801416 <memmove+0x51>
		s += n;
		d += n;
  8013e8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013ea:	f6 c2 03             	test   $0x3,%dl
  8013ed:	75 1b                	jne    80140a <memmove+0x45>
  8013ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8013f5:	75 13                	jne    80140a <memmove+0x45>
  8013f7:	f6 c1 03             	test   $0x3,%cl
  8013fa:	75 0e                	jne    80140a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8013fc:	83 ef 04             	sub    $0x4,%edi
  8013ff:	8d 72 fc             	lea    -0x4(%edx),%esi
  801402:	c1 e9 02             	shr    $0x2,%ecx
  801405:	fd                   	std    
  801406:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801408:	eb 09                	jmp    801413 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80140a:	83 ef 01             	sub    $0x1,%edi
  80140d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801410:	fd                   	std    
  801411:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801413:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801414:	eb 20                	jmp    801436 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801416:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80141c:	75 15                	jne    801433 <memmove+0x6e>
  80141e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801424:	75 0d                	jne    801433 <memmove+0x6e>
  801426:	f6 c1 03             	test   $0x3,%cl
  801429:	75 08                	jne    801433 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80142b:	c1 e9 02             	shr    $0x2,%ecx
  80142e:	fc                   	cld    
  80142f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801431:	eb 03                	jmp    801436 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801433:	fc                   	cld    
  801434:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801436:	8b 34 24             	mov    (%esp),%esi
  801439:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80143d:	89 ec                	mov    %ebp,%esp
  80143f:	5d                   	pop    %ebp
  801440:	c3                   	ret    

00801441 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801447:	8b 45 10             	mov    0x10(%ebp),%eax
  80144a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801451:	89 44 24 04          	mov    %eax,0x4(%esp)
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	89 04 24             	mov    %eax,(%esp)
  80145b:	e8 65 ff ff ff       	call   8013c5 <memmove>
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	57                   	push   %edi
  801466:	56                   	push   %esi
  801467:	53                   	push   %ebx
  801468:	8b 75 08             	mov    0x8(%ebp),%esi
  80146b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80146e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801471:	85 c9                	test   %ecx,%ecx
  801473:	74 36                	je     8014ab <memcmp+0x49>
		if (*s1 != *s2)
  801475:	0f b6 06             	movzbl (%esi),%eax
  801478:	0f b6 1f             	movzbl (%edi),%ebx
  80147b:	38 d8                	cmp    %bl,%al
  80147d:	74 20                	je     80149f <memcmp+0x3d>
  80147f:	eb 14                	jmp    801495 <memcmp+0x33>
  801481:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801486:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80148b:	83 c2 01             	add    $0x1,%edx
  80148e:	83 e9 01             	sub    $0x1,%ecx
  801491:	38 d8                	cmp    %bl,%al
  801493:	74 12                	je     8014a7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801495:	0f b6 c0             	movzbl %al,%eax
  801498:	0f b6 db             	movzbl %bl,%ebx
  80149b:	29 d8                	sub    %ebx,%eax
  80149d:	eb 11                	jmp    8014b0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80149f:	83 e9 01             	sub    $0x1,%ecx
  8014a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a7:	85 c9                	test   %ecx,%ecx
  8014a9:	75 d6                	jne    801481 <memcmp+0x1f>
  8014ab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8014c0:	39 d0                	cmp    %edx,%eax
  8014c2:	73 15                	jae    8014d9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8014c8:	38 08                	cmp    %cl,(%eax)
  8014ca:	75 06                	jne    8014d2 <memfind+0x1d>
  8014cc:	eb 0b                	jmp    8014d9 <memfind+0x24>
  8014ce:	38 08                	cmp    %cl,(%eax)
  8014d0:	74 07                	je     8014d9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8014d2:	83 c0 01             	add    $0x1,%eax
  8014d5:	39 c2                	cmp    %eax,%edx
  8014d7:	77 f5                	ja     8014ce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	57                   	push   %edi
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 04             	sub    $0x4,%esp
  8014e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014ea:	0f b6 02             	movzbl (%edx),%eax
  8014ed:	3c 20                	cmp    $0x20,%al
  8014ef:	74 04                	je     8014f5 <strtol+0x1a>
  8014f1:	3c 09                	cmp    $0x9,%al
  8014f3:	75 0e                	jne    801503 <strtol+0x28>
		s++;
  8014f5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014f8:	0f b6 02             	movzbl (%edx),%eax
  8014fb:	3c 20                	cmp    $0x20,%al
  8014fd:	74 f6                	je     8014f5 <strtol+0x1a>
  8014ff:	3c 09                	cmp    $0x9,%al
  801501:	74 f2                	je     8014f5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801503:	3c 2b                	cmp    $0x2b,%al
  801505:	75 0c                	jne    801513 <strtol+0x38>
		s++;
  801507:	83 c2 01             	add    $0x1,%edx
  80150a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801511:	eb 15                	jmp    801528 <strtol+0x4d>
	else if (*s == '-')
  801513:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80151a:	3c 2d                	cmp    $0x2d,%al
  80151c:	75 0a                	jne    801528 <strtol+0x4d>
		s++, neg = 1;
  80151e:	83 c2 01             	add    $0x1,%edx
  801521:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801528:	85 db                	test   %ebx,%ebx
  80152a:	0f 94 c0             	sete   %al
  80152d:	74 05                	je     801534 <strtol+0x59>
  80152f:	83 fb 10             	cmp    $0x10,%ebx
  801532:	75 18                	jne    80154c <strtol+0x71>
  801534:	80 3a 30             	cmpb   $0x30,(%edx)
  801537:	75 13                	jne    80154c <strtol+0x71>
  801539:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80153d:	8d 76 00             	lea    0x0(%esi),%esi
  801540:	75 0a                	jne    80154c <strtol+0x71>
		s += 2, base = 16;
  801542:	83 c2 02             	add    $0x2,%edx
  801545:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80154a:	eb 15                	jmp    801561 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80154c:	84 c0                	test   %al,%al
  80154e:	66 90                	xchg   %ax,%ax
  801550:	74 0f                	je     801561 <strtol+0x86>
  801552:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801557:	80 3a 30             	cmpb   $0x30,(%edx)
  80155a:	75 05                	jne    801561 <strtol+0x86>
		s++, base = 8;
  80155c:	83 c2 01             	add    $0x1,%edx
  80155f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801561:	b8 00 00 00 00       	mov    $0x0,%eax
  801566:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801568:	0f b6 0a             	movzbl (%edx),%ecx
  80156b:	89 cf                	mov    %ecx,%edi
  80156d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801570:	80 fb 09             	cmp    $0x9,%bl
  801573:	77 08                	ja     80157d <strtol+0xa2>
			dig = *s - '0';
  801575:	0f be c9             	movsbl %cl,%ecx
  801578:	83 e9 30             	sub    $0x30,%ecx
  80157b:	eb 1e                	jmp    80159b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80157d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801580:	80 fb 19             	cmp    $0x19,%bl
  801583:	77 08                	ja     80158d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801585:	0f be c9             	movsbl %cl,%ecx
  801588:	83 e9 57             	sub    $0x57,%ecx
  80158b:	eb 0e                	jmp    80159b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80158d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801590:	80 fb 19             	cmp    $0x19,%bl
  801593:	77 15                	ja     8015aa <strtol+0xcf>
			dig = *s - 'A' + 10;
  801595:	0f be c9             	movsbl %cl,%ecx
  801598:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80159b:	39 f1                	cmp    %esi,%ecx
  80159d:	7d 0b                	jge    8015aa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80159f:	83 c2 01             	add    $0x1,%edx
  8015a2:	0f af c6             	imul   %esi,%eax
  8015a5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8015a8:	eb be                	jmp    801568 <strtol+0x8d>
  8015aa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8015ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8015b0:	74 05                	je     8015b7 <strtol+0xdc>
		*endptr = (char *) s;
  8015b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8015b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015bb:	74 04                	je     8015c1 <strtol+0xe6>
  8015bd:	89 c8                	mov    %ecx,%eax
  8015bf:	f7 d8                	neg    %eax
}
  8015c1:	83 c4 04             	add    $0x4,%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    
  8015c9:	00 00                	add    %al,(%eax)
	...

008015cc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	89 1c 24             	mov    %ebx,(%esp)
  8015d5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015de:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e3:	89 d1                	mov    %edx,%ecx
  8015e5:	89 d3                	mov    %edx,%ebx
  8015e7:	89 d7                	mov    %edx,%edi
  8015e9:	51                   	push   %ecx
  8015ea:	52                   	push   %edx
  8015eb:	53                   	push   %ebx
  8015ec:	54                   	push   %esp
  8015ed:	55                   	push   %ebp
  8015ee:	56                   	push   %esi
  8015ef:	57                   	push   %edi
  8015f0:	54                   	push   %esp
  8015f1:	5d                   	pop    %ebp
  8015f2:	8d 35 fa 15 80 00    	lea    0x8015fa,%esi
  8015f8:	0f 34                	sysenter 
  8015fa:	5f                   	pop    %edi
  8015fb:	5e                   	pop    %esi
  8015fc:	5d                   	pop    %ebp
  8015fd:	5c                   	pop    %esp
  8015fe:	5b                   	pop    %ebx
  8015ff:	5a                   	pop    %edx
  801600:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801601:	8b 1c 24             	mov    (%esp),%ebx
  801604:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801608:	89 ec                	mov    %ebp,%esp
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	89 1c 24             	mov    %ebx,(%esp)
  801615:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801619:	b8 00 00 00 00       	mov    $0x0,%eax
  80161e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801621:	8b 55 08             	mov    0x8(%ebp),%edx
  801624:	89 c3                	mov    %eax,%ebx
  801626:	89 c7                	mov    %eax,%edi
  801628:	51                   	push   %ecx
  801629:	52                   	push   %edx
  80162a:	53                   	push   %ebx
  80162b:	54                   	push   %esp
  80162c:	55                   	push   %ebp
  80162d:	56                   	push   %esi
  80162e:	57                   	push   %edi
  80162f:	54                   	push   %esp
  801630:	5d                   	pop    %ebp
  801631:	8d 35 39 16 80 00    	lea    0x801639,%esi
  801637:	0f 34                	sysenter 
  801639:	5f                   	pop    %edi
  80163a:	5e                   	pop    %esi
  80163b:	5d                   	pop    %ebp
  80163c:	5c                   	pop    %esp
  80163d:	5b                   	pop    %ebx
  80163e:	5a                   	pop    %edx
  80163f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801640:	8b 1c 24             	mov    (%esp),%ebx
  801643:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801647:	89 ec                	mov    %ebp,%esp
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	89 1c 24             	mov    %ebx,(%esp)
  801654:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801658:	b8 10 00 00 00       	mov    $0x10,%eax
  80165d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801660:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801663:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801666:	8b 55 08             	mov    0x8(%ebp),%edx
  801669:	51                   	push   %ecx
  80166a:	52                   	push   %edx
  80166b:	53                   	push   %ebx
  80166c:	54                   	push   %esp
  80166d:	55                   	push   %ebp
  80166e:	56                   	push   %esi
  80166f:	57                   	push   %edi
  801670:	54                   	push   %esp
  801671:	5d                   	pop    %ebp
  801672:	8d 35 7a 16 80 00    	lea    0x80167a,%esi
  801678:	0f 34                	sysenter 
  80167a:	5f                   	pop    %edi
  80167b:	5e                   	pop    %esi
  80167c:	5d                   	pop    %ebp
  80167d:	5c                   	pop    %esp
  80167e:	5b                   	pop    %ebx
  80167f:	5a                   	pop    %edx
  801680:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801681:	8b 1c 24             	mov    (%esp),%ebx
  801684:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801688:	89 ec                	mov    %ebp,%esp
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 28             	sub    $0x28,%esp
  801692:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801695:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169d:	b8 0f 00 00 00       	mov    $0xf,%eax
  8016a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a8:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	7e 28                	jle    8016ee <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ca:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8016d1:	00 
  8016d2:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  8016d9:	00 
  8016da:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8016e1:	00 
  8016e2:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  8016e9:	e8 02 f1 ff ff       	call   8007f0 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8016ee:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016f4:	89 ec                	mov    %ebp,%esp
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	89 1c 24             	mov    %ebx,(%esp)
  801701:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80170a:	b8 11 00 00 00       	mov    $0x11,%eax
  80170f:	8b 55 08             	mov    0x8(%ebp),%edx
  801712:	89 cb                	mov    %ecx,%ebx
  801714:	89 cf                	mov    %ecx,%edi
  801716:	51                   	push   %ecx
  801717:	52                   	push   %edx
  801718:	53                   	push   %ebx
  801719:	54                   	push   %esp
  80171a:	55                   	push   %ebp
  80171b:	56                   	push   %esi
  80171c:	57                   	push   %edi
  80171d:	54                   	push   %esp
  80171e:	5d                   	pop    %ebp
  80171f:	8d 35 27 17 80 00    	lea    0x801727,%esi
  801725:	0f 34                	sysenter 
  801727:	5f                   	pop    %edi
  801728:	5e                   	pop    %esi
  801729:	5d                   	pop    %ebp
  80172a:	5c                   	pop    %esp
  80172b:	5b                   	pop    %ebx
  80172c:	5a                   	pop    %edx
  80172d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80172e:	8b 1c 24             	mov    (%esp),%ebx
  801731:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801735:	89 ec                	mov    %ebp,%esp
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	83 ec 28             	sub    $0x28,%esp
  80173f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801742:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801745:	b9 00 00 00 00       	mov    $0x0,%ecx
  80174a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80174f:	8b 55 08             	mov    0x8(%ebp),%edx
  801752:	89 cb                	mov    %ecx,%ebx
  801754:	89 cf                	mov    %ecx,%edi
  801756:	51                   	push   %ecx
  801757:	52                   	push   %edx
  801758:	53                   	push   %ebx
  801759:	54                   	push   %esp
  80175a:	55                   	push   %ebp
  80175b:	56                   	push   %esi
  80175c:	57                   	push   %edi
  80175d:	54                   	push   %esp
  80175e:	5d                   	pop    %ebp
  80175f:	8d 35 67 17 80 00    	lea    0x801767,%esi
  801765:	0f 34                	sysenter 
  801767:	5f                   	pop    %edi
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	5c                   	pop    %esp
  80176b:	5b                   	pop    %ebx
  80176c:	5a                   	pop    %edx
  80176d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80176e:	85 c0                	test   %eax,%eax
  801770:	7e 28                	jle    80179a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801772:	89 44 24 10          	mov    %eax,0x10(%esp)
  801776:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80177d:	00 
  80177e:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  801785:	00 
  801786:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80178d:	00 
  80178e:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  801795:	e8 56 f0 ff ff       	call   8007f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80179a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80179d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017a0:	89 ec                	mov    %ebp,%esp
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	89 1c 24             	mov    %ebx,(%esp)
  8017ad:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8017b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c2:	51                   	push   %ecx
  8017c3:	52                   	push   %edx
  8017c4:	53                   	push   %ebx
  8017c5:	54                   	push   %esp
  8017c6:	55                   	push   %ebp
  8017c7:	56                   	push   %esi
  8017c8:	57                   	push   %edi
  8017c9:	54                   	push   %esp
  8017ca:	5d                   	pop    %ebp
  8017cb:	8d 35 d3 17 80 00    	lea    0x8017d3,%esi
  8017d1:	0f 34                	sysenter 
  8017d3:	5f                   	pop    %edi
  8017d4:	5e                   	pop    %esi
  8017d5:	5d                   	pop    %ebp
  8017d6:	5c                   	pop    %esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5a                   	pop    %edx
  8017d9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017da:	8b 1c 24             	mov    (%esp),%ebx
  8017dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017e1:	89 ec                	mov    %ebp,%esp
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	83 ec 28             	sub    $0x28,%esp
  8017eb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017ee:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8017f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8017fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801801:	89 df                	mov    %ebx,%edi
  801803:	51                   	push   %ecx
  801804:	52                   	push   %edx
  801805:	53                   	push   %ebx
  801806:	54                   	push   %esp
  801807:	55                   	push   %ebp
  801808:	56                   	push   %esi
  801809:	57                   	push   %edi
  80180a:	54                   	push   %esp
  80180b:	5d                   	pop    %ebp
  80180c:	8d 35 14 18 80 00    	lea    0x801814,%esi
  801812:	0f 34                	sysenter 
  801814:	5f                   	pop    %edi
  801815:	5e                   	pop    %esi
  801816:	5d                   	pop    %ebp
  801817:	5c                   	pop    %esp
  801818:	5b                   	pop    %ebx
  801819:	5a                   	pop    %edx
  80181a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80181b:	85 c0                	test   %eax,%eax
  80181d:	7e 28                	jle    801847 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80181f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801823:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80182a:	00 
  80182b:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  801832:	00 
  801833:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80183a:	00 
  80183b:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  801842:	e8 a9 ef ff ff       	call   8007f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801847:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80184a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80184d:	89 ec                	mov    %ebp,%esp
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    

00801851 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 28             	sub    $0x28,%esp
  801857:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80185a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80185d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801862:	b8 0a 00 00 00       	mov    $0xa,%eax
  801867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186a:	8b 55 08             	mov    0x8(%ebp),%edx
  80186d:	89 df                	mov    %ebx,%edi
  80186f:	51                   	push   %ecx
  801870:	52                   	push   %edx
  801871:	53                   	push   %ebx
  801872:	54                   	push   %esp
  801873:	55                   	push   %ebp
  801874:	56                   	push   %esi
  801875:	57                   	push   %edi
  801876:	54                   	push   %esp
  801877:	5d                   	pop    %ebp
  801878:	8d 35 80 18 80 00    	lea    0x801880,%esi
  80187e:	0f 34                	sysenter 
  801880:	5f                   	pop    %edi
  801881:	5e                   	pop    %esi
  801882:	5d                   	pop    %ebp
  801883:	5c                   	pop    %esp
  801884:	5b                   	pop    %ebx
  801885:	5a                   	pop    %edx
  801886:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801887:	85 c0                	test   %eax,%eax
  801889:	7e 28                	jle    8018b3 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80188b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80188f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801896:	00 
  801897:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  80189e:	00 
  80189f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8018a6:	00 
  8018a7:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  8018ae:	e8 3d ef ff ff       	call   8007f0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8018b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018b9:	89 ec                	mov    %ebp,%esp
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 28             	sub    $0x28,%esp
  8018c3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018c6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8018c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ce:	b8 09 00 00 00       	mov    $0x9,%eax
  8018d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d9:	89 df                	mov    %ebx,%edi
  8018db:	51                   	push   %ecx
  8018dc:	52                   	push   %edx
  8018dd:	53                   	push   %ebx
  8018de:	54                   	push   %esp
  8018df:	55                   	push   %ebp
  8018e0:	56                   	push   %esi
  8018e1:	57                   	push   %edi
  8018e2:	54                   	push   %esp
  8018e3:	5d                   	pop    %ebp
  8018e4:	8d 35 ec 18 80 00    	lea    0x8018ec,%esi
  8018ea:	0f 34                	sysenter 
  8018ec:	5f                   	pop    %edi
  8018ed:	5e                   	pop    %esi
  8018ee:	5d                   	pop    %ebp
  8018ef:	5c                   	pop    %esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5a                   	pop    %edx
  8018f2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	7e 28                	jle    80191f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018fb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801902:	00 
  801903:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  80190a:	00 
  80190b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801912:	00 
  801913:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  80191a:	e8 d1 ee ff ff       	call   8007f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80191f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801922:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801925:	89 ec                	mov    %ebp,%esp
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	83 ec 28             	sub    $0x28,%esp
  80192f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801932:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801935:	bb 00 00 00 00       	mov    $0x0,%ebx
  80193a:	b8 07 00 00 00       	mov    $0x7,%eax
  80193f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801942:	8b 55 08             	mov    0x8(%ebp),%edx
  801945:	89 df                	mov    %ebx,%edi
  801947:	51                   	push   %ecx
  801948:	52                   	push   %edx
  801949:	53                   	push   %ebx
  80194a:	54                   	push   %esp
  80194b:	55                   	push   %ebp
  80194c:	56                   	push   %esi
  80194d:	57                   	push   %edi
  80194e:	54                   	push   %esp
  80194f:	5d                   	pop    %ebp
  801950:	8d 35 58 19 80 00    	lea    0x801958,%esi
  801956:	0f 34                	sysenter 
  801958:	5f                   	pop    %edi
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	5c                   	pop    %esp
  80195c:	5b                   	pop    %ebx
  80195d:	5a                   	pop    %edx
  80195e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80195f:	85 c0                	test   %eax,%eax
  801961:	7e 28                	jle    80198b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801963:	89 44 24 10          	mov    %eax,0x10(%esp)
  801967:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80196e:	00 
  80196f:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  801976:	00 
  801977:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80197e:	00 
  80197f:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  801986:	e8 65 ee ff ff       	call   8007f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80198b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80198e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801991:	89 ec                	mov    %ebp,%esp
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 28             	sub    $0x28,%esp
  80199b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80199e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8019a1:	8b 7d 18             	mov    0x18(%ebp),%edi
  8019a4:	0b 7d 14             	or     0x14(%ebp),%edi
  8019a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8019b5:	51                   	push   %ecx
  8019b6:	52                   	push   %edx
  8019b7:	53                   	push   %ebx
  8019b8:	54                   	push   %esp
  8019b9:	55                   	push   %ebp
  8019ba:	56                   	push   %esi
  8019bb:	57                   	push   %edi
  8019bc:	54                   	push   %esp
  8019bd:	5d                   	pop    %ebp
  8019be:	8d 35 c6 19 80 00    	lea    0x8019c6,%esi
  8019c4:	0f 34                	sysenter 
  8019c6:	5f                   	pop    %edi
  8019c7:	5e                   	pop    %esi
  8019c8:	5d                   	pop    %ebp
  8019c9:	5c                   	pop    %esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5a                   	pop    %edx
  8019cc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	7e 28                	jle    8019f9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8019d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019d5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8019dc:	00 
  8019dd:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  8019e4:	00 
  8019e5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8019ec:	00 
  8019ed:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  8019f4:	e8 f7 ed ff ff       	call   8007f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8019f9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019ff:	89 ec                	mov    %ebp,%esp
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 28             	sub    $0x28,%esp
  801a09:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a0c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801a0f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a14:	b8 05 00 00 00       	mov    $0x5,%eax
  801a19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a1f:	8b 55 08             	mov    0x8(%ebp),%edx
  801a22:	51                   	push   %ecx
  801a23:	52                   	push   %edx
  801a24:	53                   	push   %ebx
  801a25:	54                   	push   %esp
  801a26:	55                   	push   %ebp
  801a27:	56                   	push   %esi
  801a28:	57                   	push   %edi
  801a29:	54                   	push   %esp
  801a2a:	5d                   	pop    %ebp
  801a2b:	8d 35 33 1a 80 00    	lea    0x801a33,%esi
  801a31:	0f 34                	sysenter 
  801a33:	5f                   	pop    %edi
  801a34:	5e                   	pop    %esi
  801a35:	5d                   	pop    %ebp
  801a36:	5c                   	pop    %esp
  801a37:	5b                   	pop    %ebx
  801a38:	5a                   	pop    %edx
  801a39:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	7e 28                	jle    801a66 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801a3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a42:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801a49:	00 
  801a4a:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  801a51:	00 
  801a52:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801a59:	00 
  801a5a:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  801a61:	e8 8a ed ff ff       	call   8007f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801a66:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a69:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a6c:	89 ec                	mov    %ebp,%esp
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	89 1c 24             	mov    %ebx,(%esp)
  801a79:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a82:	b8 0c 00 00 00       	mov    $0xc,%eax
  801a87:	89 d1                	mov    %edx,%ecx
  801a89:	89 d3                	mov    %edx,%ebx
  801a8b:	89 d7                	mov    %edx,%edi
  801a8d:	51                   	push   %ecx
  801a8e:	52                   	push   %edx
  801a8f:	53                   	push   %ebx
  801a90:	54                   	push   %esp
  801a91:	55                   	push   %ebp
  801a92:	56                   	push   %esi
  801a93:	57                   	push   %edi
  801a94:	54                   	push   %esp
  801a95:	5d                   	pop    %ebp
  801a96:	8d 35 9e 1a 80 00    	lea    0x801a9e,%esi
  801a9c:	0f 34                	sysenter 
  801a9e:	5f                   	pop    %edi
  801a9f:	5e                   	pop    %esi
  801aa0:	5d                   	pop    %ebp
  801aa1:	5c                   	pop    %esp
  801aa2:	5b                   	pop    %ebx
  801aa3:	5a                   	pop    %edx
  801aa4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801aa5:	8b 1c 24             	mov    (%esp),%ebx
  801aa8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801aac:	89 ec                	mov    %ebp,%esp
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	89 1c 24             	mov    %ebx,(%esp)
  801ab9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801abd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ac2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ac7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aca:	8b 55 08             	mov    0x8(%ebp),%edx
  801acd:	89 df                	mov    %ebx,%edi
  801acf:	51                   	push   %ecx
  801ad0:	52                   	push   %edx
  801ad1:	53                   	push   %ebx
  801ad2:	54                   	push   %esp
  801ad3:	55                   	push   %ebp
  801ad4:	56                   	push   %esi
  801ad5:	57                   	push   %edi
  801ad6:	54                   	push   %esp
  801ad7:	5d                   	pop    %ebp
  801ad8:	8d 35 e0 1a 80 00    	lea    0x801ae0,%esi
  801ade:	0f 34                	sysenter 
  801ae0:	5f                   	pop    %edi
  801ae1:	5e                   	pop    %esi
  801ae2:	5d                   	pop    %ebp
  801ae3:	5c                   	pop    %esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5a                   	pop    %edx
  801ae6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801ae7:	8b 1c 24             	mov    (%esp),%ebx
  801aea:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801aee:	89 ec                	mov    %ebp,%esp
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
  801af8:	89 1c 24             	mov    %ebx,(%esp)
  801afb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801aff:	ba 00 00 00 00       	mov    $0x0,%edx
  801b04:	b8 02 00 00 00       	mov    $0x2,%eax
  801b09:	89 d1                	mov    %edx,%ecx
  801b0b:	89 d3                	mov    %edx,%ebx
  801b0d:	89 d7                	mov    %edx,%edi
  801b0f:	51                   	push   %ecx
  801b10:	52                   	push   %edx
  801b11:	53                   	push   %ebx
  801b12:	54                   	push   %esp
  801b13:	55                   	push   %ebp
  801b14:	56                   	push   %esi
  801b15:	57                   	push   %edi
  801b16:	54                   	push   %esp
  801b17:	5d                   	pop    %ebp
  801b18:	8d 35 20 1b 80 00    	lea    0x801b20,%esi
  801b1e:	0f 34                	sysenter 
  801b20:	5f                   	pop    %edi
  801b21:	5e                   	pop    %esi
  801b22:	5d                   	pop    %ebp
  801b23:	5c                   	pop    %esp
  801b24:	5b                   	pop    %ebx
  801b25:	5a                   	pop    %edx
  801b26:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801b27:	8b 1c 24             	mov    (%esp),%ebx
  801b2a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b2e:	89 ec                	mov    %ebp,%esp
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 28             	sub    $0x28,%esp
  801b38:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b3b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801b3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b43:	b8 03 00 00 00       	mov    $0x3,%eax
  801b48:	8b 55 08             	mov    0x8(%ebp),%edx
  801b4b:	89 cb                	mov    %ecx,%ebx
  801b4d:	89 cf                	mov    %ecx,%edi
  801b4f:	51                   	push   %ecx
  801b50:	52                   	push   %edx
  801b51:	53                   	push   %ebx
  801b52:	54                   	push   %esp
  801b53:	55                   	push   %ebp
  801b54:	56                   	push   %esi
  801b55:	57                   	push   %edi
  801b56:	54                   	push   %esp
  801b57:	5d                   	pop    %ebp
  801b58:	8d 35 60 1b 80 00    	lea    0x801b60,%esi
  801b5e:	0f 34                	sysenter 
  801b60:	5f                   	pop    %edi
  801b61:	5e                   	pop    %esi
  801b62:	5d                   	pop    %ebp
  801b63:	5c                   	pop    %esp
  801b64:	5b                   	pop    %ebx
  801b65:	5a                   	pop    %edx
  801b66:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801b67:	85 c0                	test   %eax,%eax
  801b69:	7e 28                	jle    801b93 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801b6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b6f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801b76:	00 
  801b77:	c7 44 24 08 a0 2f 80 	movl   $0x802fa0,0x8(%esp)
  801b7e:	00 
  801b7f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801b86:	00 
  801b87:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  801b8e:	e8 5d ec ff ff       	call   8007f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801b93:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b96:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b99:	89 ec                	mov    %ebp,%esp
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    
  801b9d:	00 00                	add    %al,(%eax)
	...

00801ba0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ba6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801bac:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb1:	39 ca                	cmp    %ecx,%edx
  801bb3:	75 04                	jne    801bb9 <ipc_find_env+0x19>
  801bb5:	b0 00                	mov    $0x0,%al
  801bb7:	eb 12                	jmp    801bcb <ipc_find_env+0x2b>
  801bb9:	89 c2                	mov    %eax,%edx
  801bbb:	c1 e2 07             	shl    $0x7,%edx
  801bbe:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801bc5:	8b 12                	mov    (%edx),%edx
  801bc7:	39 ca                	cmp    %ecx,%edx
  801bc9:	75 10                	jne    801bdb <ipc_find_env+0x3b>
			return envs[i].env_id;
  801bcb:	89 c2                	mov    %eax,%edx
  801bcd:	c1 e2 07             	shl    $0x7,%edx
  801bd0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801bd7:	8b 00                	mov    (%eax),%eax
  801bd9:	eb 0e                	jmp    801be9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bdb:	83 c0 01             	add    $0x1,%eax
  801bde:	3d 00 04 00 00       	cmp    $0x400,%eax
  801be3:	75 d4                	jne    801bb9 <ipc_find_env+0x19>
  801be5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	57                   	push   %edi
  801bef:	56                   	push   %esi
  801bf0:	53                   	push   %ebx
  801bf1:	83 ec 1c             	sub    $0x1c,%esp
  801bf4:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801bfd:	85 db                	test   %ebx,%ebx
  801bff:	74 19                	je     801c1a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801c01:	8b 45 14             	mov    0x14(%ebp),%eax
  801c04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c10:	89 34 24             	mov    %esi,(%esp)
  801c13:	e8 8c fb ff ff       	call   8017a4 <sys_ipc_try_send>
  801c18:	eb 1b                	jmp    801c35 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801c1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c21:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801c28:	ee 
  801c29:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c2d:	89 34 24             	mov    %esi,(%esp)
  801c30:	e8 6f fb ff ff       	call   8017a4 <sys_ipc_try_send>
           if(ret == 0)
  801c35:	85 c0                	test   %eax,%eax
  801c37:	74 28                	je     801c61 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801c39:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c3c:	74 1c                	je     801c5a <ipc_send+0x6f>
              panic("ipc send error");
  801c3e:	c7 44 24 08 cb 2f 80 	movl   $0x802fcb,0x8(%esp)
  801c45:	00 
  801c46:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801c4d:	00 
  801c4e:	c7 04 24 da 2f 80 00 	movl   $0x802fda,(%esp)
  801c55:	e8 96 eb ff ff       	call   8007f0 <_panic>
           sys_yield();
  801c5a:	e8 11 fe ff ff       	call   801a70 <sys_yield>
        }
  801c5f:	eb 9c                	jmp    801bfd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801c61:	83 c4 1c             	add    $0x1c,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5f                   	pop    %edi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	83 ec 10             	sub    $0x10,%esp
  801c71:	8b 75 08             	mov    0x8(%ebp),%esi
  801c74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	75 0e                	jne    801c8c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801c7e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801c85:	e8 af fa ff ff       	call   801739 <sys_ipc_recv>
  801c8a:	eb 08                	jmp    801c94 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801c8c:	89 04 24             	mov    %eax,(%esp)
  801c8f:	e8 a5 fa ff ff       	call   801739 <sys_ipc_recv>
        if(ret == 0){
  801c94:	85 c0                	test   %eax,%eax
  801c96:	75 26                	jne    801cbe <ipc_recv+0x55>
           if(from_env_store)
  801c98:	85 f6                	test   %esi,%esi
  801c9a:	74 0a                	je     801ca6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801c9c:	a1 04 50 80 00       	mov    0x805004,%eax
  801ca1:	8b 40 78             	mov    0x78(%eax),%eax
  801ca4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801ca6:	85 db                	test   %ebx,%ebx
  801ca8:	74 0a                	je     801cb4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801caa:	a1 04 50 80 00       	mov    0x805004,%eax
  801caf:	8b 40 7c             	mov    0x7c(%eax),%eax
  801cb2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801cb4:	a1 04 50 80 00       	mov    0x805004,%eax
  801cb9:	8b 40 74             	mov    0x74(%eax),%eax
  801cbc:	eb 14                	jmp    801cd2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801cbe:	85 f6                	test   %esi,%esi
  801cc0:	74 06                	je     801cc8 <ipc_recv+0x5f>
              *from_env_store = 0;
  801cc2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801cc8:	85 db                	test   %ebx,%ebx
  801cca:	74 06                	je     801cd2 <ipc_recv+0x69>
              *perm_store = 0;
  801ccc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	00 00                	add    %al,(%eax)
  801cdb:	00 00                	add    %al,(%eax)
  801cdd:	00 00                	add    %al,(%eax)
	...

00801ce0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	05 00 00 00 30       	add    $0x30000000,%eax
  801ceb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf9:	89 04 24             	mov    %eax,(%esp)
  801cfc:	e8 df ff ff ff       	call   801ce0 <fd2num>
  801d01:	05 20 00 0d 00       	add    $0xd0020,%eax
  801d06:	c1 e0 0c             	shl    $0xc,%eax
}
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    

00801d0b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	57                   	push   %edi
  801d0f:	56                   	push   %esi
  801d10:	53                   	push   %ebx
  801d11:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801d14:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801d19:	a8 01                	test   $0x1,%al
  801d1b:	74 36                	je     801d53 <fd_alloc+0x48>
  801d1d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801d22:	a8 01                	test   $0x1,%al
  801d24:	74 2d                	je     801d53 <fd_alloc+0x48>
  801d26:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801d2b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801d30:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801d35:	89 c3                	mov    %eax,%ebx
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	c1 ea 16             	shr    $0x16,%edx
  801d3c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801d3f:	f6 c2 01             	test   $0x1,%dl
  801d42:	74 14                	je     801d58 <fd_alloc+0x4d>
  801d44:	89 c2                	mov    %eax,%edx
  801d46:	c1 ea 0c             	shr    $0xc,%edx
  801d49:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801d4c:	f6 c2 01             	test   $0x1,%dl
  801d4f:	75 10                	jne    801d61 <fd_alloc+0x56>
  801d51:	eb 05                	jmp    801d58 <fd_alloc+0x4d>
  801d53:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801d58:	89 1f                	mov    %ebx,(%edi)
  801d5a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801d5f:	eb 17                	jmp    801d78 <fd_alloc+0x6d>
  801d61:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801d66:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801d6b:	75 c8                	jne    801d35 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801d6d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801d73:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801d80:	8b 45 08             	mov    0x8(%ebp),%eax
  801d83:	83 f8 1f             	cmp    $0x1f,%eax
  801d86:	77 36                	ja     801dbe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801d88:	05 00 00 0d 00       	add    $0xd0000,%eax
  801d8d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801d90:	89 c2                	mov    %eax,%edx
  801d92:	c1 ea 16             	shr    $0x16,%edx
  801d95:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d9c:	f6 c2 01             	test   $0x1,%dl
  801d9f:	74 1d                	je     801dbe <fd_lookup+0x41>
  801da1:	89 c2                	mov    %eax,%edx
  801da3:	c1 ea 0c             	shr    $0xc,%edx
  801da6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801dad:	f6 c2 01             	test   $0x1,%dl
  801db0:	74 0c                	je     801dbe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801db2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db5:	89 02                	mov    %eax,(%edx)
  801db7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801dbc:	eb 05                	jmp    801dc3 <fd_lookup+0x46>
  801dbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801dce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd5:	89 04 24             	mov    %eax,(%esp)
  801dd8:	e8 a0 ff ff ff       	call   801d7d <fd_lookup>
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 0e                	js     801def <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801de1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801de4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de7:	89 50 04             	mov    %edx,0x4(%eax)
  801dea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	56                   	push   %esi
  801df5:	53                   	push   %ebx
  801df6:	83 ec 10             	sub    $0x10,%esp
  801df9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801dff:	b8 08 40 80 00       	mov    $0x804008,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801e04:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801e09:	be 64 30 80 00       	mov    $0x803064,%esi
		if (devtab[i]->dev_id == dev_id) {
  801e0e:	39 08                	cmp    %ecx,(%eax)
  801e10:	75 10                	jne    801e22 <dev_lookup+0x31>
  801e12:	eb 04                	jmp    801e18 <dev_lookup+0x27>
  801e14:	39 08                	cmp    %ecx,(%eax)
  801e16:	75 0a                	jne    801e22 <dev_lookup+0x31>
			*dev = devtab[i];
  801e18:	89 03                	mov    %eax,(%ebx)
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801e1f:	90                   	nop
  801e20:	eb 31                	jmp    801e53 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801e22:	83 c2 01             	add    $0x1,%edx
  801e25:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	75 e8                	jne    801e14 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801e2c:	a1 04 50 80 00       	mov    0x805004,%eax
  801e31:	8b 40 48             	mov    0x48(%eax),%eax
  801e34:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3c:	c7 04 24 e4 2f 80 00 	movl   $0x802fe4,(%esp)
  801e43:	e8 61 ea ff ff       	call   8008a9 <cprintf>
	*dev = 0;
  801e48:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	5b                   	pop    %ebx
  801e57:	5e                   	pop    %esi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	53                   	push   %ebx
  801e5e:	83 ec 24             	sub    $0x24,%esp
  801e61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 07 ff ff ff       	call   801d7d <fd_lookup>
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 53                	js     801ecd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e84:	8b 00                	mov    (%eax),%eax
  801e86:	89 04 24             	mov    %eax,(%esp)
  801e89:	e8 63 ff ff ff       	call   801df1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 3b                	js     801ecd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801e92:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e9a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801e9e:	74 2d                	je     801ecd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ea0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ea3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801eaa:	00 00 00 
	stat->st_isdir = 0;
  801ead:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801eb4:	00 00 00 
	stat->st_dev = dev;
  801eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ec0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ec4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ec7:	89 14 24             	mov    %edx,(%esp)
  801eca:	ff 50 14             	call   *0x14(%eax)
}
  801ecd:	83 c4 24             	add    $0x24,%esp
  801ed0:	5b                   	pop    %ebx
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    

00801ed3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	53                   	push   %ebx
  801ed7:	83 ec 24             	sub    $0x24,%esp
  801eda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801edd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee4:	89 1c 24             	mov    %ebx,(%esp)
  801ee7:	e8 91 fe ff ff       	call   801d7d <fd_lookup>
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 5f                	js     801f4f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ef0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801efa:	8b 00                	mov    (%eax),%eax
  801efc:	89 04 24             	mov    %eax,(%esp)
  801eff:	e8 ed fe ff ff       	call   801df1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 47                	js     801f4f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f0b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801f0f:	75 23                	jne    801f34 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801f11:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801f16:	8b 40 48             	mov    0x48(%eax),%eax
  801f19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f21:	c7 04 24 04 30 80 00 	movl   $0x803004,(%esp)
  801f28:	e8 7c e9 ff ff       	call   8008a9 <cprintf>
  801f2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801f32:	eb 1b                	jmp    801f4f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f37:	8b 48 18             	mov    0x18(%eax),%ecx
  801f3a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f3f:	85 c9                	test   %ecx,%ecx
  801f41:	74 0c                	je     801f4f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801f43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4a:	89 14 24             	mov    %edx,(%esp)
  801f4d:	ff d1                	call   *%ecx
}
  801f4f:	83 c4 24             	add    $0x24,%esp
  801f52:	5b                   	pop    %ebx
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	53                   	push   %ebx
  801f59:	83 ec 24             	sub    $0x24,%esp
  801f5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f66:	89 1c 24             	mov    %ebx,(%esp)
  801f69:	e8 0f fe ff ff       	call   801d7d <fd_lookup>
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 66                	js     801fd8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7c:	8b 00                	mov    (%eax),%eax
  801f7e:	89 04 24             	mov    %eax,(%esp)
  801f81:	e8 6b fe ff ff       	call   801df1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 4e                	js     801fd8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f8d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801f91:	75 23                	jne    801fb6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801f93:	a1 04 50 80 00       	mov    0x805004,%eax
  801f98:	8b 40 48             	mov    0x48(%eax),%eax
  801f9b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa3:	c7 04 24 28 30 80 00 	movl   $0x803028,(%esp)
  801faa:	e8 fa e8 ff ff       	call   8008a9 <cprintf>
  801faf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801fb4:	eb 22                	jmp    801fd8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb9:	8b 48 0c             	mov    0xc(%eax),%ecx
  801fbc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801fc1:	85 c9                	test   %ecx,%ecx
  801fc3:	74 13                	je     801fd8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801fc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd3:	89 14 24             	mov    %edx,(%esp)
  801fd6:	ff d1                	call   *%ecx
}
  801fd8:	83 c4 24             	add    $0x24,%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 24             	sub    $0x24,%esp
  801fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fe8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801feb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fef:	89 1c 24             	mov    %ebx,(%esp)
  801ff2:	e8 86 fd ff ff       	call   801d7d <fd_lookup>
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	78 6b                	js     802066 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802002:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802005:	8b 00                	mov    (%eax),%eax
  802007:	89 04 24             	mov    %eax,(%esp)
  80200a:	e8 e2 fd ff ff       	call   801df1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80200f:	85 c0                	test   %eax,%eax
  802011:	78 53                	js     802066 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802013:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802016:	8b 42 08             	mov    0x8(%edx),%eax
  802019:	83 e0 03             	and    $0x3,%eax
  80201c:	83 f8 01             	cmp    $0x1,%eax
  80201f:	75 23                	jne    802044 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802021:	a1 04 50 80 00       	mov    0x805004,%eax
  802026:	8b 40 48             	mov    0x48(%eax),%eax
  802029:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802031:	c7 04 24 45 30 80 00 	movl   $0x803045,(%esp)
  802038:	e8 6c e8 ff ff       	call   8008a9 <cprintf>
  80203d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  802042:	eb 22                	jmp    802066 <read+0x88>
	}
	if (!dev->dev_read)
  802044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802047:	8b 48 08             	mov    0x8(%eax),%ecx
  80204a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80204f:	85 c9                	test   %ecx,%ecx
  802051:	74 13                	je     802066 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802053:	8b 45 10             	mov    0x10(%ebp),%eax
  802056:	89 44 24 08          	mov    %eax,0x8(%esp)
  80205a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802061:	89 14 24             	mov    %edx,(%esp)
  802064:	ff d1                	call   *%ecx
}
  802066:	83 c4 24             	add    $0x24,%esp
  802069:	5b                   	pop    %ebx
  80206a:	5d                   	pop    %ebp
  80206b:	c3                   	ret    

0080206c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	57                   	push   %edi
  802070:	56                   	push   %esi
  802071:	53                   	push   %ebx
  802072:	83 ec 1c             	sub    $0x1c,%esp
  802075:	8b 7d 08             	mov    0x8(%ebp),%edi
  802078:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80207b:	ba 00 00 00 00       	mov    $0x0,%edx
  802080:	bb 00 00 00 00       	mov    $0x0,%ebx
  802085:	b8 00 00 00 00       	mov    $0x0,%eax
  80208a:	85 f6                	test   %esi,%esi
  80208c:	74 29                	je     8020b7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80208e:	89 f0                	mov    %esi,%eax
  802090:	29 d0                	sub    %edx,%eax
  802092:	89 44 24 08          	mov    %eax,0x8(%esp)
  802096:	03 55 0c             	add    0xc(%ebp),%edx
  802099:	89 54 24 04          	mov    %edx,0x4(%esp)
  80209d:	89 3c 24             	mov    %edi,(%esp)
  8020a0:	e8 39 ff ff ff       	call   801fde <read>
		if (m < 0)
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	78 0e                	js     8020b7 <readn+0x4b>
			return m;
		if (m == 0)
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	74 08                	je     8020b5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8020ad:	01 c3                	add    %eax,%ebx
  8020af:	89 da                	mov    %ebx,%edx
  8020b1:	39 f3                	cmp    %esi,%ebx
  8020b3:	72 d9                	jb     80208e <readn+0x22>
  8020b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8020b7:	83 c4 1c             	add    $0x1c,%esp
  8020ba:	5b                   	pop    %ebx
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    

008020bf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 20             	sub    $0x20,%esp
  8020c7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8020ca:	89 34 24             	mov    %esi,(%esp)
  8020cd:	e8 0e fc ff ff       	call   801ce0 <fd2num>
  8020d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8020d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020d9:	89 04 24             	mov    %eax,(%esp)
  8020dc:	e8 9c fc ff ff       	call   801d7d <fd_lookup>
  8020e1:	89 c3                	mov    %eax,%ebx
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 05                	js     8020ec <fd_close+0x2d>
  8020e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8020ea:	74 0c                	je     8020f8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8020ec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8020f0:	19 c0                	sbb    %eax,%eax
  8020f2:	f7 d0                	not    %eax
  8020f4:	21 c3                	and    %eax,%ebx
  8020f6:	eb 3d                	jmp    802135 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8020f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ff:	8b 06                	mov    (%esi),%eax
  802101:	89 04 24             	mov    %eax,(%esp)
  802104:	e8 e8 fc ff ff       	call   801df1 <dev_lookup>
  802109:	89 c3                	mov    %eax,%ebx
  80210b:	85 c0                	test   %eax,%eax
  80210d:	78 16                	js     802125 <fd_close+0x66>
		if (dev->dev_close)
  80210f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802112:	8b 40 10             	mov    0x10(%eax),%eax
  802115:	bb 00 00 00 00       	mov    $0x0,%ebx
  80211a:	85 c0                	test   %eax,%eax
  80211c:	74 07                	je     802125 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80211e:	89 34 24             	mov    %esi,(%esp)
  802121:	ff d0                	call   *%eax
  802123:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802125:	89 74 24 04          	mov    %esi,0x4(%esp)
  802129:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802130:	e8 f4 f7 ff ff       	call   801929 <sys_page_unmap>
	return r;
}
  802135:	89 d8                	mov    %ebx,%eax
  802137:	83 c4 20             	add    $0x20,%esp
  80213a:	5b                   	pop    %ebx
  80213b:	5e                   	pop    %esi
  80213c:	5d                   	pop    %ebp
  80213d:	c3                   	ret    

0080213e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802144:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	89 04 24             	mov    %eax,(%esp)
  802151:	e8 27 fc ff ff       	call   801d7d <fd_lookup>
  802156:	85 c0                	test   %eax,%eax
  802158:	78 13                	js     80216d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80215a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802161:	00 
  802162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802165:	89 04 24             	mov    %eax,(%esp)
  802168:	e8 52 ff ff ff       	call   8020bf <fd_close>
}
  80216d:	c9                   	leave  
  80216e:	c3                   	ret    

0080216f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80216f:	55                   	push   %ebp
  802170:	89 e5                	mov    %esp,%ebp
  802172:	83 ec 18             	sub    $0x18,%esp
  802175:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802178:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80217b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802182:	00 
  802183:	8b 45 08             	mov    0x8(%ebp),%eax
  802186:	89 04 24             	mov    %eax,(%esp)
  802189:	e8 79 03 00 00       	call   802507 <open>
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	85 c0                	test   %eax,%eax
  802192:	78 1b                	js     8021af <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802194:	8b 45 0c             	mov    0xc(%ebp),%eax
  802197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219b:	89 1c 24             	mov    %ebx,(%esp)
  80219e:	e8 b7 fc ff ff       	call   801e5a <fstat>
  8021a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8021a5:	89 1c 24             	mov    %ebx,(%esp)
  8021a8:	e8 91 ff ff ff       	call   80213e <close>
  8021ad:	89 f3                	mov    %esi,%ebx
	return r;
}
  8021af:	89 d8                	mov    %ebx,%eax
  8021b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8021b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021b7:	89 ec                	mov    %ebp,%esp
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    

008021bb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	53                   	push   %ebx
  8021bf:	83 ec 14             	sub    $0x14,%esp
  8021c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8021c7:	89 1c 24             	mov    %ebx,(%esp)
  8021ca:	e8 6f ff ff ff       	call   80213e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8021cf:	83 c3 01             	add    $0x1,%ebx
  8021d2:	83 fb 20             	cmp    $0x20,%ebx
  8021d5:	75 f0                	jne    8021c7 <close_all+0xc>
		close(i);
}
  8021d7:	83 c4 14             	add    $0x14,%esp
  8021da:	5b                   	pop    %ebx
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    

008021dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8021dd:	55                   	push   %ebp
  8021de:	89 e5                	mov    %esp,%ebp
  8021e0:	83 ec 58             	sub    $0x58,%esp
  8021e3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8021e6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8021e9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8021ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8021ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8021f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f9:	89 04 24             	mov    %eax,(%esp)
  8021fc:	e8 7c fb ff ff       	call   801d7d <fd_lookup>
  802201:	89 c3                	mov    %eax,%ebx
  802203:	85 c0                	test   %eax,%eax
  802205:	0f 88 e0 00 00 00    	js     8022eb <dup+0x10e>
		return r;
	close(newfdnum);
  80220b:	89 3c 24             	mov    %edi,(%esp)
  80220e:	e8 2b ff ff ff       	call   80213e <close>

	newfd = INDEX2FD(newfdnum);
  802213:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802219:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80221c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80221f:	89 04 24             	mov    %eax,(%esp)
  802222:	e8 c9 fa ff ff       	call   801cf0 <fd2data>
  802227:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802229:	89 34 24             	mov    %esi,(%esp)
  80222c:	e8 bf fa ff ff       	call   801cf0 <fd2data>
  802231:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  802234:	89 da                	mov    %ebx,%edx
  802236:	89 d8                	mov    %ebx,%eax
  802238:	c1 e8 16             	shr    $0x16,%eax
  80223b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802242:	a8 01                	test   $0x1,%al
  802244:	74 43                	je     802289 <dup+0xac>
  802246:	c1 ea 0c             	shr    $0xc,%edx
  802249:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802250:	a8 01                	test   $0x1,%al
  802252:	74 35                	je     802289 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802254:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80225b:	25 07 0e 00 00       	and    $0xe07,%eax
  802260:	89 44 24 10          	mov    %eax,0x10(%esp)
  802264:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802267:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802272:	00 
  802273:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802277:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80227e:	e8 12 f7 ff ff       	call   801995 <sys_page_map>
  802283:	89 c3                	mov    %eax,%ebx
  802285:	85 c0                	test   %eax,%eax
  802287:	78 3f                	js     8022c8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80228c:	89 c2                	mov    %eax,%edx
  80228e:	c1 ea 0c             	shr    $0xc,%edx
  802291:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802298:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80229e:	89 54 24 10          	mov    %edx,0x10(%esp)
  8022a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8022a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022ad:	00 
  8022ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b9:	e8 d7 f6 ff ff       	call   801995 <sys_page_map>
  8022be:	89 c3                	mov    %eax,%ebx
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	78 04                	js     8022c8 <dup+0xeb>
  8022c4:	89 fb                	mov    %edi,%ebx
  8022c6:	eb 23                	jmp    8022eb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8022c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d3:	e8 51 f6 ff ff       	call   801929 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8022d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8022db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e6:	e8 3e f6 ff ff       	call   801929 <sys_page_unmap>
	return r;
}
  8022eb:	89 d8                	mov    %ebx,%eax
  8022ed:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8022f0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8022f3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8022f6:	89 ec                	mov    %ebp,%esp
  8022f8:	5d                   	pop    %ebp
  8022f9:	c3                   	ret    
	...

008022fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	83 ec 18             	sub    $0x18,%esp
  802302:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802305:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802308:	89 c3                	mov    %eax,%ebx
  80230a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80230c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  802313:	75 11                	jne    802326 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802315:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80231c:	e8 7f f8 ff ff       	call   801ba0 <ipc_find_env>
  802321:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802326:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80232d:	00 
  80232e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802335:	00 
  802336:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80233a:	a1 00 50 80 00       	mov    0x805000,%eax
  80233f:	89 04 24             	mov    %eax,(%esp)
  802342:	e8 a4 f8 ff ff       	call   801beb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802347:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80234e:	00 
  80234f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802353:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235a:	e8 0a f9 ff ff       	call   801c69 <ipc_recv>
}
  80235f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802362:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802365:	89 ec                	mov    %ebp,%esp
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    

00802369 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802369:	55                   	push   %ebp
  80236a:	89 e5                	mov    %esp,%ebp
  80236c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80236f:	8b 45 08             	mov    0x8(%ebp),%eax
  802372:	8b 40 0c             	mov    0xc(%eax),%eax
  802375:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80237a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802382:	ba 00 00 00 00       	mov    $0x0,%edx
  802387:	b8 02 00 00 00       	mov    $0x2,%eax
  80238c:	e8 6b ff ff ff       	call   8022fc <fsipc>
}
  802391:	c9                   	leave  
  802392:	c3                   	ret    

00802393 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802393:	55                   	push   %ebp
  802394:	89 e5                	mov    %esp,%ebp
  802396:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802399:	8b 45 08             	mov    0x8(%ebp),%eax
  80239c:	8b 40 0c             	mov    0xc(%eax),%eax
  80239f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8023a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8023a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8023ae:	e8 49 ff ff ff       	call   8022fc <fsipc>
}
  8023b3:	c9                   	leave  
  8023b4:	c3                   	ret    

008023b5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8023b5:	55                   	push   %ebp
  8023b6:	89 e5                	mov    %esp,%ebp
  8023b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8023c5:	e8 32 ff ff ff       	call   8022fc <fsipc>
}
  8023ca:	c9                   	leave  
  8023cb:	c3                   	ret    

008023cc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	53                   	push   %ebx
  8023d0:	83 ec 14             	sub    $0x14,%esp
  8023d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8023d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8023dc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8023e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8023e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8023eb:	e8 0c ff ff ff       	call   8022fc <fsipc>
  8023f0:	85 c0                	test   %eax,%eax
  8023f2:	78 2b                	js     80241f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8023f4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8023fb:	00 
  8023fc:	89 1c 24             	mov    %ebx,(%esp)
  8023ff:	e8 d6 ed ff ff       	call   8011da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802404:	a1 80 60 80 00       	mov    0x806080,%eax
  802409:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80240f:	a1 84 60 80 00       	mov    0x806084,%eax
  802414:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80241a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80241f:	83 c4 14             	add    $0x14,%esp
  802422:	5b                   	pop    %ebx
  802423:	5d                   	pop    %ebp
  802424:	c3                   	ret    

00802425 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802425:	55                   	push   %ebp
  802426:	89 e5                	mov    %esp,%ebp
  802428:	83 ec 18             	sub    $0x18,%esp
  80242b:	8b 45 10             	mov    0x10(%ebp),%eax
  80242e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802433:	76 05                	jbe    80243a <devfile_write+0x15>
  802435:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  80243a:	8b 55 08             	mov    0x8(%ebp),%edx
  80243d:	8b 52 0c             	mov    0xc(%edx),%edx
  802440:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  802446:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  80244b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80244f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802452:	89 44 24 04          	mov    %eax,0x4(%esp)
  802456:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80245d:	e8 63 ef ff ff       	call   8013c5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  802462:	ba 00 00 00 00       	mov    $0x0,%edx
  802467:	b8 04 00 00 00       	mov    $0x4,%eax
  80246c:	e8 8b fe ff ff       	call   8022fc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802471:	c9                   	leave  
  802472:	c3                   	ret    

00802473 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802473:	55                   	push   %ebp
  802474:	89 e5                	mov    %esp,%ebp
  802476:	53                   	push   %ebx
  802477:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80247a:	8b 45 08             	mov    0x8(%ebp),%eax
  80247d:	8b 40 0c             	mov    0xc(%eax),%eax
  802480:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  802485:	8b 45 10             	mov    0x10(%ebp),%eax
  802488:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  80248d:	ba 00 00 00 00       	mov    $0x0,%edx
  802492:	b8 03 00 00 00       	mov    $0x3,%eax
  802497:	e8 60 fe ff ff       	call   8022fc <fsipc>
  80249c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80249e:	85 c0                	test   %eax,%eax
  8024a0:	78 17                	js     8024b9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  8024a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a6:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8024ad:	00 
  8024ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b1:	89 04 24             	mov    %eax,(%esp)
  8024b4:	e8 0c ef ff ff       	call   8013c5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  8024b9:	89 d8                	mov    %ebx,%eax
  8024bb:	83 c4 14             	add    $0x14,%esp
  8024be:	5b                   	pop    %ebx
  8024bf:	5d                   	pop    %ebp
  8024c0:	c3                   	ret    

008024c1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8024c1:	55                   	push   %ebp
  8024c2:	89 e5                	mov    %esp,%ebp
  8024c4:	53                   	push   %ebx
  8024c5:	83 ec 14             	sub    $0x14,%esp
  8024c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8024cb:	89 1c 24             	mov    %ebx,(%esp)
  8024ce:	e8 bd ec ff ff       	call   801190 <strlen>
  8024d3:	89 c2                	mov    %eax,%edx
  8024d5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8024da:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8024e0:	7f 1f                	jg     802501 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8024e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024e6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8024ed:	e8 e8 ec ff ff       	call   8011da <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8024f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f7:	b8 07 00 00 00       	mov    $0x7,%eax
  8024fc:	e8 fb fd ff ff       	call   8022fc <fsipc>
}
  802501:	83 c4 14             	add    $0x14,%esp
  802504:	5b                   	pop    %ebx
  802505:	5d                   	pop    %ebp
  802506:	c3                   	ret    

00802507 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802507:	55                   	push   %ebp
  802508:	89 e5                	mov    %esp,%ebp
  80250a:	83 ec 28             	sub    $0x28,%esp
  80250d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802510:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802513:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802516:	89 34 24             	mov    %esi,(%esp)
  802519:	e8 72 ec ff ff       	call   801190 <strlen>
  80251e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802523:	3d 00 04 00 00       	cmp    $0x400,%eax
  802528:	7f 6d                	jg     802597 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80252a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80252d:	89 04 24             	mov    %eax,(%esp)
  802530:	e8 d6 f7 ff ff       	call   801d0b <fd_alloc>
  802535:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  802537:	85 c0                	test   %eax,%eax
  802539:	78 5c                	js     802597 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80253b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  802543:	89 34 24             	mov    %esi,(%esp)
  802546:	e8 45 ec ff ff       	call   801190 <strlen>
  80254b:	83 c0 01             	add    $0x1,%eax
  80254e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802552:	89 74 24 04          	mov    %esi,0x4(%esp)
  802556:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80255d:	e8 63 ee ff ff       	call   8013c5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  802562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802565:	b8 01 00 00 00       	mov    $0x1,%eax
  80256a:	e8 8d fd ff ff       	call   8022fc <fsipc>
  80256f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802571:	85 c0                	test   %eax,%eax
  802573:	79 15                	jns    80258a <open+0x83>
             fd_close(fd,0);
  802575:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80257c:	00 
  80257d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802580:	89 04 24             	mov    %eax,(%esp)
  802583:	e8 37 fb ff ff       	call   8020bf <fd_close>
             return r;
  802588:	eb 0d                	jmp    802597 <open+0x90>
        }
        return fd2num(fd);
  80258a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80258d:	89 04 24             	mov    %eax,(%esp)
  802590:	e8 4b f7 ff ff       	call   801ce0 <fd2num>
  802595:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802597:	89 d8                	mov    %ebx,%eax
  802599:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80259c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80259f:	89 ec                	mov    %ebp,%esp
  8025a1:	5d                   	pop    %ebp
  8025a2:	c3                   	ret    
	...

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	89 e5                	mov    %esp,%ebp
  8025b3:	57                   	push   %edi
  8025b4:	56                   	push   %esi
  8025b5:	83 ec 10             	sub    $0x10,%esp
  8025b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8025bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8025be:	8b 75 10             	mov    0x10(%ebp),%esi
  8025c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025c4:	85 c0                	test   %eax,%eax
  8025c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8025c9:	75 35                	jne    802600 <__udivdi3+0x50>
  8025cb:	39 fe                	cmp    %edi,%esi
  8025cd:	77 61                	ja     802630 <__udivdi3+0x80>
  8025cf:	85 f6                	test   %esi,%esi
  8025d1:	75 0b                	jne    8025de <__udivdi3+0x2e>
  8025d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d8:	31 d2                	xor    %edx,%edx
  8025da:	f7 f6                	div    %esi
  8025dc:	89 c6                	mov    %eax,%esi
  8025de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8025e1:	31 d2                	xor    %edx,%edx
  8025e3:	89 f8                	mov    %edi,%eax
  8025e5:	f7 f6                	div    %esi
  8025e7:	89 c7                	mov    %eax,%edi
  8025e9:	89 c8                	mov    %ecx,%eax
  8025eb:	f7 f6                	div    %esi
  8025ed:	89 c1                	mov    %eax,%ecx
  8025ef:	89 fa                	mov    %edi,%edx
  8025f1:	89 c8                	mov    %ecx,%eax
  8025f3:	83 c4 10             	add    $0x10,%esp
  8025f6:	5e                   	pop    %esi
  8025f7:	5f                   	pop    %edi
  8025f8:	5d                   	pop    %ebp
  8025f9:	c3                   	ret    
  8025fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802600:	39 f8                	cmp    %edi,%eax
  802602:	77 1c                	ja     802620 <__udivdi3+0x70>
  802604:	0f bd d0             	bsr    %eax,%edx
  802607:	83 f2 1f             	xor    $0x1f,%edx
  80260a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80260d:	75 39                	jne    802648 <__udivdi3+0x98>
  80260f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802612:	0f 86 a0 00 00 00    	jbe    8026b8 <__udivdi3+0x108>
  802618:	39 f8                	cmp    %edi,%eax
  80261a:	0f 82 98 00 00 00    	jb     8026b8 <__udivdi3+0x108>
  802620:	31 ff                	xor    %edi,%edi
  802622:	31 c9                	xor    %ecx,%ecx
  802624:	89 c8                	mov    %ecx,%eax
  802626:	89 fa                	mov    %edi,%edx
  802628:	83 c4 10             	add    $0x10,%esp
  80262b:	5e                   	pop    %esi
  80262c:	5f                   	pop    %edi
  80262d:	5d                   	pop    %ebp
  80262e:	c3                   	ret    
  80262f:	90                   	nop
  802630:	89 d1                	mov    %edx,%ecx
  802632:	89 fa                	mov    %edi,%edx
  802634:	89 c8                	mov    %ecx,%eax
  802636:	31 ff                	xor    %edi,%edi
  802638:	f7 f6                	div    %esi
  80263a:	89 c1                	mov    %eax,%ecx
  80263c:	89 fa                	mov    %edi,%edx
  80263e:	89 c8                	mov    %ecx,%eax
  802640:	83 c4 10             	add    $0x10,%esp
  802643:	5e                   	pop    %esi
  802644:	5f                   	pop    %edi
  802645:	5d                   	pop    %ebp
  802646:	c3                   	ret    
  802647:	90                   	nop
  802648:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80264c:	89 f2                	mov    %esi,%edx
  80264e:	d3 e0                	shl    %cl,%eax
  802650:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802653:	b8 20 00 00 00       	mov    $0x20,%eax
  802658:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80265b:	89 c1                	mov    %eax,%ecx
  80265d:	d3 ea                	shr    %cl,%edx
  80265f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802663:	0b 55 ec             	or     -0x14(%ebp),%edx
  802666:	d3 e6                	shl    %cl,%esi
  802668:	89 c1                	mov    %eax,%ecx
  80266a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80266d:	89 fe                	mov    %edi,%esi
  80266f:	d3 ee                	shr    %cl,%esi
  802671:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802675:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802678:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80267b:	d3 e7                	shl    %cl,%edi
  80267d:	89 c1                	mov    %eax,%ecx
  80267f:	d3 ea                	shr    %cl,%edx
  802681:	09 d7                	or     %edx,%edi
  802683:	89 f2                	mov    %esi,%edx
  802685:	89 f8                	mov    %edi,%eax
  802687:	f7 75 ec             	divl   -0x14(%ebp)
  80268a:	89 d6                	mov    %edx,%esi
  80268c:	89 c7                	mov    %eax,%edi
  80268e:	f7 65 e8             	mull   -0x18(%ebp)
  802691:	39 d6                	cmp    %edx,%esi
  802693:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802696:	72 30                	jb     8026c8 <__udivdi3+0x118>
  802698:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80269b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80269f:	d3 e2                	shl    %cl,%edx
  8026a1:	39 c2                	cmp    %eax,%edx
  8026a3:	73 05                	jae    8026aa <__udivdi3+0xfa>
  8026a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8026a8:	74 1e                	je     8026c8 <__udivdi3+0x118>
  8026aa:	89 f9                	mov    %edi,%ecx
  8026ac:	31 ff                	xor    %edi,%edi
  8026ae:	e9 71 ff ff ff       	jmp    802624 <__udivdi3+0x74>
  8026b3:	90                   	nop
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	31 ff                	xor    %edi,%edi
  8026ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  8026bf:	e9 60 ff ff ff       	jmp    802624 <__udivdi3+0x74>
  8026c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8026cb:	31 ff                	xor    %edi,%edi
  8026cd:	89 c8                	mov    %ecx,%eax
  8026cf:	89 fa                	mov    %edi,%edx
  8026d1:	83 c4 10             	add    $0x10,%esp
  8026d4:	5e                   	pop    %esi
  8026d5:	5f                   	pop    %edi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    
	...

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	89 e5                	mov    %esp,%ebp
  8026e3:	57                   	push   %edi
  8026e4:	56                   	push   %esi
  8026e5:	83 ec 20             	sub    $0x20,%esp
  8026e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8026eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8026f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026f4:	85 d2                	test   %edx,%edx
  8026f6:	89 c8                	mov    %ecx,%eax
  8026f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8026fb:	75 13                	jne    802710 <__umoddi3+0x30>
  8026fd:	39 f7                	cmp    %esi,%edi
  8026ff:	76 3f                	jbe    802740 <__umoddi3+0x60>
  802701:	89 f2                	mov    %esi,%edx
  802703:	f7 f7                	div    %edi
  802705:	89 d0                	mov    %edx,%eax
  802707:	31 d2                	xor    %edx,%edx
  802709:	83 c4 20             	add    $0x20,%esp
  80270c:	5e                   	pop    %esi
  80270d:	5f                   	pop    %edi
  80270e:	5d                   	pop    %ebp
  80270f:	c3                   	ret    
  802710:	39 f2                	cmp    %esi,%edx
  802712:	77 4c                	ja     802760 <__umoddi3+0x80>
  802714:	0f bd ca             	bsr    %edx,%ecx
  802717:	83 f1 1f             	xor    $0x1f,%ecx
  80271a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80271d:	75 51                	jne    802770 <__umoddi3+0x90>
  80271f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802722:	0f 87 e0 00 00 00    	ja     802808 <__umoddi3+0x128>
  802728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80272b:	29 f8                	sub    %edi,%eax
  80272d:	19 d6                	sbb    %edx,%esi
  80272f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802735:	89 f2                	mov    %esi,%edx
  802737:	83 c4 20             	add    $0x20,%esp
  80273a:	5e                   	pop    %esi
  80273b:	5f                   	pop    %edi
  80273c:	5d                   	pop    %ebp
  80273d:	c3                   	ret    
  80273e:	66 90                	xchg   %ax,%ax
  802740:	85 ff                	test   %edi,%edi
  802742:	75 0b                	jne    80274f <__umoddi3+0x6f>
  802744:	b8 01 00 00 00       	mov    $0x1,%eax
  802749:	31 d2                	xor    %edx,%edx
  80274b:	f7 f7                	div    %edi
  80274d:	89 c7                	mov    %eax,%edi
  80274f:	89 f0                	mov    %esi,%eax
  802751:	31 d2                	xor    %edx,%edx
  802753:	f7 f7                	div    %edi
  802755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802758:	f7 f7                	div    %edi
  80275a:	eb a9                	jmp    802705 <__umoddi3+0x25>
  80275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	83 c4 20             	add    $0x20,%esp
  802767:	5e                   	pop    %esi
  802768:	5f                   	pop    %edi
  802769:	5d                   	pop    %ebp
  80276a:	c3                   	ret    
  80276b:	90                   	nop
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802774:	d3 e2                	shl    %cl,%edx
  802776:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802779:	ba 20 00 00 00       	mov    $0x20,%edx
  80277e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802781:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802784:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802788:	89 fa                	mov    %edi,%edx
  80278a:	d3 ea                	shr    %cl,%edx
  80278c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802790:	0b 55 f4             	or     -0xc(%ebp),%edx
  802793:	d3 e7                	shl    %cl,%edi
  802795:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802799:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80279c:	89 f2                	mov    %esi,%edx
  80279e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8027a1:	89 c7                	mov    %eax,%edi
  8027a3:	d3 ea                	shr    %cl,%edx
  8027a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8027ac:	89 c2                	mov    %eax,%edx
  8027ae:	d3 e6                	shl    %cl,%esi
  8027b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027b4:	d3 ea                	shr    %cl,%edx
  8027b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027ba:	09 d6                	or     %edx,%esi
  8027bc:	89 f0                	mov    %esi,%eax
  8027be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8027c1:	d3 e7                	shl    %cl,%edi
  8027c3:	89 f2                	mov    %esi,%edx
  8027c5:	f7 75 f4             	divl   -0xc(%ebp)
  8027c8:	89 d6                	mov    %edx,%esi
  8027ca:	f7 65 e8             	mull   -0x18(%ebp)
  8027cd:	39 d6                	cmp    %edx,%esi
  8027cf:	72 2b                	jb     8027fc <__umoddi3+0x11c>
  8027d1:	39 c7                	cmp    %eax,%edi
  8027d3:	72 23                	jb     8027f8 <__umoddi3+0x118>
  8027d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027d9:	29 c7                	sub    %eax,%edi
  8027db:	19 d6                	sbb    %edx,%esi
  8027dd:	89 f0                	mov    %esi,%eax
  8027df:	89 f2                	mov    %esi,%edx
  8027e1:	d3 ef                	shr    %cl,%edi
  8027e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027e7:	d3 e0                	shl    %cl,%eax
  8027e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027ed:	09 f8                	or     %edi,%eax
  8027ef:	d3 ea                	shr    %cl,%edx
  8027f1:	83 c4 20             	add    $0x20,%esp
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	39 d6                	cmp    %edx,%esi
  8027fa:	75 d9                	jne    8027d5 <__umoddi3+0xf5>
  8027fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8027ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802802:	eb d1                	jmp    8027d5 <__umoddi3+0xf5>
  802804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802808:	39 f2                	cmp    %esi,%edx
  80280a:	0f 82 18 ff ff ff    	jb     802728 <__umoddi3+0x48>
  802810:	e9 1d ff ff ff       	jmp    802732 <__umoddi3+0x52>
