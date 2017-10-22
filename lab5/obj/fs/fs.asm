
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 73 1d 00 00       	call   801da4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800046:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80004b:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  80004c:	0f b6 d8             	movzbl %al,%ebx
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 c0 00 00 00       	and    $0xc0,%eax
  800056:	83 f8 40             	cmp    $0x40,%eax
  800059:	75 f0                	jne    80004b <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80005b:	85 c9                	test   %ecx,%ecx
  80005d:	74 0a                	je     800069 <ide_wait_ready+0x29>
  80005f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800064:	f6 c3 21             	test   $0x21,%bl
  800067:	75 05                	jne    80006e <ide_wait_ready+0x2e>
  800069:	b8 00 00 00 00       	mov    $0x0,%eax
		return -1;
	return 0;
}
  80006e:	5b                   	pop    %ebx
  80006f:	5d                   	pop    %ebp
  800070:	c3                   	ret    

00800071 <ide_write>:
	return 0;
}

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  800071:	55                   	push   %ebp
  800072:	89 e5                	mov    %esp,%ebp
  800074:	57                   	push   %edi
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	83 ec 1c             	sub    $0x1c,%esp
  80007a:	8b 75 08             	mov    0x8(%ebp),%esi
  80007d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800080:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  800083:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  800089:	76 24                	jbe    8000af <ide_write+0x3e>
  80008b:	c7 44 24 0c 00 3f 80 	movl   $0x803f00,0xc(%esp)
  800092:	00 
  800093:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  80009a:	00 
  80009b:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8000a2:	00 
  8000a3:	c7 04 24 22 3f 80 00 	movl   $0x803f22,(%esp)
  8000aa:	e8 65 1d 00 00       	call   801e14 <_panic>

	ide_wait_ready(0);
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	e8 87 ff ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000b9:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8000be:	89 f8                	mov    %edi,%eax
  8000c0:	ee                   	out    %al,(%dx)
  8000c1:	b2 f3                	mov    $0xf3,%dl
  8000c3:	89 f0                	mov    %esi,%eax
  8000c5:	ee                   	out    %al,(%dx)
  8000c6:	89 f0                	mov    %esi,%eax
  8000c8:	c1 e8 08             	shr    $0x8,%eax
  8000cb:	b2 f4                	mov    $0xf4,%dl
  8000cd:	ee                   	out    %al,(%dx)
  8000ce:	89 f0                	mov    %esi,%eax
  8000d0:	c1 e8 10             	shr    $0x10,%eax
  8000d3:	b2 f5                	mov    $0xf5,%dl
  8000d5:	ee                   	out    %al,(%dx)
  8000d6:	a1 00 50 80 00       	mov    0x805000,%eax
  8000db:	83 e0 01             	and    $0x1,%eax
  8000de:	c1 e0 04             	shl    $0x4,%eax
  8000e1:	83 c8 e0             	or     $0xffffffe0,%eax
  8000e4:	c1 ee 18             	shr    $0x18,%esi
  8000e7:	83 e6 0f             	and    $0xf,%esi
  8000ea:	09 f0                	or     %esi,%eax
  8000ec:	b2 f6                	mov    $0xf6,%dl
  8000ee:	ee                   	out    %al,(%dx)
  8000ef:	b2 f7                	mov    $0xf7,%dl
  8000f1:	b8 30 00 00 00       	mov    $0x30,%eax
  8000f6:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  8000f7:	85 ff                	test   %edi,%edi
  8000f9:	74 2a                	je     800125 <ide_write+0xb4>
		if ((r = ide_wait_ready(1)) < 0)
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	e8 3b ff ff ff       	call   800040 <ide_wait_ready>
  800105:	85 c0                	test   %eax,%eax
  800107:	78 21                	js     80012a <ide_write+0xb9>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800109:	89 de                	mov    %ebx,%esi
  80010b:	b9 80 00 00 00       	mov    $0x80,%ecx
  800110:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800115:	fc                   	cld    
  800116:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800118:	83 ef 01             	sub    $0x1,%edi
  80011b:	74 08                	je     800125 <ide_write+0xb4>
  80011d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800123:	eb d6                	jmp    8000fb <ide_write+0x8a>
  800125:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  80012a:	83 c4 1c             	add    $0x1c,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <ide_read>:
	diskno = d;
}

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	83 ec 1c             	sub    $0x1c,%esp
  80013b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80013e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800141:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800144:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80014a:	76 24                	jbe    800170 <ide_read+0x3e>
  80014c:	c7 44 24 0c 00 3f 80 	movl   $0x803f00,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800163:	00 
  800164:	c7 04 24 22 3f 80 00 	movl   $0x803f22,(%esp)
  80016b:	e8 a4 1c 00 00       	call   801e14 <_panic>

	ide_wait_ready(0);
  800170:	b8 00 00 00 00       	mov    $0x0,%eax
  800175:	e8 c6 fe ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80017a:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80017f:	89 f0                	mov    %esi,%eax
  800181:	ee                   	out    %al,(%dx)
  800182:	b2 f3                	mov    $0xf3,%dl
  800184:	89 f8                	mov    %edi,%eax
  800186:	ee                   	out    %al,(%dx)
  800187:	89 f8                	mov    %edi,%eax
  800189:	c1 e8 08             	shr    $0x8,%eax
  80018c:	b2 f4                	mov    $0xf4,%dl
  80018e:	ee                   	out    %al,(%dx)
  80018f:	89 f8                	mov    %edi,%eax
  800191:	c1 e8 10             	shr    $0x10,%eax
  800194:	b2 f5                	mov    $0xf5,%dl
  800196:	ee                   	out    %al,(%dx)
  800197:	a1 00 50 80 00       	mov    0x805000,%eax
  80019c:	83 e0 01             	and    $0x1,%eax
  80019f:	c1 e0 04             	shl    $0x4,%eax
  8001a2:	83 c8 e0             	or     $0xffffffe0,%eax
  8001a5:	c1 ef 18             	shr    $0x18,%edi
  8001a8:	83 e7 0f             	and    $0xf,%edi
  8001ab:	09 f8                	or     %edi,%eax
  8001ad:	b2 f6                	mov    $0xf6,%dl
  8001af:	ee                   	out    %al,(%dx)
  8001b0:	b2 f7                	mov    $0xf7,%dl
  8001b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8001b7:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001b8:	85 f6                	test   %esi,%esi
  8001ba:	74 2a                	je     8001e6 <ide_read+0xb4>
		if ((r = ide_wait_ready(1)) < 0)
  8001bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8001c1:	e8 7a fe ff ff       	call   800040 <ide_wait_ready>
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	78 21                	js     8001eb <ide_read+0xb9>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  8001ca:	89 df                	mov    %ebx,%edi
  8001cc:	b9 80 00 00 00       	mov    $0x80,%ecx
  8001d1:	ba f0 01 00 00       	mov    $0x1f0,%edx
  8001d6:	fc                   	cld    
  8001d7:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001d9:	83 ee 01             	sub    $0x1,%esi
  8001dc:	74 08                	je     8001e6 <ide_read+0xb4>
  8001de:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8001e4:	eb d6                	jmp    8001bc <ide_read+0x8a>
  8001e6:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
}
  8001eb:	83 c4 1c             	add    $0x1c,%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5e                   	pop    %esi
  8001f0:	5f                   	pop    %edi
  8001f1:	5d                   	pop    %ebp
  8001f2:	c3                   	ret    

008001f3 <ide_set_disk>:
	return (x < 1000);
}

void
ide_set_disk(int d)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	83 ec 18             	sub    $0x18,%esp
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8001fc:	83 f8 01             	cmp    $0x1,%eax
  8001ff:	76 1c                	jbe    80021d <ide_set_disk+0x2a>
		panic("bad disk number");
  800201:	c7 44 24 08 2b 3f 80 	movl   $0x803f2b,0x8(%esp)
  800208:	00 
  800209:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800210:	00 
  800211:	c7 04 24 22 3f 80 00 	movl   $0x803f22,(%esp)
  800218:	e8 f7 1b 00 00       	call   801e14 <_panic>
	diskno = d;
  80021d:	a3 00 50 80 00       	mov    %eax,0x805000
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <ide_probe_disk1>:
	return 0;
}

bool
ide_probe_disk1(void)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80022b:	b8 00 00 00 00       	mov    $0x0,%eax
  800230:	e8 0b fe ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800235:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80023a:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80023f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800240:	b2 f7                	mov    $0xf7,%dl
  800242:	ec                   	in     (%dx),%al

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800243:	b9 01 00 00 00       	mov    $0x1,%ecx
  800248:	a8 a1                	test   $0xa1,%al
  80024a:	75 0f                	jne    80025b <ide_probe_disk1+0x37>
  80024c:	b1 00                	mov    $0x0,%cl
  80024e:	eb 10                	jmp    800260 <ide_probe_disk1+0x3c>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800250:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800253:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800259:	74 05                	je     800260 <ide_probe_disk1+0x3c>
  80025b:	ec                   	in     (%dx),%al
  80025c:	a8 a1                	test   $0xa1,%al
  80025e:	75 f0                	jne    800250 <ide_probe_disk1+0x2c>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800260:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800265:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80026a:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  80026b:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  800271:	0f 9e c3             	setle  %bl
  800274:	0f b6 db             	movzbl %bl,%ebx
  800277:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80027b:	c7 04 24 3b 3f 80 00 	movl   $0x803f3b,(%esp)
  800282:	e8 46 1c 00 00       	call   801ecd <cprintf>
	return (x < 1000);
}
  800287:	89 d8                	mov    %ebx,%eax
  800289:	83 c4 14             	add    $0x14,%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    
	...

00800290 <va_is_mapped>:
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
	return (vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P);
  800293:	8b 55 08             	mov    0x8(%ebp),%edx
  800296:	89 d0                	mov    %edx,%eax
  800298:	c1 e8 16             	shr    $0x16,%eax
  80029b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8002a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a7:	f6 c1 01             	test   $0x1,%cl
  8002aa:	74 0d                	je     8002b9 <va_is_mapped+0x29>
  8002ac:	c1 ea 0c             	shr    $0xc,%edx
  8002af:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8002b6:	83 e0 01             	and    $0x1,%eax
}
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
	return (vpt[PGNUM(va)] & PTE_D) != 0;
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	c1 e8 0c             	shr    $0xc,%eax
  8002c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002cb:	c1 e8 06             	shr    $0x6,%eax
  8002ce:	83 e0 01             	and    $0x1,%eax
}
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	83 ec 18             	sub    $0x18,%esp
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	74 0f                	je     8002ef <diskaddr+0x1c>
  8002e0:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8002e6:	85 d2                	test   %edx,%edx
  8002e8:	74 25                	je     80030f <diskaddr+0x3c>
  8002ea:	3b 42 04             	cmp    0x4(%edx),%eax
  8002ed:	72 20                	jb     80030f <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  8002ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f3:	c7 44 24 08 54 3f 80 	movl   $0x803f54,0x8(%esp)
  8002fa:	00 
  8002fb:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800302:	00 
  800303:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  80030a:	e8 05 1b 00 00       	call   801e14 <_panic>
  80030f:	05 00 00 01 00       	add    $0x10000,%eax
  800314:	c1 e0 0c             	shl    $0xc,%eax
	return (char*) (DISKMAP + blockno * BLKSIZE);
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <bc_pgfault>:
// Fault any disk block that is read or written in to memory by
// loading it from disk.
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 20             	sub    $0x20,%esp
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800324:	8b 30                	mov    (%eax),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800326:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
  80032c:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800332:	76 2e                	jbe    800362 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800334:	8b 50 04             	mov    0x4(%eax),%edx
  800337:	89 54 24 14          	mov    %edx,0x14(%esp)
  80033b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80033f:	8b 40 28             	mov    0x28(%eax),%eax
  800342:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800346:	c7 44 24 08 78 3f 80 	movl   $0x803f78,0x8(%esp)
  80034d:	00 
  80034e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800355:	00 
  800356:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  80035d:	e8 b2 1a 00 00       	call   801e14 <_panic>
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800362:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
  800368:	c1 eb 0c             	shr    $0xc,%ebx
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80036b:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800370:	85 c0                	test   %eax,%eax
  800372:	74 25                	je     800399 <bc_pgfault+0x80>
  800374:	3b 58 04             	cmp    0x4(%eax),%ebx
  800377:	72 20                	jb     800399 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  800379:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80037d:	c7 44 24 08 a8 3f 80 	movl   $0x803fa8,0x8(%esp)
  800384:	00 
  800385:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80038c:	00 
  80038d:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  800394:	e8 7b 1a 00 00       	call   801e14 <_panic>
	// of the block from the disk into that page, and mark the
	// page not-dirty (since reading the data from disk will mark
	// the page dirty).
	//
	// LAB 5: Your code here
        void* newaddr = ROUNDDOWN(addr,PGSIZE);
  800399:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        if((r = sys_page_alloc(0, newaddr, PTE_P|PTE_U|PTE_W|PTE_SYSCALL)) < 0)
  80039f:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  8003a6:	00 
  8003a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003b2:	e8 6c 2c 00 00       	call   803023 <sys_page_alloc>
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	79 20                	jns    8003db <bc_pgfault+0xc2>
            panic("sys_page_alloc: %e", r);
  8003bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003bf:	c7 44 24 08 f8 3f 80 	movl   $0x803ff8,0x8(%esp)
  8003c6:	00 
  8003c7:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  8003ce:	00 
  8003cf:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  8003d6:	e8 39 1a 00 00       	call   801e14 <_panic>
        if((r = ide_read(BLKSECTS* blockno,newaddr,BLKSECTS)) < 0)
  8003db:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8003e2:	00 
  8003e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e7:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
  8003ee:	89 04 24             	mov    %eax,(%esp)
  8003f1:	e8 3c fd ff ff       	call   800132 <ide_read>
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	79 20                	jns    80041a <bc_pgfault+0x101>
            panic("ide_read: %e",r);
  8003fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fe:	c7 44 24 08 0b 40 80 	movl   $0x80400b,0x8(%esp)
  800405:	00 
  800406:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  80040d:	00 
  80040e:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  800415:	e8 fa 19 00 00       	call   801e14 <_panic>
	//panic("bc_pgfault not implemented");

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80041a:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800421:	74 2c                	je     80044f <bc_pgfault+0x136>
  800423:	89 1c 24             	mov    %ebx,(%esp)
  800426:	e8 05 03 00 00       	call   800730 <block_is_free>
  80042b:	85 c0                	test   %eax,%eax
  80042d:	74 20                	je     80044f <bc_pgfault+0x136>
		panic("reading free block %08x\n", blockno);
  80042f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800433:	c7 44 24 08 18 40 80 	movl   $0x804018,0x8(%esp)
  80043a:	00 
  80043b:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  800442:	00 
  800443:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  80044a:	e8 c5 19 00 00       	call   801e14 <_panic>
}
  80044f:	83 c4 20             	add    $0x20,%esp
  800452:	5b                   	pop    %ebx
  800453:	5e                   	pop    %esi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	83 ec 28             	sub    $0x28,%esp
  80045c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80045f:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800462:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800465:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  80046b:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800470:	76 20                	jbe    800492 <flush_block+0x3c>
		panic("flush_block of bad va %08x", addr);
  800472:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800476:	c7 44 24 08 31 40 80 	movl   $0x804031,0x8(%esp)
  80047d:	00 
  80047e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  800485:	00 
  800486:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  80048d:	e8 82 19 00 00       	call   801e14 <_panic>

	// LAB 5: Your code here.
        int r;
        void* newaddr = ROUNDDOWN(addr,PGSIZE);
  800492:	89 f3                	mov    %esi,%ebx
  800494:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        if(va_is_mapped(newaddr) && va_is_dirty(newaddr)){
  80049a:	89 1c 24             	mov    %ebx,(%esp)
  80049d:	e8 ee fd ff ff       	call   800290 <va_is_mapped>
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	0f 84 9c 00 00 00    	je     800546 <flush_block+0xf0>
  8004aa:	89 1c 24             	mov    %ebx,(%esp)
  8004ad:	e8 09 fe ff ff       	call   8002bb <va_is_dirty>
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	0f 84 8c 00 00 00    	je     800546 <flush_block+0xf0>
             if((r = ide_write(BLKSECTS* blockno,newaddr,BLKSECTS))<0)
  8004ba:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004c1:	00 
  8004c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c6:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  8004cc:	c1 ee 0c             	shr    $0xc,%esi
  8004cf:	c1 e6 03             	shl    $0x3,%esi
  8004d2:	89 34 24             	mov    %esi,(%esp)
  8004d5:	e8 97 fb ff ff       	call   800071 <ide_write>
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	79 20                	jns    8004fe <flush_block+0xa8>
                  panic("ide_write: %e",r);
  8004de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e2:	c7 44 24 08 4c 40 80 	movl   $0x80404c,0x8(%esp)
  8004e9:	00 
  8004ea:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  8004f1:	00 
  8004f2:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  8004f9:	e8 16 19 00 00       	call   801e14 <_panic>
             if((r = sys_page_map(0,newaddr,0,newaddr,PTE_P|PTE_U|PTE_W|PTE_SYSCALL))<0)
  8004fe:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800505:	00 
  800506:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80050a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800511:	00 
  800512:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800516:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80051d:	e8 93 2a 00 00       	call   802fb5 <sys_page_map>
  800522:	85 c0                	test   %eax,%eax
  800524:	79 20                	jns    800546 <flush_block+0xf0>
                  panic("sys_page_map: %e", r);
  800526:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052a:	c7 44 24 08 5a 40 80 	movl   $0x80405a,0x8(%esp)
  800531:	00 
  800532:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800539:	00 
  80053a:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  800541:	e8 ce 18 00 00       	call   801e14 <_panic>
        }
            
        
	//panic("flush_block not implemented");
}
  800546:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800549:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80054c:	89 ec                	mov    %ebp,%esp
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800559:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800560:	e8 6e fd ff ff       	call   8002d3 <diskaddr>
  800565:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80056c:	00 
  80056d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800571:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800577:	89 04 24             	mov    %eax,(%esp)
  80057a:	e8 66 24 00 00       	call   8029e5 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80057f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800586:	e8 48 fd ff ff       	call   8002d3 <diskaddr>
  80058b:	c7 44 24 04 6b 40 80 	movl   $0x80406b,0x4(%esp)
  800592:	00 
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	e8 5f 22 00 00       	call   8027fa <strcpy>
	flush_block(diskaddr(1));
  80059b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a2:	e8 2c fd ff ff       	call   8002d3 <diskaddr>
  8005a7:	89 04 24             	mov    %eax,(%esp)
  8005aa:	e8 a7 fe ff ff       	call   800456 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8005af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b6:	e8 18 fd ff ff       	call   8002d3 <diskaddr>
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	e8 cd fc ff ff       	call   800290 <va_is_mapped>
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	75 24                	jne    8005eb <check_bc+0x9b>
  8005c7:	c7 44 24 0c 8d 40 80 	movl   $0x80408d,0xc(%esp)
  8005ce:	00 
  8005cf:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  8005d6:	00 
  8005d7:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8005de:	00 
  8005df:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  8005e6:	e8 29 18 00 00       	call   801e14 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  8005eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005f2:	e8 dc fc ff ff       	call   8002d3 <diskaddr>
  8005f7:	89 04 24             	mov    %eax,(%esp)
  8005fa:	e8 bc fc ff ff       	call   8002bb <va_is_dirty>
  8005ff:	85 c0                	test   %eax,%eax
  800601:	74 24                	je     800627 <check_bc+0xd7>
  800603:	c7 44 24 0c 72 40 80 	movl   $0x804072,0xc(%esp)
  80060a:	00 
  80060b:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  800612:	00 
  800613:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80061a:	00 
  80061b:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  800622:	e8 ed 17 00 00       	call   801e14 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800627:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062e:	e8 a0 fc ff ff       	call   8002d3 <diskaddr>
  800633:	89 44 24 04          	mov    %eax,0x4(%esp)
  800637:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80063e:	e8 06 29 00 00       	call   802f49 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800643:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80064a:	e8 84 fc ff ff       	call   8002d3 <diskaddr>
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 39 fc ff ff       	call   800290 <va_is_mapped>
  800657:	85 c0                	test   %eax,%eax
  800659:	74 24                	je     80067f <check_bc+0x12f>
  80065b:	c7 44 24 0c 8c 40 80 	movl   $0x80408c,0xc(%esp)
  800662:	00 
  800663:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  80066a:	00 
  80066b:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800672:	00 
  800673:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  80067a:	e8 95 17 00 00       	call   801e14 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80067f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800686:	e8 48 fc ff ff       	call   8002d3 <diskaddr>
  80068b:	c7 44 24 04 6b 40 80 	movl   $0x80406b,0x4(%esp)
  800692:	00 
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	e8 1a 22 00 00       	call   8028b5 <strcmp>
  80069b:	85 c0                	test   %eax,%eax
  80069d:	74 24                	je     8006c3 <check_bc+0x173>
  80069f:	c7 44 24 0c cc 3f 80 	movl   $0x803fcc,0xc(%esp)
  8006a6:	00 
  8006a7:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  8006ae:	00 
  8006af:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8006b6:	00 
  8006b7:	c7 04 24 f0 3f 80 00 	movl   $0x803ff0,(%esp)
  8006be:	e8 51 17 00 00       	call   801e14 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8006c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006ca:	e8 04 fc ff ff       	call   8002d3 <diskaddr>
  8006cf:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8006d6:	00 
  8006d7:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  8006dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e1:	89 04 24             	mov    %eax,(%esp)
  8006e4:	e8 fc 22 00 00       	call   8029e5 <memmove>
	flush_block(diskaddr(1));
  8006e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006f0:	e8 de fb ff ff       	call   8002d3 <diskaddr>
  8006f5:	89 04 24             	mov    %eax,(%esp)
  8006f8:	e8 59 fd ff ff       	call   800456 <flush_block>

	cprintf("block cache is good\n");
  8006fd:	c7 04 24 a7 40 80 00 	movl   $0x8040a7,(%esp)
  800704:	e8 c4 17 00 00       	call   801ecd <cprintf>
}
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <bc_init>:

void
bc_init(void)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(bc_pgfault);
  800711:	c7 04 24 19 03 80 00 	movl   $0x800319,(%esp)
  800718:	e8 a3 2a 00 00       	call   8031c0 <set_pgfault_handler>
	check_bc();
  80071d:	e8 2e fe ff ff       	call   800550 <check_bc>
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    
	...

00800730 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
	if (super == 0 || blockno >= super->s_nblocks)
  800737:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 25                	je     800766 <block_is_free+0x36>
  800741:	39 42 04             	cmp    %eax,0x4(%edx)
  800744:	76 20                	jbe    800766 <block_is_free+0x36>
  800746:	89 c1                	mov    %eax,%ecx
  800748:	83 e1 1f             	and    $0x1f,%ecx
  80074b:	ba 01 00 00 00       	mov    $0x1,%edx
  800750:	d3 e2                	shl    %cl,%edx
  800752:	c1 e8 05             	shr    $0x5,%eax
  800755:	8b 1d 04 a0 80 00    	mov    0x80a004,%ebx
  80075b:	85 14 83             	test   %edx,(%ebx,%eax,4)
  80075e:	0f 95 c0             	setne  %al
  800761:	0f b6 c0             	movzbl %al,%eax
  800764:	eb 05                	jmp    80076b <block_is_free+0x3b>
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80076b:	5b                   	pop    %ebx
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  800771:	80 38 2f             	cmpb   $0x2f,(%eax)
  800774:	75 08                	jne    80077e <skip_slash+0x10>
		p++;
  800776:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800779:	80 38 2f             	cmpb   $0x2f,(%eax)
  80077c:	74 f8                	je     800776 <skip_slash+0x8>
		p++;
	return p;
}
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <fs_sync>:
}

// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800787:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80078c:	83 78 04 01          	cmpl   $0x1,0x4(%eax)
  800790:	76 2a                	jbe    8007bc <fs_sync+0x3c>
  800792:	b8 01 00 00 00       	mov    $0x1,%eax
  800797:	bb 01 00 00 00       	mov    $0x1,%ebx
		flush_block(diskaddr(i));
  80079c:	89 04 24             	mov    %eax,(%esp)
  80079f:	e8 2f fb ff ff       	call   8002d3 <diskaddr>
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	e8 aa fc ff ff       	call   800456 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8007ac:	83 c3 01             	add    $0x1,%ebx
  8007af:	89 d8                	mov    %ebx,%eax
  8007b1:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8007b7:	39 5a 04             	cmp    %ebx,0x4(%edx)
  8007ba:	77 e0                	ja     80079c <fs_sync+0x1c>
		flush_block(diskaddr(i));
}
  8007bc:	83 c4 14             	add    $0x14,%esp
  8007bf:	5b                   	pop    %ebx
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	83 ec 10             	sub    $0x10,%esp
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
        int i;
        for(i = 2 + super->s_nblocks/BLKBITSIZE;i<super->s_nblocks;i++){
  8007ca:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007cf:	8b 70 04             	mov    0x4(%eax),%esi
  8007d2:	89 f3                	mov    %esi,%ebx
  8007d4:	c1 eb 0f             	shr    $0xf,%ebx
  8007d7:	83 c3 02             	add    $0x2,%ebx
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	39 de                	cmp    %ebx,%esi
  8007de:	76 58                	jbe    800838 <alloc_block+0x76>
           if(block_is_free(i)){
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	e8 48 ff ff ff       	call   800730 <block_is_free>
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	74 43                	je     80082f <alloc_block+0x6d>
               bitmap[i/32] &= ~(1<<(i % 32));
  8007ec:	89 d8                	mov    %ebx,%eax
  8007ee:	c1 f8 1f             	sar    $0x1f,%eax
  8007f1:	89 c6                	mov    %eax,%esi
  8007f3:	c1 ee 1b             	shr    $0x1b,%esi
  8007f6:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  8007f9:	89 ca                	mov    %ecx,%edx
  8007fb:	c1 fa 05             	sar    $0x5,%edx
  8007fe:	c1 e2 02             	shl    $0x2,%edx
  800801:	03 15 04 a0 80 00    	add    0x80a004,%edx
  800807:	83 e1 1f             	and    $0x1f,%ecx
  80080a:	29 f1                	sub    %esi,%ecx
  80080c:	be fe ff ff ff       	mov    $0xfffffffe,%esi
  800811:	d3 c6                	rol    %cl,%esi
  800813:	21 32                	and    %esi,(%edx)
               flush_block((void*)((2 + i/BLKBITSIZE)*BLKSIZE + DISKMAP));
  800815:	c1 e8 11             	shr    $0x11,%eax
  800818:	01 d8                	add    %ebx,%eax
  80081a:	c1 f8 0f             	sar    $0xf,%eax
  80081d:	05 02 00 01 00       	add    $0x10002,%eax
  800822:	c1 e0 0c             	shl    $0xc,%eax
  800825:	89 04 24             	mov    %eax,(%esp)
  800828:	e8 29 fc ff ff       	call   800456 <flush_block>
               return i;
  80082d:	eb 0e                	jmp    80083d <alloc_block+0x7b>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
        int i;
        for(i = 2 + super->s_nblocks/BLKBITSIZE;i<super->s_nblocks;i++){
  80082f:	83 c3 01             	add    $0x1,%ebx
  800832:	89 d8                	mov    %ebx,%eax
  800834:	39 de                	cmp    %ebx,%esi
  800836:	77 a8                	ja     8007e0 <alloc_block+0x1e>
  800838:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
               return i;
           }
        } 
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
}
  80083d:	89 d8                	mov    %ebx,%eax
  80083f:	83 c4 10             	add    $0x10,%esp
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <free_block>:
}

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 18             	sub    $0x18,%esp
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80084f:	85 c9                	test   %ecx,%ecx
  800851:	75 1c                	jne    80086f <free_block+0x29>
		panic("attempt to free zero block");
  800853:	c7 44 24 08 bc 40 80 	movl   $0x8040bc,0x8(%esp)
  80085a:	00 
  80085b:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800862:	00 
  800863:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  80086a:	e8 a5 15 00 00       	call   801e14 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  80086f:	89 c8                	mov    %ecx,%eax
  800871:	c1 e8 05             	shr    $0x5,%eax
  800874:	c1 e0 02             	shl    $0x2,%eax
  800877:	03 05 04 a0 80 00    	add    0x80a004,%eax
  80087d:	83 e1 1f             	and    $0x1f,%ecx
  800880:	ba 01 00 00 00       	mov    $0x1,%edx
  800885:	d3 e2                	shl    %cl,%edx
  800887:	09 10                	or     %edx,(%eax)
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	83 ec 10             	sub    $0x10,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800893:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800898:	8b 70 04             	mov    0x4(%eax),%esi
  80089b:	85 f6                	test   %esi,%esi
  80089d:	74 44                	je     8008e3 <check_bitmap+0x58>
  80089f:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(!block_is_free(2+i));
  8008a4:	8d 43 02             	lea    0x2(%ebx),%eax
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	e8 81 fe ff ff       	call   800730 <block_is_free>
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	74 24                	je     8008d7 <check_bitmap+0x4c>
  8008b3:	c7 44 24 0c df 40 80 	movl   $0x8040df,0xc(%esp)
  8008ba:	00 
  8008bb:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  8008c2:	00 
  8008c3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8008ca:	00 
  8008cb:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  8008d2:	e8 3d 15 00 00       	call   801e14 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8008d7:	83 c3 01             	add    $0x1,%ebx
  8008da:	89 d8                	mov    %ebx,%eax
  8008dc:	c1 e0 0f             	shl    $0xf,%eax
  8008df:	39 f0                	cmp    %esi,%eax
  8008e1:	72 c1                	jb     8008a4 <check_bitmap+0x19>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008ea:	e8 41 fe ff ff       	call   800730 <block_is_free>
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	74 24                	je     800917 <check_bitmap+0x8c>
  8008f3:	c7 44 24 0c f3 40 80 	movl   $0x8040f3,0xc(%esp)
  8008fa:	00 
  8008fb:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  800902:	00 
  800903:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  80090a:	00 
  80090b:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  800912:	e8 fd 14 00 00       	call   801e14 <_panic>
	assert(!block_is_free(1));
  800917:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80091e:	e8 0d fe ff ff       	call   800730 <block_is_free>
  800923:	85 c0                	test   %eax,%eax
  800925:	74 24                	je     80094b <check_bitmap+0xc0>
  800927:	c7 44 24 0c 05 41 80 	movl   $0x804105,0xc(%esp)
  80092e:	00 
  80092f:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  800936:	00 
  800937:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80093e:	00 
  80093f:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  800946:	e8 c9 14 00 00       	call   801e14 <_panic>

	cprintf("bitmap is good\n");
  80094b:	c7 04 24 17 41 80 00 	movl   $0x804117,(%esp)
  800952:	e8 76 15 00 00       	call   801ecd <cprintf>
}
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800964:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800969:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80096f:	74 1c                	je     80098d <check_super+0x2f>
		panic("bad file system magic number");
  800971:	c7 44 24 08 27 41 80 	movl   $0x804127,0x8(%esp)
  800978:	00 
  800979:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800980:	00 
  800981:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  800988:	e8 87 14 00 00       	call   801e14 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80098d:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800994:	76 1c                	jbe    8009b2 <check_super+0x54>
		panic("file system is too large");
  800996:	c7 44 24 08 44 41 80 	movl   $0x804144,0x8(%esp)
  80099d:	00 
  80099e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  8009a5:	00 
  8009a6:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  8009ad:	e8 62 14 00 00       	call   801e14 <_panic>

	cprintf("superblock is good\n");
  8009b2:	c7 04 24 5d 41 80 00 	movl   $0x80415d,(%esp)
  8009b9:	e8 0f 15 00 00       	call   801ecd <cprintf>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	83 ec 38             	sub    $0x38,%esp
  8009c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009cf:	89 c7                	mov    %eax,%edi
  8009d1:	89 d3                	mov    %edx,%ebx
  8009d3:	89 ce                	mov    %ecx,%esi
	// LAB 5: Your code here.
        if(filebno >= NDIRECT + NINDIRECT)
  8009d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009da:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8009e0:	0f 87 9e 00 00 00    	ja     800a84 <file_block_walk+0xc4>
            return -E_INVAL;
        if(filebno < NDIRECT){
  8009e6:	83 fa 09             	cmp    $0x9,%edx
  8009e9:	77 1b                	ja     800a06 <file_block_walk+0x46>
            if(ppdiskbno)
  8009eb:	85 c9                	test   %ecx,%ecx
  8009ed:	0f 84 8c 00 00 00    	je     800a7f <file_block_walk+0xbf>
               *ppdiskbno = &(f->f_direct[filebno]);
  8009f3:	8d 84 97 88 00 00 00 	lea    0x88(%edi,%edx,4),%eax
  8009fa:	89 01                	mov    %eax,(%ecx)
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	e9 7e 00 00 00       	jmp    800a84 <file_block_walk+0xc4>
            return 0;
        }
        else{
           if(!f->f_indirect){
  800a06:	83 bf b0 00 00 00 00 	cmpl   $0x0,0xb0(%edi)
  800a0d:	75 50                	jne    800a5f <file_block_walk+0x9f>
               int r;
               if(!alloc)
  800a0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a13:	75 07                	jne    800a1c <file_block_walk+0x5c>
  800a15:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800a1a:	eb 68                	jmp    800a84 <file_block_walk+0xc4>
                  return -E_NOT_FOUND;
               r = alloc_block();
  800a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a20:	e8 9d fd ff ff       	call   8007c2 <alloc_block>
  800a25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
               if(r < 0)
  800a28:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800a2d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a31:	78 51                	js     800a84 <file_block_walk+0xc4>
                  return -E_NO_DISK;
               memset((void*)(r*BLKSIZE + DISKMAP),0,BLKSIZE);
  800a33:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800a3a:	00 
  800a3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a42:	00 
  800a43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a46:	05 00 00 01 00       	add    $0x10000,%eax
  800a4b:	c1 e0 0c             	shl    $0xc,%eax
  800a4e:	89 04 24             	mov    %eax,(%esp)
  800a51:	e8 30 1f 00 00       	call   802986 <memset>
               f->f_indirect = r;
  800a56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a59:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)
           }
           if(ppdiskbno)
  800a5f:	85 f6                	test   %esi,%esi
  800a61:	74 1c                	je     800a7f <file_block_walk+0xbf>
               *ppdiskbno = ((uint32_t*)(f->f_indirect*BLKSIZE + DISKMAP)) + (filebno - NDIRECT);
  800a63:	8b 87 b0 00 00 00    	mov    0xb0(%edi),%eax
  800a69:	c1 e0 0a             	shl    $0xa,%eax
  800a6c:	8d 84 03 f6 ff ff 03 	lea    0x3fffff6(%ebx,%eax,1),%eax
  800a73:	c1 e0 02             	shl    $0x2,%eax
  800a76:	89 06                	mov    %eax,(%esi)
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7d:	eb 05                	jmp    800a84 <file_block_walk+0xc4>
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
           return 0;
        }            
	//panic("file_block_walk not implemented");
}
  800a84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a8d:	89 ec                	mov    %ebp,%esp
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	83 ec 3c             	sub    $0x3c,%esp
  800a9a:	89 c6                	mov    %eax,%esi
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800a9c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800aa2:	05 ff 0f 00 00       	add    $0xfff,%eax
  800aa7:	89 c7                	mov    %eax,%edi
  800aa9:	c1 ff 1f             	sar    $0x1f,%edi
  800aac:	c1 ef 14             	shr    $0x14,%edi
  800aaf:	01 c7                	add    %eax,%edi
  800ab1:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ab4:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800aba:	89 d0                	mov    %edx,%eax
  800abc:	c1 f8 1f             	sar    $0x1f,%eax
  800abf:	c1 e8 14             	shr    $0x14,%eax
  800ac2:	8d 14 10             	lea    (%eax,%edx,1),%edx
  800ac5:	c1 fa 0c             	sar    $0xc,%edx
  800ac8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800acb:	39 d7                	cmp    %edx,%edi
  800acd:	76 4c                	jbe    800b1b <file_truncate_blocks+0x8a>
  800acf:	89 d3                	mov    %edx,%ebx
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ad1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800adb:	89 da                	mov    %ebx,%edx
  800add:	89 f0                	mov    %esi,%eax
  800adf:	e8 dc fe ff ff       	call   8009c0 <file_block_walk>
  800ae4:	85 c0                	test   %eax,%eax
  800ae6:	78 1c                	js     800b04 <file_truncate_blocks+0x73>
		return r;
	if (*ptr) {
  800ae8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aeb:	8b 00                	mov    (%eax),%eax
  800aed:	85 c0                	test   %eax,%eax
  800aef:	74 23                	je     800b14 <file_truncate_blocks+0x83>
		free_block(*ptr);
  800af1:	89 04 24             	mov    %eax,(%esp)
  800af4:	e8 4d fd ff ff       	call   800846 <free_block>
		*ptr = 0;
  800af9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800afc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800b02:	eb 10                	jmp    800b14 <file_truncate_blocks+0x83>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b08:	c7 04 24 71 41 80 00 	movl   $0x804171,(%esp)
  800b0f:	e8 b9 13 00 00       	call   801ecd <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800b14:	83 c3 01             	add    $0x1,%ebx
  800b17:	39 df                	cmp    %ebx,%edi
  800b19:	77 b6                	ja     800ad1 <file_truncate_blocks+0x40>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800b1b:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800b1f:	77 1c                	ja     800b3d <file_truncate_blocks+0xac>
  800b21:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800b27:	85 c0                	test   %eax,%eax
  800b29:	74 12                	je     800b3d <file_truncate_blocks+0xac>
		free_block(f->f_indirect);
  800b2b:	89 04 24             	mov    %eax,(%esp)
  800b2e:	e8 13 fd ff ff       	call   800846 <free_block>
		f->f_indirect = 0;
  800b33:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800b3a:	00 00 00 
	}
}
  800b3d:	83 c4 3c             	add    $0x3c,%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <file_set_size>:

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 18             	sub    $0x18,%esp
  800b4b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b4e:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b51:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b54:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800b57:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  800b5d:	7e 09                	jle    800b68 <file_set_size+0x23>
		file_truncate_blocks(f, newsize);
  800b5f:	89 f2                	mov    %esi,%edx
  800b61:	89 d8                	mov    %ebx,%eax
  800b63:	e8 29 ff ff ff       	call   800a91 <file_truncate_blocks>
	f->f_size = newsize;
  800b68:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800b6e:	89 1c 24             	mov    %ebx,(%esp)
  800b71:	e8 e0 f8 ff ff       	call   800456 <flush_block>
	return 0;
}
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b7e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b81:	89 ec                	mov    %ebp,%esp
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 2c             	sub    $0x2c,%esp
  800b8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800b91:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800b97:	05 ff 0f 00 00       	add    $0xfff,%eax
  800b9c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800ba1:	7e 5b                	jle    800bfe <file_flush+0x79>
  800ba3:	be 00 00 00 00       	mov    $0x0,%esi
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800ba8:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800bab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bb2:	89 f9                	mov    %edi,%ecx
  800bb4:	89 f2                	mov    %esi,%edx
  800bb6:	89 d8                	mov    %ebx,%eax
  800bb8:	e8 03 fe ff ff       	call   8009c0 <file_block_walk>
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	78 1d                	js     800bde <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
  800bc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	74 16                	je     800bde <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
  800bc8:	8b 00                	mov    (%eax),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	74 10                	je     800bde <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
  800bce:	89 04 24             	mov    %eax,(%esp)
  800bd1:	e8 fd f6 ff ff       	call   8002d3 <diskaddr>
  800bd6:	89 04 24             	mov    %eax,(%esp)
  800bd9:	e8 78 f8 ff ff       	call   800456 <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800bde:	83 c6 01             	add    $0x1,%esi
  800be1:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800be7:	05 ff 0f 00 00       	add    $0xfff,%eax
  800bec:	89 c2                	mov    %eax,%edx
  800bee:	c1 fa 1f             	sar    $0x1f,%edx
  800bf1:	c1 ea 14             	shr    $0x14,%edx
  800bf4:	8d 04 02             	lea    (%edx,%eax,1),%eax
  800bf7:	c1 f8 0c             	sar    $0xc,%eax
  800bfa:	39 f0                	cmp    %esi,%eax
  800bfc:	7f ad                	jg     800bab <file_flush+0x26>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800bfe:	89 1c 24             	mov    %ebx,(%esp)
  800c01:	e8 50 f8 ff ff       	call   800456 <flush_block>
	if (f->f_indirect)
  800c06:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	74 10                	je     800c20 <file_flush+0x9b>
		flush_block(diskaddr(f->f_indirect));
  800c10:	89 04 24             	mov    %eax,(%esp)
  800c13:	e8 bb f6 ff ff       	call   8002d3 <diskaddr>
  800c18:	89 04 24             	mov    %eax,(%esp)
  800c1b:	e8 36 f8 ff ff       	call   800456 <flush_block>
}
  800c20:	83 c4 2c             	add    $0x2c,%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 48             	sub    $0x48,%esp
  800c2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c34:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c3a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 5: Your code here.
        uint32_t* pdiskbno;
        int r = file_block_walk(f,filebno,&pdiskbno,1);
  800c3d:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800c40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c47:	89 f2                	mov    %esi,%edx
  800c49:	89 f8                	mov    %edi,%eax
  800c4b:	e8 70 fd ff ff       	call   8009c0 <file_block_walk>
  800c50:	89 c3                	mov    %eax,%ebx
        if(r == 0){
  800c52:	85 c0                	test   %eax,%eax
  800c54:	0f 85 9c 00 00 00    	jne    800cf6 <file_get_block+0xce>
           if(*pdiskbno != 0){
  800c5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c5d:	8b 00                	mov    (%eax),%eax
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	74 12                	je     800c75 <file_get_block+0x4d>
              uint32_t num = *pdiskbno;
              *blk = (char*)diskaddr(num);
  800c63:	89 04 24             	mov    %eax,(%esp)
  800c66:	e8 68 f6 ff ff       	call   8002d3 <diskaddr>
  800c6b:	8b 55 10             	mov    0x10(%ebp),%edx
  800c6e:	89 02                	mov    %eax,(%edx)
              return 0;    
  800c70:	e9 81 00 00 00       	jmp    800cf6 <file_get_block+0xce>
           }
           else{
               r = alloc_block();
  800c75:	e8 48 fb ff ff       	call   8007c2 <alloc_block>
  800c7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
               if(r < 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	79 07                	jns    800c88 <file_get_block+0x60>
  800c81:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
  800c86:	eb 6e                	jmp    800cf6 <file_get_block+0xce>
                  return -E_NO_DISK;
               memset((void*)(r*BLKSIZE + DISKMAP),0,BLKSIZE);
  800c88:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800c8f:	00 
  800c90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c97:	00 
  800c98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c9b:	05 00 00 01 00       	add    $0x10000,%eax
  800ca0:	c1 e0 0c             	shl    $0xc,%eax
  800ca3:	89 04 24             	mov    %eax,(%esp)
  800ca6:	e8 db 1c 00 00       	call   802986 <memset>
               if(filebno <NDIRECT){
  800cab:	83 fe 09             	cmp    $0x9,%esi
  800cae:	77 19                	ja     800cc9 <file_get_block+0xa1>
                     f->f_direct[filebno] = r;
  800cb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800cb3:	89 84 b7 88 00 00 00 	mov    %eax,0x88(%edi,%esi,4)
                     *blk = (char*)diskaddr(r);
  800cba:	89 04 24             	mov    %eax,(%esp)
  800cbd:	e8 11 f6 ff ff       	call   8002d3 <diskaddr>
  800cc2:	8b 55 10             	mov    0x10(%ebp),%edx
  800cc5:	89 02                	mov    %eax,(%edx)
  800cc7:	eb 2d                	jmp    800cf6 <file_get_block+0xce>
               }
               else{
                     uint32_t* addr = diskaddr(f->f_indirect);
  800cc9:	8b 87 b0 00 00 00    	mov    0xb0(%edi),%eax
  800ccf:	89 04 24             	mov    %eax,(%esp)
  800cd2:	e8 fc f5 ff ff       	call   8002d3 <diskaddr>
                     addr[filebno - NDIRECT] = r;
  800cd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800cda:	89 54 b0 d8          	mov    %edx,-0x28(%eax,%esi,4)
                     flush_block(addr);
  800cde:	89 04 24             	mov    %eax,(%esp)
  800ce1:	e8 70 f7 ff ff       	call   800456 <flush_block>
                     *blk = (char*)diskaddr(r);
  800ce6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ce9:	89 04 24             	mov    %eax,(%esp)
  800cec:	e8 e2 f5 ff ff       	call   8002d3 <diskaddr>
  800cf1:	8b 55 10             	mov    0x10(%ebp),%edx
  800cf4:	89 02                	mov    %eax,(%edx)
           }          
        }
        else
            return r;
	//panic("file_get_block not implemented");
}
  800cf6:	89 d8                	mov    %ebx,%eax
  800cf8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cfb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cfe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d01:	89 ec                	mov    %ebp,%esp
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800d11:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800d17:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800d1d:	e8 4c fa ff ff       	call   80076e <skip_slash>
  800d22:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	f = &super->s_root;
  800d28:	a1 08 a0 80 00       	mov    0x80a008,%eax
	dir = 0;
	name[0] = 0;
  800d2d:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800d34:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800d3b:	74 0c                	je     800d49 <walk_path+0x44>
		*pdir = 0;
  800d3d:	8b 95 40 ff ff ff    	mov    -0xc0(%ebp),%edx
  800d43:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800d49:	83 c0 08             	add    $0x8,%eax
  800d4c:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800d52:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800d58:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  800d5e:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800d63:	e9 a0 01 00 00       	jmp    800f08 <walk_path+0x203>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800d68:	83 c6 01             	add    $0x1,%esi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800d6b:	0f b6 06             	movzbl (%esi),%eax
  800d6e:	3c 2f                	cmp    $0x2f,%al
  800d70:	74 04                	je     800d76 <walk_path+0x71>
  800d72:	84 c0                	test   %al,%al
  800d74:	75 f2                	jne    800d68 <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  800d76:	89 f3                	mov    %esi,%ebx
  800d78:	2b 9d 48 ff ff ff    	sub    -0xb8(%ebp),%ebx
  800d7e:	83 fb 7f             	cmp    $0x7f,%ebx
  800d81:	7e 0a                	jle    800d8d <walk_path+0x88>
  800d83:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d88:	e9 c2 01 00 00       	jmp    800f4f <walk_path+0x24a>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800d8d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d91:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  800d97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9b:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800da1:	89 14 24             	mov    %edx,(%esp)
  800da4:	e8 3c 1c 00 00       	call   8029e5 <memmove>
		name[path - p] = '\0';
  800da9:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800db0:	00 
		path = skip_slash(path);
  800db1:	89 f0                	mov    %esi,%eax
  800db3:	e8 b6 f9 ff ff       	call   80076e <skip_slash>
  800db8:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800dbe:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800dc4:	83 b9 84 00 00 00 01 	cmpl   $0x1,0x84(%ecx)
  800dcb:	0f 85 79 01 00 00    	jne    800f4a <walk_path+0x245>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800dd1:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
  800dd7:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800ddc:	74 24                	je     800e02 <walk_path+0xfd>
  800dde:	c7 44 24 0c 8e 41 80 	movl   $0x80418e,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  800dfd:	e8 12 10 00 00       	call   801e14 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	c1 fa 1f             	sar    $0x1f,%edx
  800e07:	c1 ea 14             	shr    $0x14,%edx
  800e0a:	8d 04 02             	lea    (%edx,%eax,1),%eax
  800e0d:	c1 f8 0c             	sar    $0xc,%eax
  800e10:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  800e16:	85 c0                	test   %eax,%eax
  800e18:	0f 84 8a 00 00 00    	je     800ea8 <walk_path+0x1a3>
  800e1e:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800e25:	00 00 00 
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800e28:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800e2e:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800e34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e38:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800e3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e42:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800e48:	89 0c 24             	mov    %ecx,(%esp)
  800e4b:	e8 d8 fd ff ff       	call   800c28 <file_get_block>
  800e50:	85 c0                	test   %eax,%eax
  800e52:	78 4b                	js     800e9f <walk_path+0x19a>
  800e54:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  800e5a:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  800e60:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	89 1c 24             	mov    %ebx,(%esp)
  800e6d:	e8 43 1a 00 00       	call   8028b5 <strcmp>
  800e72:	85 c0                	test   %eax,%eax
  800e74:	0f 84 82 00 00 00    	je     800efc <walk_path+0x1f7>
  800e7a:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800e80:	3b 9d 54 ff ff ff    	cmp    -0xac(%ebp),%ebx
  800e86:	75 de                	jne    800e66 <walk_path+0x161>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800e88:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800e8f:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800e95:	39 95 44 ff ff ff    	cmp    %edx,-0xbc(%ebp)
  800e9b:	77 91                	ja     800e2e <walk_path+0x129>
  800e9d:	eb 09                	jmp    800ea8 <walk_path+0x1a3>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800e9f:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ea2:	0f 85 a7 00 00 00    	jne    800f4f <walk_path+0x24a>
  800ea8:	8b 8d 48 ff ff ff    	mov    -0xb8(%ebp),%ecx
  800eae:	80 39 00             	cmpb   $0x0,(%ecx)
  800eb1:	0f 85 93 00 00 00    	jne    800f4a <walk_path+0x245>
				if (pdir)
  800eb7:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800ebe:	74 0e                	je     800ece <walk_path+0x1c9>
					*pdir = dir;
  800ec0:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800ec6:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800ecc:	89 10                	mov    %edx,(%eax)
				if (lastelem)
  800ece:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ed2:	74 15                	je     800ee9 <walk_path+0x1e4>
					strcpy(lastelem, name);
  800ed4:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800eda:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ede:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee1:	89 0c 24             	mov    %ecx,(%esp)
  800ee4:	e8 11 19 00 00       	call   8027fa <strcpy>
				*pf = 0;
  800ee9:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800eef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800ef5:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800efa:	eb 53                	jmp    800f4f <walk_path+0x24a>
  800efc:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800f02:	89 9d 4c ff ff ff    	mov    %ebx,-0xb4(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800f08:	8b 8d 48 ff ff ff    	mov    -0xb8(%ebp),%ecx
  800f0e:	0f b6 01             	movzbl (%ecx),%eax
  800f11:	84 c0                	test   %al,%al
  800f13:	74 0f                	je     800f24 <walk_path+0x21f>
  800f15:	89 ce                	mov    %ecx,%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800f17:	3c 2f                	cmp    $0x2f,%al
  800f19:	0f 85 49 fe ff ff    	jne    800d68 <walk_path+0x63>
  800f1f:	e9 52 fe ff ff       	jmp    800d76 <walk_path+0x71>
			}
			return r;
		}
	}

	if (pdir)
  800f24:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800f2b:	74 08                	je     800f35 <walk_path+0x230>
		*pdir = dir;
  800f2d:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800f33:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800f35:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800f3b:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
  800f41:	89 0a                	mov    %ecx,(%edx)
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  800f48:	eb 05                	jmp    800f4f <walk_path+0x24a>
  800f4a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
}
  800f4f:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <file_remove>:
}

// Remove a file by truncating it and then zeroing the name.
int
file_remove(const char *path)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
  800f60:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	e8 8e fd ff ff       	call   800d05 <walk_path>
  800f77:	85 c0                	test   %eax,%eax
  800f79:	78 30                	js     800fab <file_remove+0x51>
		return r;

	file_truncate_blocks(f, 0);
  800f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f83:	e8 09 fb ff ff       	call   800a91 <file_truncate_blocks>
	f->f_name[0] = '\0';
  800f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8b:	c6 00 00             	movb   $0x0,(%eax)
	f->f_size = 0;
  800f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f91:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  800f98:	00 00 00 
	flush_block(f);
  800f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9e:	89 04 24             	mov    %eax,(%esp)
  800fa1:	e8 b0 f4 ff ff       	call   800456 <flush_block>
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax

	return 0;
}
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800fb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc5:	e8 3b fd ff ff       	call   800d05 <walk_path>
}
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	57                   	push   %edi
  800fd0:	56                   	push   %esi
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 3c             	sub    $0x3c,%esp
  800fd5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fd8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800fdb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800fde:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe1:	01 d8                	add    %ebx,%eax
  800fe3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800fef:	77 0d                	ja     800ffe <file_write+0x32>
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800ff1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ff4:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  800ff7:	72 1d                	jb     801016 <file_write+0x4a>
  800ff9:	e9 85 00 00 00       	jmp    801083 <file_write+0xb7>
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
  800ffe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801001:	89 54 24 04          	mov    %edx,0x4(%esp)
  801005:	8b 45 08             	mov    0x8(%ebp),%eax
  801008:	89 04 24             	mov    %eax,(%esp)
  80100b:	e8 35 fb ff ff       	call   800b45 <file_set_size>
  801010:	85 c0                	test   %eax,%eax
  801012:	79 dd                	jns    800ff1 <file_write+0x25>
  801014:	eb 70                	jmp    801086 <file_write+0xba>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  801016:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801019:	89 54 24 08          	mov    %edx,0x8(%esp)
  80101d:	89 d8                	mov    %ebx,%eax
  80101f:	c1 f8 1f             	sar    $0x1f,%eax
  801022:	c1 e8 14             	shr    $0x14,%eax
  801025:	01 d8                	add    %ebx,%eax
  801027:	c1 f8 0c             	sar    $0xc,%eax
  80102a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102e:	8b 45 08             	mov    0x8(%ebp),%eax
  801031:	89 04 24             	mov    %eax,(%esp)
  801034:	e8 ef fb ff ff       	call   800c28 <file_get_block>
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 49                	js     801086 <file_write+0xba>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  80103d:	89 da                	mov    %ebx,%edx
  80103f:	c1 fa 1f             	sar    $0x1f,%edx
  801042:	c1 ea 14             	shr    $0x14,%edx
  801045:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801048:	25 ff 0f 00 00       	and    $0xfff,%eax
  80104d:	29 d0                	sub    %edx,%eax
  80104f:	be 00 10 00 00       	mov    $0x1000,%esi
  801054:	29 c6                	sub    %eax,%esi
  801056:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801059:	2b 55 d0             	sub    -0x30(%ebp),%edx
  80105c:	39 d6                	cmp    %edx,%esi
  80105e:	76 02                	jbe    801062 <file_write+0x96>
  801060:	89 d6                	mov    %edx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  801062:	89 74 24 08          	mov    %esi,0x8(%esp)
  801066:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80106a:	03 45 e4             	add    -0x1c(%ebp),%eax
  80106d:	89 04 24             	mov    %eax,(%esp)
  801070:	e8 70 19 00 00       	call   8029e5 <memmove>
		pos += bn;
  801075:	01 f3                	add    %esi,%ebx
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  801077:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80107a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  80107d:	76 04                	jbe    801083 <file_write+0xb7>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
  80107f:	01 f7                	add    %esi,%edi
  801081:	eb 93                	jmp    801016 <file_write+0x4a>
	}

	return count;
  801083:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801086:	83 c4 3c             	add    $0x3c,%esp
  801089:	5b                   	pop    %ebx
  80108a:	5e                   	pop    %esi
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	83 ec 3c             	sub    $0x3c,%esp
  801097:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80109a:	8b 55 10             	mov    0x10(%ebp),%edx
  80109d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  8010a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a3:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
  8010a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ae:	39 d9                	cmp    %ebx,%ecx
  8010b0:	0f 8e 8b 00 00 00    	jle    801141 <file_read+0xb3>
		return 0;

	count = MIN(count, f->f_size - offset);
  8010b6:	29 d9                	sub    %ebx,%ecx
  8010b8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8010bb:	39 d1                	cmp    %edx,%ecx
  8010bd:	76 03                	jbe    8010c2 <file_read+0x34>
  8010bf:	89 55 cc             	mov    %edx,-0x34(%ebp)

	for (pos = offset; pos < offset + count; ) {
  8010c2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8010c5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8010c8:	01 d8                	add    %ebx,%eax
  8010ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8010cd:	39 d8                	cmp    %ebx,%eax
  8010cf:	76 6d                	jbe    80113e <file_read+0xb0>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  8010d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d8:	89 d8                	mov    %ebx,%eax
  8010da:	c1 f8 1f             	sar    $0x1f,%eax
  8010dd:	c1 e8 14             	shr    $0x14,%eax
  8010e0:	01 d8                	add    %ebx,%eax
  8010e2:	c1 f8 0c             	sar    $0xc,%eax
  8010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	89 04 24             	mov    %eax,(%esp)
  8010ef:	e8 34 fb ff ff       	call   800c28 <file_get_block>
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 49                	js     801141 <file_read+0xb3>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  8010f8:	89 da                	mov    %ebx,%edx
  8010fa:	c1 fa 1f             	sar    $0x1f,%edx
  8010fd:	c1 ea 14             	shr    $0x14,%edx
  801100:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801103:	25 ff 0f 00 00       	and    $0xfff,%eax
  801108:	29 d0                	sub    %edx,%eax
  80110a:	be 00 10 00 00       	mov    $0x1000,%esi
  80110f:	29 c6                	sub    %eax,%esi
  801111:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801114:	2b 55 d0             	sub    -0x30(%ebp),%edx
  801117:	39 d6                	cmp    %edx,%esi
  801119:	76 02                	jbe    80111d <file_read+0x8f>
  80111b:	89 d6                	mov    %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  80111d:	89 74 24 08          	mov    %esi,0x8(%esp)
  801121:	03 45 e4             	add    -0x1c(%ebp),%eax
  801124:	89 44 24 04          	mov    %eax,0x4(%esp)
  801128:	89 3c 24             	mov    %edi,(%esp)
  80112b:	e8 b5 18 00 00       	call   8029e5 <memmove>
		pos += bn;
  801130:	01 f3                	add    %esi,%ebx
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  801132:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801135:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  801138:	76 04                	jbe    80113e <file_read+0xb0>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
  80113a:	01 f7                	add    %esi,%edi
  80113c:	eb 93                	jmp    8010d1 <file_read+0x43>
	}

	return count;
  80113e:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
  801141:	83 c4 3c             	add    $0x3c,%esp
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801155:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  80115b:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801161:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801167:	89 04 24             	mov    %eax,(%esp)
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	e8 93 fb ff ff       	call   800d05 <walk_path>
  801172:	85 c0                	test   %eax,%eax
  801174:	75 0a                	jne    801180 <file_create+0x37>
  801176:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80117b:	e9 ed 00 00 00       	jmp    80126d <file_create+0x124>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801180:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801183:	0f 85 e4 00 00 00    	jne    80126d <file_create+0x124>
  801189:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  80118f:	85 f6                	test   %esi,%esi
  801191:	0f 84 d6 00 00 00    	je     80126d <file_create+0x124>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801197:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  80119d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8011a2:	74 24                	je     8011c8 <file_create+0x7f>
  8011a4:	c7 44 24 0c 8e 41 80 	movl   $0x80418e,0xc(%esp)
  8011ab:	00 
  8011ac:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  8011b3:	00 
  8011b4:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  8011bb:	00 
  8011bc:	c7 04 24 d7 40 80 00 	movl   $0x8040d7,(%esp)
  8011c3:	e8 4c 0c 00 00       	call   801e14 <_panic>
	nblock = dir->f_size / BLKSIZE;
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	c1 fa 1f             	sar    $0x1f,%edx
  8011cd:	c1 ea 14             	shr    $0x14,%edx
  8011d0:	8d 04 02             	lea    (%edx,%eax,1),%eax
  8011d3:	c1 f8 0c             	sar    $0xc,%eax
  8011d6:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  8011dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	74 56                	je     80123b <file_create+0xf2>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8011e5:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8011eb:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011f3:	89 34 24             	mov    %esi,(%esp)
  8011f6:	e8 2d fa ff ff       	call   800c28 <file_get_block>
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 6e                	js     80126d <file_create+0x124>
			return r;
		f = (struct File*) blk;
  8011ff:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  801205:	89 ca                	mov    %ecx,%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  801207:	80 39 00             	cmpb   $0x0,(%ecx)
  80120a:	74 13                	je     80121f <file_create+0xd6>
  80120c:	8d 81 00 01 00 00    	lea    0x100(%ecx),%eax
// --------------------------------------------------------------

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
  801212:	81 c1 00 10 00 00    	add    $0x1000,%ecx
  801218:	89 c2                	mov    %eax,%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  80121a:	80 38 00             	cmpb   $0x0,(%eax)
  80121d:	75 08                	jne    801227 <file_create+0xde>
				*file = &f[j];
  80121f:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
  801225:	eb 51                	jmp    801278 <file_create+0x12f>
  801227:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  80122c:	39 c8                	cmp    %ecx,%eax
  80122e:	75 e8                	jne    801218 <file_create+0xcf>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  801230:	83 c3 01             	add    $0x1,%ebx
  801233:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  801239:	77 b0                	ja     8011eb <file_create+0xa2>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  80123b:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  801242:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801245:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  80124b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80124f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801253:	89 34 24             	mov    %esi,(%esp)
  801256:	e8 cd f9 ff ff       	call   800c28 <file_get_block>
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 0e                	js     80126d <file_create+0x124>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  80125f:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801265:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80126b:	eb 0b                	jmp    801278 <file_create+0x12f>
		return r;
	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  80126d:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;
	strcpy(f->f_name, name);
  801278:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80127e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801282:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801288:	89 04 24             	mov    %eax,(%esp)
  80128b:	e8 6a 15 00 00       	call   8027fa <strcpy>
	*pf = f;
  801290:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801296:	8b 45 0c             	mov    0xc(%ebp),%eax
  801299:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80129b:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8012a1:	89 04 24             	mov    %eax,(%esp)
  8012a4:	e8 dc f8 ff ff       	call   800b85 <file_flush>
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8012ae:	eb bd                	jmp    80126d <file_create+0x124>

008012b0 <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  8012b6:	e8 69 ef ff ff       	call   800224 <ide_probe_disk1>
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	74 0e                	je     8012cd <fs_init+0x1d>
		ide_set_disk(1);
  8012bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8012c6:	e8 28 ef ff ff       	call   8001f3 <ide_set_disk>
  8012cb:	eb 0c                	jmp    8012d9 <fs_init+0x29>
	else
		ide_set_disk(0);
  8012cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d4:	e8 1a ef ff ff       	call   8001f3 <ide_set_disk>

	bc_init();
  8012d9:	e8 2d f4 ff ff       	call   80070b <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  8012de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8012e5:	e8 e9 ef ff ff       	call   8002d3 <diskaddr>
  8012ea:	a3 08 a0 80 00       	mov    %eax,0x80a008
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8012ef:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8012f6:	e8 d8 ef ff ff       	call   8002d3 <diskaddr>
  8012fb:	a3 04 a0 80 00       	mov    %eax,0x80a004

	check_super();
  801300:	e8 59 f6 ff ff       	call   80095e <check_super>
	check_bitmap();
  801305:	e8 81 f5 ff ff       	call   80088b <check_bitmap>
}
  80130a:	c9                   	leave  
  80130b:	c3                   	ret    
  80130c:	00 00                	add    %al,(%eax)
	...

00801310 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	ba 20 50 80 00       	mov    $0x805020,%edx
  801318:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
		opentab[i].o_fileid = i;
  801322:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801324:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801327:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  80132d:	83 c0 01             	add    $0x1,%eax
  801330:	83 c2 10             	add    $0x10,%edx
  801333:	3d 00 04 00 00       	cmp    $0x400,%eax
  801338:	75 e8                	jne    801322 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <serve_sync>:
}

// Sync the file system.
int
serve_sync(envid_t envid, union Fsipc *req)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801342:	e8 39 f4 ff ff       	call   800780 <fs_sync>
	return 0;
}
  801347:	b8 00 00 00 00       	mov    $0x0,%eax
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <serve_remove>:
}

// Remove the file req->req_path.
int
serve_remove(envid_t envid, struct Fsreq_remove *req)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	53                   	push   %ebx
  801352:	81 ec 14 04 00 00    	sub    $0x414,%esp

	// Delete the named file.
	// Note: This request doesn't refer to an open file.

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801358:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  80135f:	00 
  801360:	8b 45 0c             	mov    0xc(%ebp),%eax
  801363:	89 44 24 04          	mov    %eax,0x4(%esp)
  801367:	8d 9d f8 fb ff ff    	lea    -0x408(%ebp),%ebx
  80136d:	89 1c 24             	mov    %ebx,(%esp)
  801370:	e8 70 16 00 00       	call   8029e5 <memmove>
	path[MAXPATHLEN-1] = 0;
  801375:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Delete the specified file
	return file_remove(path);
  801379:	89 1c 24             	mov    %ebx,(%esp)
  80137c:	e8 d9 fb ff ff       	call   800f5a <file_remove>
}
  801381:	81 c4 14 04 00 00    	add    $0x414,%esp
  801387:	5b                   	pop    %ebx
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <openfile_lookup>:
}

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	83 ec 18             	sub    $0x18,%esp
  801390:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801393:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801396:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801399:	89 f3                	mov    %esi,%ebx
  80139b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8013a1:	c1 e3 04             	shl    $0x4,%ebx
  8013a4:	81 c3 20 50 80 00    	add    $0x805020,%ebx
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  8013aa:	8b 43 0c             	mov    0xc(%ebx),%eax
  8013ad:	89 04 24             	mov    %eax,(%esp)
  8013b0:	e8 8f 28 00 00       	call   803c44 <pageref>
  8013b5:	83 f8 01             	cmp    $0x1,%eax
  8013b8:	74 10                	je     8013ca <openfile_lookup+0x40>
  8013ba:	39 33                	cmp    %esi,(%ebx)
  8013bc:	75 0c                	jne    8013ca <openfile_lookup+0x40>
		return -E_INVAL;
	*po = o;
  8013be:	8b 45 10             	mov    0x10(%ebp),%eax
  8013c1:	89 18                	mov    %ebx,(%eax)
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8013c8:	eb 05                	jmp    8013cf <openfile_lookup+0x45>
  8013ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013d2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8013d5:	89 ec                	mov    %ebp,%esp
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e9:	8b 00                	mov    (%eax),%eax
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	89 04 24             	mov    %eax,(%esp)
  8013f5:	e8 90 ff ff ff       	call   80138a <openfile_lookup>
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 13                	js     801411 <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  8013fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801401:	8b 40 04             	mov    0x4(%eax),%eax
  801404:	89 04 24             	mov    %eax,(%esp)
  801407:	e8 79 f7 ff ff       	call   800b85 <file_flush>
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	53                   	push   %ebx
  801417:	83 ec 24             	sub    $0x24,%esp
  80141a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80141d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801420:	89 44 24 08          	mov    %eax,0x8(%esp)
  801424:	8b 03                	mov    (%ebx),%eax
  801426:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142a:	8b 45 08             	mov    0x8(%ebp),%eax
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	e8 55 ff ff ff       	call   80138a <openfile_lookup>
  801435:	85 c0                	test   %eax,%eax
  801437:	78 3f                	js     801478 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801439:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143c:	8b 40 04             	mov    0x4(%eax),%eax
  80143f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801443:	89 1c 24             	mov    %ebx,(%esp)
  801446:	e8 af 13 00 00       	call   8027fa <strcpy>
	ret->ret_size = o->o_file->f_size;
  80144b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144e:	8b 50 04             	mov    0x4(%eax),%edx
  801451:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801457:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80145d:	8b 40 04             	mov    0x4(%eax),%eax
  801460:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801467:	0f 94 c0             	sete   %al
  80146a:	0f b6 c0             	movzbl %al,%eax
  80146d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801478:	83 c4 24             	add    $0x24,%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5d                   	pop    %ebp
  80147d:	c3                   	ret    

0080147e <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
  801483:	83 ec 20             	sub    $0x20,%esp
  801486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
        int fileid = req->req_fileid;
        int n = req->req_n;
  801489:	8b 73 04             	mov    0x4(%ebx),%esi
        struct OpenFile* o;
        int r = openfile_lookup(envid,fileid,&o);
  80148c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801493:	8b 03                	mov    (%ebx),%eax
  801495:	89 44 24 04          	mov    %eax,0x4(%esp)
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	89 04 24             	mov    %eax,(%esp)
  80149f:	e8 e6 fe ff ff       	call   80138a <openfile_lookup>
        if(r < 0)
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 41                	js     8014e9 <serve_write+0x6b>
           return r;
        n = n < PGSIZE? n:PGSIZE;
        ssize_t count = file_write(o->o_file,req->req_buf,n,o->o_fd->fd_offset);
  8014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ab:	8b 50 0c             	mov    0xc(%eax),%edx
  8014ae:	8b 52 04             	mov    0x4(%edx),%edx
  8014b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014b5:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
  8014bb:	7e 05                	jle    8014c2 <serve_write+0x44>
  8014bd:	be 00 10 00 00       	mov    $0x1000,%esi
  8014c2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8014c6:	83 c3 08             	add    $0x8,%ebx
  8014c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014cd:	8b 40 04             	mov    0x4(%eax),%eax
  8014d0:	89 04 24             	mov    %eax,(%esp)
  8014d3:	e8 f4 fa ff ff       	call   800fcc <file_write>
  8014d8:	89 c2                	mov    %eax,%edx
        if(count < 0)
  8014da:	85 d2                	test   %edx,%edx
  8014dc:	78 0b                	js     8014e9 <serve_write+0x6b>
           return count;
        o->o_fd->fd_offset += count;
  8014de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e4:	01 50 04             	add    %edx,0x4(%eax)
  8014e7:	89 d0                	mov    %edx,%eax
        return count;
	//panic("serve_write not implemented");
}
  8014e9:	83 c4 20             	add    $0x20,%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	56                   	push   %esi
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 20             	sub    $0x20,%esp
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//
	// Hint: Use file_read.
	// Hint: The seek position is stored in the struct Fd.
	// LAB 5: Your code here
        int fileid = req->req_fileid;
        int n = req->req_n;
  8014fb:	8b 73 04             	mov    0x4(%ebx),%esi
        struct OpenFile* o;
        int r = openfile_lookup(envid,fileid,&o);
  8014fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801501:	89 44 24 08          	mov    %eax,0x8(%esp)
  801505:	8b 03                	mov    (%ebx),%eax
  801507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	e8 74 fe ff ff       	call   80138a <openfile_lookup>
        if(r < 0)
  801516:	85 c0                	test   %eax,%eax
  801518:	78 3e                	js     801558 <serve_read+0x68>
            return r;
        n = n < PGSIZE ? n :PGSIZE;
        ssize_t count = file_read(o->o_file,ret->ret_buf,n,o->o_fd->fd_offset);
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	8b 50 0c             	mov    0xc(%eax),%edx
  801520:	8b 52 04             	mov    0x4(%edx),%edx
  801523:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801527:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
  80152d:	7e 05                	jle    801534 <serve_read+0x44>
  80152f:	be 00 10 00 00       	mov    $0x1000,%esi
  801534:	89 74 24 08          	mov    %esi,0x8(%esp)
  801538:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80153c:	8b 40 04             	mov    0x4(%eax),%eax
  80153f:	89 04 24             	mov    %eax,(%esp)
  801542:	e8 47 fb ff ff       	call   80108e <file_read>
  801547:	89 c2                	mov    %eax,%edx
        if(count < 0)
  801549:	85 d2                	test   %edx,%edx
  80154b:	78 0b                	js     801558 <serve_read+0x68>
           return count;
        o->o_fd->fd_offset += count;
  80154d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801550:	8b 40 0c             	mov    0xc(%eax),%eax
  801553:	01 50 04             	add    %edx,0x4(%eax)
  801556:	89 d0                	mov    %edx,%eax
        return count;
	//panic("serve_read not implemented");
}
  801558:	83 c4 20             	add    $0x20,%esp
  80155b:	5b                   	pop    %ebx
  80155c:	5e                   	pop    %esi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	53                   	push   %ebx
  801563:	83 ec 24             	sub    $0x24,%esp
  801566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801570:	8b 03                	mov    (%ebx),%eax
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	8b 45 08             	mov    0x8(%ebp),%eax
  801579:	89 04 24             	mov    %eax,(%esp)
  80157c:	e8 09 fe ff ff       	call   80138a <openfile_lookup>
  801581:	85 c0                	test   %eax,%eax
  801583:	78 15                	js     80159a <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801585:	8b 43 04             	mov    0x4(%ebx),%eax
  801588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158f:	8b 40 04             	mov    0x4(%eax),%eax
  801592:	89 04 24             	mov    %eax,(%esp)
  801595:	e8 ab f5 ff ff       	call   800b45 <file_set_size>
}
  80159a:	83 c4 24             	add    $0x24,%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    

008015a0 <openfile_alloc>:
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	83 ec 28             	sub    $0x28,%esp
  8015a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  8015b7:	be 2c 50 80 00       	mov    $0x80502c,%esi
  8015bc:	89 d8                	mov    %ebx,%eax
  8015be:	c1 e0 04             	shl    $0x4,%eax
  8015c1:	8b 04 06             	mov    (%esi,%eax,1),%eax
  8015c4:	89 04 24             	mov    %eax,(%esp)
  8015c7:	e8 78 26 00 00       	call   803c44 <pageref>
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	74 0a                	je     8015da <openfile_alloc+0x3a>
  8015d0:	83 f8 01             	cmp    $0x1,%eax
  8015d3:	75 65                	jne    80163a <openfile_alloc+0x9a>
  8015d5:	8d 76 00             	lea    0x0(%esi),%esi
  8015d8:	eb 27                	jmp    801601 <openfile_alloc+0x61>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8015da:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015e1:	00 
  8015e2:	89 d8                	mov    %ebx,%eax
  8015e4:	c1 e0 04             	shl    $0x4,%eax
  8015e7:	8b 80 2c 50 80 00    	mov    0x80502c(%eax),%eax
  8015ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f8:	e8 26 1a 00 00       	call   803023 <sys_page_alloc>
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 4d                	js     80164e <openfile_alloc+0xae>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801601:	c1 e3 04             	shl    $0x4,%ebx
  801604:	81 83 20 50 80 00 00 	addl   $0x400,0x805020(%ebx)
  80160b:	04 00 00 
			*o = &opentab[i];
  80160e:	8d 83 20 50 80 00    	lea    0x805020(%ebx),%eax
  801614:	89 07                	mov    %eax,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801616:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80161d:	00 
  80161e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801625:	00 
  801626:	8b 83 2c 50 80 00    	mov    0x80502c(%ebx),%eax
  80162c:	89 04 24             	mov    %eax,(%esp)
  80162f:	e8 52 13 00 00       	call   802986 <memset>
			return (*o)->o_fileid;
  801634:	8b 07                	mov    (%edi),%eax
  801636:	8b 00                	mov    (%eax),%eax
  801638:	eb 14                	jmp    80164e <openfile_alloc+0xae>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80163a:	83 c3 01             	add    $0x1,%ebx
  80163d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801643:	0f 85 73 ff ff ff    	jne    8015bc <openfile_alloc+0x1c>
  801649:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
}
  80164e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801651:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801654:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801657:	89 ec                	mov    %ebp,%esp
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    

0080165b <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	53                   	push   %ebx
  80165f:	81 ec 24 04 00 00    	sub    $0x424,%esp
  801665:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801668:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  80166f:	00 
  801670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801674:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80167a:	89 04 24             	mov    %eax,(%esp)
  80167d:	e8 63 13 00 00       	call   8029e5 <memmove>
	path[MAXPATHLEN-1] = 0;
  801682:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801686:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 0c ff ff ff       	call   8015a0 <openfile_alloc>
  801694:	85 c0                	test   %eax,%eax
  801696:	0f 88 ec 00 00 00    	js     801788 <serve_open+0x12d>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  80169c:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8016a3:	74 32                	je     8016d7 <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  8016a5:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8016ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016af:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016b5:	89 04 24             	mov    %eax,(%esp)
  8016b8:	e8 8c fa ff ff       	call   801149 <file_create>
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	79 36                	jns    8016f7 <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8016c1:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8016c8:	0f 85 ba 00 00 00    	jne    801788 <serve_open+0x12d>
  8016ce:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8016d1:	0f 85 b1 00 00 00    	jne    801788 <serve_open+0x12d>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8016d7:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8016dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e1:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016e7:	89 04 24             	mov    %eax,(%esp)
  8016ea:	e8 be f8 ff ff       	call   800fad <file_open>
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	0f 88 91 00 00 00    	js     801788 <serve_open+0x12d>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8016f7:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8016fe:	74 1a                	je     80171a <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  801700:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801707:	00 
  801708:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	e8 2f f4 ff ff       	call   800b45 <file_set_size>
  801716:	85 c0                	test   %eax,%eax
  801718:	78 6e                	js     801788 <serve_open+0x12d>
			return r;
		}
	}

	// Save the file pointer
	o->o_file = f;
  80171a:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801720:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801726:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801729:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80172f:	8b 50 0c             	mov    0xc(%eax),%edx
  801732:	8b 00                	mov    (%eax),%eax
  801734:	89 42 0c             	mov    %eax,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801737:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80173d:	8b 40 0c             	mov    0xc(%eax),%eax
  801740:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801746:	83 e2 03             	and    $0x3,%edx
  801749:	89 50 08             	mov    %edx,0x8(%eax)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80174c:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801752:	8b 40 0c             	mov    0xc(%eax),%eax
  801755:	8b 15 68 90 80 00    	mov    0x809068,%edx
  80175b:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80175d:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801763:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801769:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller
	*pg_store = o->o_fd;
  80176c:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801772:	8b 50 0c             	mov    0xc(%eax),%edx
  801775:	8b 45 10             	mov    0x10(%ebp),%eax
  801778:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W;
  80177a:	8b 45 14             	mov    0x14(%ebp),%eax
  80177d:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801788:	81 c4 24 04 00 00    	add    $0x424,%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	57                   	push   %edi
  801795:	56                   	push   %esi
  801796:	53                   	push   %ebx
  801797:	83 ec 2c             	sub    $0x2c,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80179a:	8d 5d e0             	lea    -0x20(%ebp),%ebx
  80179d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < NHANDLERS && handlers[req]) {
  8017a0:	bf 40 90 80 00       	mov    $0x809040,%edi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8017a5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8017ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017b0:	a1 20 90 80 00       	mov    0x809020,%eax
  8017b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b9:	89 34 24             	mov    %esi,(%esp)
  8017bc:	e8 48 1b 00 00       	call   803309 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  8017c1:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
  8017c5:	75 15                	jne    8017dc <serve+0x4b>
			cprintf("Invalid request from %08x: no argument page\n",
  8017c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ce:	c7 04 24 ac 41 80 00 	movl   $0x8041ac,(%esp)
  8017d5:	e8 f3 06 00 00       	call   801ecd <cprintf>
				whom);
			continue; // just leave it hanging...
  8017da:	eb c9                	jmp    8017a5 <serve+0x14>
		}

		pg = NULL;
  8017dc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		if (req == FSREQ_OPEN) {
  8017e3:	83 f8 01             	cmp    $0x1,%eax
  8017e6:	75 21                	jne    801809 <serve+0x78>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8017e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8017ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f3:	a1 20 90 80 00       	mov    0x809020,%eax
  8017f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ff:	89 04 24             	mov    %eax,(%esp)
  801802:	e8 54 fe ff ff       	call   80165b <serve_open>
  801807:	eb 3b                	jmp    801844 <serve+0xb3>
		} else if (req < NHANDLERS && handlers[req]) {
  801809:	83 f8 08             	cmp    $0x8,%eax
  80180c:	77 1a                	ja     801828 <serve+0x97>
  80180e:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801811:	85 d2                	test   %edx,%edx
  801813:	74 13                	je     801828 <serve+0x97>
			r = handlers[req](whom, fsreq);
  801815:	a1 20 90 80 00       	mov    0x809020,%eax
  80181a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801821:	89 04 24             	mov    %eax,(%esp)
  801824:	ff d2                	call   *%edx
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < NHANDLERS && handlers[req]) {
  801826:	eb 1c                	jmp    801844 <serve+0xb3>
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  801828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80182c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	c7 04 24 dc 41 80 00 	movl   $0x8041dc,(%esp)
  80183a:	e8 8e 06 00 00       	call   801ecd <cprintf>
  80183f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
  801844:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801847:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80184b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80184e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801852:	89 44 24 04          	mov    %eax,0x4(%esp)
  801856:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801859:	89 04 24             	mov    %eax,(%esp)
  80185c:	e8 2a 1a 00 00       	call   80328b <ipc_send>
		sys_page_unmap(0, fsreq);
  801861:	a1 20 90 80 00       	mov    0x809020,%eax
  801866:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801871:	e8 d3 16 00 00       	call   802f49 <sys_page_unmap>
  801876:	e9 2a ff ff ff       	jmp    8017a5 <serve+0x14>

0080187b <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801881:	c7 05 64 90 80 00 ff 	movl   $0x8041ff,0x809064
  801888:	41 80 00 
	cprintf("FS is running\n");
  80188b:	c7 04 24 02 42 80 00 	movl   $0x804202,(%esp)
  801892:	e8 36 06 00 00       	call   801ecd <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801897:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80189c:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8018a1:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8018a3:	c7 04 24 11 42 80 00 	movl   $0x804211,(%esp)
  8018aa:	e8 1e 06 00 00       	call   801ecd <cprintf>

	serve_init();
  8018af:	e8 5c fa ff ff       	call   801310 <serve_init>
	fs_init();
  8018b4:	e8 f7 f9 ff ff       	call   8012b0 <fs_init>
	fs_test();
  8018b9:	e8 0a 00 00 00       	call   8018c8 <fs_test>
	serve();
  8018be:	66 90                	xchg   %ax,%ax
  8018c0:	e8 cc fe ff ff       	call   801791 <serve>
}
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    
	...

008018c8 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8018cf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018d6:	00 
  8018d7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  8018de:	00 
  8018df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e6:	e8 38 17 00 00       	call   803023 <sys_page_alloc>
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	79 20                	jns    80190f <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  8018ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018f3:	c7 44 24 08 f8 3f 80 	movl   $0x803ff8,0x8(%esp)
  8018fa:	00 
  8018fb:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  801902:	00 
  801903:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  80190a:	e8 05 05 00 00       	call   801e14 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80190f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801916:	00 
  801917:	a1 04 a0 80 00       	mov    0x80a004,%eax
  80191c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801920:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  801927:	e8 b9 10 00 00       	call   8029e5 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80192c:	e8 91 ee ff ff       	call   8007c2 <alloc_block>
  801931:	85 c0                	test   %eax,%eax
  801933:	79 20                	jns    801955 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801935:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801939:	c7 44 24 08 2a 42 80 	movl   $0x80422a,0x8(%esp)
  801940:	00 
  801941:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  801948:	00 
  801949:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801950:	e8 bf 04 00 00       	call   801e14 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801955:	89 c3                	mov    %eax,%ebx
  801957:	c1 fb 1f             	sar    $0x1f,%ebx
  80195a:	c1 eb 1b             	shr    $0x1b,%ebx
  80195d:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801960:	89 c2                	mov    %eax,%edx
  801962:	c1 fa 05             	sar    $0x5,%edx
  801965:	c1 e2 02             	shl    $0x2,%edx
  801968:	89 c1                	mov    %eax,%ecx
  80196a:	83 e1 1f             	and    $0x1f,%ecx
  80196d:	29 d9                	sub    %ebx,%ecx
  80196f:	b8 01 00 00 00       	mov    $0x1,%eax
  801974:	d3 e0                	shl    %cl,%eax
  801976:	85 82 00 10 00 00    	test   %eax,0x1000(%edx)
  80197c:	75 24                	jne    8019a2 <fs_test+0xda>
  80197e:	c7 44 24 0c 3a 42 80 	movl   $0x80423a,0xc(%esp)
  801985:	00 
  801986:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  80198d:	00 
  80198e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801995:	00 
  801996:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  80199d:	e8 72 04 00 00       	call   801e14 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8019a2:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8019a8:	85 04 11             	test   %eax,(%ecx,%edx,1)
  8019ab:	74 24                	je     8019d1 <fs_test+0x109>
  8019ad:	c7 44 24 0c b0 43 80 	movl   $0x8043b0,0xc(%esp)
  8019b4:	00 
  8019b5:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  8019bc:	00 
  8019bd:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8019c4:	00 
  8019c5:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  8019cc:	e8 43 04 00 00       	call   801e14 <_panic>
	cprintf("alloc_block is good\n");
  8019d1:	c7 04 24 55 42 80 00 	movl   $0x804255,(%esp)
  8019d8:	e8 f0 04 00 00       	call   801ecd <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8019dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e4:	c7 04 24 6a 42 80 00 	movl   $0x80426a,(%esp)
  8019eb:	e8 bd f5 ff ff       	call   800fad <file_open>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	79 25                	jns    801a19 <fs_test+0x151>
  8019f4:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8019f7:	74 40                	je     801a39 <fs_test+0x171>
		panic("file_open /not-found: %e", r);
  8019f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019fd:	c7 44 24 08 75 42 80 	movl   $0x804275,0x8(%esp)
  801a04:	00 
  801a05:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801a0c:	00 
  801a0d:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801a14:	e8 fb 03 00 00       	call   801e14 <_panic>
	else if (r == 0)
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	75 1c                	jne    801a39 <fs_test+0x171>
		panic("file_open /not-found succeeded!");
  801a1d:	c7 44 24 08 d0 43 80 	movl   $0x8043d0,0x8(%esp)
  801a24:	00 
  801a25:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801a2c:	00 
  801a2d:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801a34:	e8 db 03 00 00       	call   801e14 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801a39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a40:	c7 04 24 8e 42 80 00 	movl   $0x80428e,(%esp)
  801a47:	e8 61 f5 ff ff       	call   800fad <file_open>
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	79 20                	jns    801a70 <fs_test+0x1a8>
		panic("file_open /newmotd: %e", r);
  801a50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a54:	c7 44 24 08 97 42 80 	movl   $0x804297,0x8(%esp)
  801a5b:	00 
  801a5c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801a63:	00 
  801a64:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801a6b:	e8 a4 03 00 00       	call   801e14 <_panic>
	cprintf("file_open is good\n");
  801a70:	c7 04 24 ae 42 80 00 	movl   $0x8042ae,(%esp)
  801a77:	e8 51 04 00 00       	call   801ecd <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a83:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a8a:	00 
  801a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8e:	89 04 24             	mov    %eax,(%esp)
  801a91:	e8 92 f1 ff ff       	call   800c28 <file_get_block>
  801a96:	85 c0                	test   %eax,%eax
  801a98:	79 20                	jns    801aba <fs_test+0x1f2>
		panic("file_get_block: %e", r);
  801a9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a9e:	c7 44 24 08 c1 42 80 	movl   $0x8042c1,0x8(%esp)
  801aa5:	00 
  801aa6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801aad:	00 
  801aae:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801ab5:	e8 5a 03 00 00       	call   801e14 <_panic>
	if (strcmp(blk, msg) != 0)
  801aba:	8b 1d 3c 44 80 00    	mov    0x80443c,%ebx
  801ac0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac7:	89 04 24             	mov    %eax,(%esp)
  801aca:	e8 e6 0d 00 00       	call   8028b5 <strcmp>
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	74 1c                	je     801aef <fs_test+0x227>
		panic("file_get_block returned wrong data");
  801ad3:	c7 44 24 08 f0 43 80 	movl   $0x8043f0,0x8(%esp)
  801ada:	00 
  801adb:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801ae2:	00 
  801ae3:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801aea:	e8 25 03 00 00       	call   801e14 <_panic>
	cprintf("file_get_block is good\n");
  801aef:	c7 04 24 d4 42 80 00 	movl   $0x8042d4,(%esp)
  801af6:	e8 d2 03 00 00       	call   801ecd <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afe:	0f b6 10             	movzbl (%eax),%edx
  801b01:	88 10                	mov    %dl,(%eax)
	assert((vpt[PGNUM(blk)] & PTE_D));
  801b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b06:	c1 e8 0c             	shr    $0xc,%eax
  801b09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b10:	a8 40                	test   $0x40,%al
  801b12:	75 24                	jne    801b38 <fs_test+0x270>
  801b14:	c7 44 24 0c ed 42 80 	movl   $0x8042ed,0xc(%esp)
  801b1b:	00 
  801b1c:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  801b23:	00 
  801b24:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801b2b:	00 
  801b2c:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801b33:	e8 dc 02 00 00       	call   801e14 <_panic>
	file_flush(f);
  801b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3b:	89 04 24             	mov    %eax,(%esp)
  801b3e:	e8 42 f0 ff ff       	call   800b85 <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  801b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b46:	c1 e8 0c             	shr    $0xc,%eax
  801b49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b50:	a8 40                	test   $0x40,%al
  801b52:	74 24                	je     801b78 <fs_test+0x2b0>
  801b54:	c7 44 24 0c ec 42 80 	movl   $0x8042ec,0xc(%esp)
  801b5b:	00 
  801b5c:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  801b63:	00 
  801b64:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801b6b:	00 
  801b6c:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801b73:	e8 9c 02 00 00       	call   801e14 <_panic>
	cprintf("file_flush is good\n");
  801b78:	c7 04 24 07 43 80 00 	movl   $0x804307,(%esp)
  801b7f:	e8 49 03 00 00       	call   801ecd <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801b84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b8b:	00 
  801b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8f:	89 04 24             	mov    %eax,(%esp)
  801b92:	e8 ae ef ff ff       	call   800b45 <file_set_size>
  801b97:	85 c0                	test   %eax,%eax
  801b99:	79 20                	jns    801bbb <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  801b9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b9f:	c7 44 24 08 1b 43 80 	movl   $0x80431b,0x8(%esp)
  801ba6:	00 
  801ba7:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801bae:	00 
  801baf:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801bb6:	e8 59 02 00 00       	call   801e14 <_panic>
	assert(f->f_direct[0] == 0);
  801bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbe:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801bc5:	74 24                	je     801beb <fs_test+0x323>
  801bc7:	c7 44 24 0c 2d 43 80 	movl   $0x80432d,0xc(%esp)
  801bce:	00 
  801bcf:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  801bd6:	00 
  801bd7:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801bde:	00 
  801bdf:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801be6:	e8 29 02 00 00       	call   801e14 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  801beb:	c1 e8 0c             	shr    $0xc,%eax
  801bee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bf5:	a8 40                	test   $0x40,%al
  801bf7:	74 24                	je     801c1d <fs_test+0x355>
  801bf9:	c7 44 24 0c 41 43 80 	movl   $0x804341,0xc(%esp)
  801c00:	00 
  801c01:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  801c08:	00 
  801c09:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801c10:	00 
  801c11:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801c18:	e8 f7 01 00 00       	call   801e14 <_panic>
	cprintf("file_truncate is good\n");
  801c1d:	c7 04 24 5a 43 80 00 	movl   $0x80435a,(%esp)
  801c24:	e8 a4 02 00 00       	call   801ecd <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801c29:	89 1c 24             	mov    %ebx,(%esp)
  801c2c:	e8 7f 0b 00 00       	call   8027b0 <strlen>
  801c31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	89 04 24             	mov    %eax,(%esp)
  801c3b:	e8 05 ef ff ff       	call   800b45 <file_set_size>
  801c40:	85 c0                	test   %eax,%eax
  801c42:	79 20                	jns    801c64 <fs_test+0x39c>
		panic("file_set_size 2: %e", r);
  801c44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c48:	c7 44 24 08 71 43 80 	movl   $0x804371,0x8(%esp)
  801c4f:	00 
  801c50:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801c57:	00 
  801c58:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801c5f:	e8 b0 01 00 00       	call   801e14 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  801c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c67:	89 c2                	mov    %eax,%edx
  801c69:	c1 ea 0c             	shr    $0xc,%edx
  801c6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c73:	f6 c2 40             	test   $0x40,%dl
  801c76:	74 24                	je     801c9c <fs_test+0x3d4>
  801c78:	c7 44 24 0c 41 43 80 	movl   $0x804341,0xc(%esp)
  801c7f:	00 
  801c80:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  801c87:	00 
  801c88:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  801c8f:	00 
  801c90:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801c97:	e8 78 01 00 00       	call   801e14 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801c9c:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801c9f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ca3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801caa:	00 
  801cab:	89 04 24             	mov    %eax,(%esp)
  801cae:	e8 75 ef ff ff       	call   800c28 <file_get_block>
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	79 20                	jns    801cd7 <fs_test+0x40f>
		panic("file_get_block 2: %e", r);
  801cb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cbb:	c7 44 24 08 85 43 80 	movl   $0x804385,0x8(%esp)
  801cc2:	00 
  801cc3:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  801cca:	00 
  801ccb:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801cd2:	e8 3d 01 00 00       	call   801e14 <_panic>
	strcpy(blk, msg);
  801cd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 14 0b 00 00       	call   8027fa <strcpy>
	assert((vpt[PGNUM(blk)] & PTE_D));
  801ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce9:	c1 e8 0c             	shr    $0xc,%eax
  801cec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cf3:	a8 40                	test   $0x40,%al
  801cf5:	75 24                	jne    801d1b <fs_test+0x453>
  801cf7:	c7 44 24 0c ed 42 80 	movl   $0x8042ed,0xc(%esp)
  801cfe:	00 
  801cff:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  801d06:	00 
  801d07:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801d0e:	00 
  801d0f:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801d16:	e8 f9 00 00 00       	call   801e14 <_panic>
	file_flush(f);
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 5f ee ff ff       	call   800b85 <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  801d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d29:	c1 e8 0c             	shr    $0xc,%eax
  801d2c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d33:	a8 40                	test   $0x40,%al
  801d35:	74 24                	je     801d5b <fs_test+0x493>
  801d37:	c7 44 24 0c ec 42 80 	movl   $0x8042ec,0xc(%esp)
  801d3e:	00 
  801d3f:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  801d46:	00 
  801d47:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801d4e:	00 
  801d4f:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801d56:	e8 b9 00 00 00       	call   801e14 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  801d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5e:	c1 e8 0c             	shr    $0xc,%eax
  801d61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d68:	a8 40                	test   $0x40,%al
  801d6a:	74 24                	je     801d90 <fs_test+0x4c8>
  801d6c:	c7 44 24 0c 41 43 80 	movl   $0x804341,0xc(%esp)
  801d73:	00 
  801d74:	c7 44 24 08 0d 3f 80 	movl   $0x803f0d,0x8(%esp)
  801d7b:	00 
  801d7c:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  801d83:	00 
  801d84:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801d8b:	e8 84 00 00 00       	call   801e14 <_panic>
	cprintf("file rewrite is good\n");
  801d90:	c7 04 24 9a 43 80 00 	movl   $0x80439a,(%esp)
  801d97:	e8 31 01 00 00       	call   801ecd <cprintf>
}
  801d9c:	83 c4 24             	add    $0x24,%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    
	...

00801da4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 18             	sub    $0x18,%esp
  801daa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801db0:	8b 75 08             	mov    0x8(%ebp),%esi
  801db3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  801db6:	e8 57 13 00 00       	call   803112 <sys_getenvid>
  801dbb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801dc0:	89 c2                	mov    %eax,%edx
  801dc2:	c1 e2 07             	shl    $0x7,%edx
  801dc5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801dcc:	a3 0c a0 80 00       	mov    %eax,0x80a00c
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801dd1:	85 f6                	test   %esi,%esi
  801dd3:	7e 07                	jle    801ddc <libmain+0x38>
		binaryname = argv[0];
  801dd5:	8b 03                	mov    (%ebx),%eax
  801dd7:	a3 64 90 80 00       	mov    %eax,0x809064

	// call user main routine
	umain(argc, argv);
  801ddc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801de0:	89 34 24             	mov    %esi,(%esp)
  801de3:	e8 93 fa ff ff       	call   80187b <umain>

	// exit gracefully
	exit();
  801de8:	e8 0b 00 00 00       	call   801df8 <exit>
}
  801ded:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801df0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801df3:	89 ec                	mov    %ebp,%esp
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    
	...

00801df8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801dfe:	e8 58 1a 00 00       	call   80385b <close_all>
	sys_env_destroy(0);
  801e03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0a:	e8 43 13 00 00       	call   803152 <sys_env_destroy>
}
  801e0f:	c9                   	leave  
  801e10:	c3                   	ret    
  801e11:	00 00                	add    %al,(%eax)
	...

00801e14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	56                   	push   %esi
  801e18:	53                   	push   %ebx
  801e19:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801e1c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e1f:	8b 1d 64 90 80 00    	mov    0x809064,%ebx
  801e25:	e8 e8 12 00 00       	call   803112 <sys_getenvid>
  801e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e31:	8b 55 08             	mov    0x8(%ebp),%edx
  801e34:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e38:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e40:	c7 04 24 4c 44 80 00 	movl   $0x80444c,(%esp)
  801e47:	e8 81 00 00 00       	call   801ecd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e50:	8b 45 10             	mov    0x10(%ebp),%eax
  801e53:	89 04 24             	mov    %eax,(%esp)
  801e56:	e8 11 00 00 00       	call   801e6c <vcprintf>
	cprintf("\n");
  801e5b:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  801e62:	e8 66 00 00 00       	call   801ecd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e67:	cc                   	int3   
  801e68:	eb fd                	jmp    801e67 <_panic+0x53>
	...

00801e6c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801e75:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801e7c:	00 00 00 
	b.cnt = 0;
  801e7f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801e86:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e97:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801e9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea1:	c7 04 24 e7 1e 80 00 	movl   $0x801ee7,(%esp)
  801ea8:	e8 cf 01 00 00       	call   80207c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801ead:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801ebd:	89 04 24             	mov    %eax,(%esp)
  801ec0:	e8 67 0d 00 00       	call   802c2c <sys_cputs>

	return b.cnt;
}
  801ec5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801ecb:	c9                   	leave  
  801ecc:	c3                   	ret    

00801ecd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801ed3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	89 04 24             	mov    %eax,(%esp)
  801ee0:	e8 87 ff ff ff       	call   801e6c <vcprintf>
	va_end(ap);

	return cnt;
}
  801ee5:	c9                   	leave  
  801ee6:	c3                   	ret    

00801ee7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	53                   	push   %ebx
  801eeb:	83 ec 14             	sub    $0x14,%esp
  801eee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801ef1:	8b 03                	mov    (%ebx),%eax
  801ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ef6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801efa:	83 c0 01             	add    $0x1,%eax
  801efd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801eff:	3d ff 00 00 00       	cmp    $0xff,%eax
  801f04:	75 19                	jne    801f1f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801f06:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801f0d:	00 
  801f0e:	8d 43 08             	lea    0x8(%ebx),%eax
  801f11:	89 04 24             	mov    %eax,(%esp)
  801f14:	e8 13 0d 00 00       	call   802c2c <sys_cputs>
		b->idx = 0;
  801f19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801f1f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801f23:	83 c4 14             	add    $0x14,%esp
  801f26:	5b                   	pop    %ebx
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    
  801f29:	00 00                	add    %al,(%eax)
  801f2b:	00 00                	add    %al,(%eax)
  801f2d:	00 00                	add    %al,(%eax)
	...

00801f30 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	57                   	push   %edi
  801f34:	56                   	push   %esi
  801f35:	53                   	push   %ebx
  801f36:	83 ec 4c             	sub    $0x4c,%esp
  801f39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f3c:	89 d6                	mov    %edx,%esi
  801f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f41:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f47:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801f50:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  801f53:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801f56:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f5b:	39 d1                	cmp    %edx,%ecx
  801f5d:	72 07                	jb     801f66 <printnum_v2+0x36>
  801f5f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f62:	39 d0                	cmp    %edx,%eax
  801f64:	77 5f                	ja     801fc5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801f66:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801f6a:	83 eb 01             	sub    $0x1,%ebx
  801f6d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f79:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  801f7d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801f80:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801f83:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801f86:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f91:	00 
  801f92:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801f9b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f9f:	e8 ec 1c 00 00       	call   803c90 <__udivdi3>
  801fa4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801fa7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801faa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801fb2:	89 04 24             	mov    %eax,(%esp)
  801fb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fb9:	89 f2                	mov    %esi,%edx
  801fbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fbe:	e8 6d ff ff ff       	call   801f30 <printnum_v2>
  801fc3:	eb 1e                	jmp    801fe3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801fc5:	83 ff 2d             	cmp    $0x2d,%edi
  801fc8:	74 19                	je     801fe3 <printnum_v2+0xb3>
		while (--width > 0)
  801fca:	83 eb 01             	sub    $0x1,%ebx
  801fcd:	85 db                	test   %ebx,%ebx
  801fcf:	90                   	nop
  801fd0:	7e 11                	jle    801fe3 <printnum_v2+0xb3>
			putch(padc, putdat);
  801fd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fd6:	89 3c 24             	mov    %edi,(%esp)
  801fd9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  801fdc:	83 eb 01             	sub    $0x1,%ebx
  801fdf:	85 db                	test   %ebx,%ebx
  801fe1:	7f ef                	jg     801fd2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801fe3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe7:	8b 74 24 04          	mov    0x4(%esp),%esi
  801feb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801fee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ff2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ff9:	00 
  801ffa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801ffd:	89 14 24             	mov    %edx,(%esp)
  802000:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802003:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802007:	e8 b4 1d 00 00       	call   803dc0 <__umoddi3>
  80200c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802010:	0f be 80 6f 44 80 00 	movsbl 0x80446f(%eax),%eax
  802017:	89 04 24             	mov    %eax,(%esp)
  80201a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80201d:	83 c4 4c             	add    $0x4c,%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    

00802025 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  802028:	83 fa 01             	cmp    $0x1,%edx
  80202b:	7e 0e                	jle    80203b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80202d:	8b 10                	mov    (%eax),%edx
  80202f:	8d 4a 08             	lea    0x8(%edx),%ecx
  802032:	89 08                	mov    %ecx,(%eax)
  802034:	8b 02                	mov    (%edx),%eax
  802036:	8b 52 04             	mov    0x4(%edx),%edx
  802039:	eb 22                	jmp    80205d <getuint+0x38>
	else if (lflag)
  80203b:	85 d2                	test   %edx,%edx
  80203d:	74 10                	je     80204f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80203f:	8b 10                	mov    (%eax),%edx
  802041:	8d 4a 04             	lea    0x4(%edx),%ecx
  802044:	89 08                	mov    %ecx,(%eax)
  802046:	8b 02                	mov    (%edx),%eax
  802048:	ba 00 00 00 00       	mov    $0x0,%edx
  80204d:	eb 0e                	jmp    80205d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80204f:	8b 10                	mov    (%eax),%edx
  802051:	8d 4a 04             	lea    0x4(%edx),%ecx
  802054:	89 08                	mov    %ecx,(%eax)
  802056:	8b 02                	mov    (%edx),%eax
  802058:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80205d:	5d                   	pop    %ebp
  80205e:	c3                   	ret    

0080205f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  802065:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  802069:	8b 10                	mov    (%eax),%edx
  80206b:	3b 50 04             	cmp    0x4(%eax),%edx
  80206e:	73 0a                	jae    80207a <sprintputch+0x1b>
		*b->buf++ = ch;
  802070:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802073:	88 0a                	mov    %cl,(%edx)
  802075:	83 c2 01             	add    $0x1,%edx
  802078:	89 10                	mov    %edx,(%eax)
}
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    

0080207c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	57                   	push   %edi
  802080:	56                   	push   %esi
  802081:	53                   	push   %ebx
  802082:	83 ec 6c             	sub    $0x6c,%esp
  802085:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  802088:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80208f:	eb 1a                	jmp    8020ab <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  802091:	85 c0                	test   %eax,%eax
  802093:	0f 84 66 06 00 00    	je     8026ff <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  802099:	8b 55 0c             	mov    0xc(%ebp),%edx
  80209c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020a0:	89 04 24             	mov    %eax,(%esp)
  8020a3:	ff 55 08             	call   *0x8(%ebp)
  8020a6:	eb 03                	jmp    8020ab <vprintfmt+0x2f>
  8020a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8020ab:	0f b6 07             	movzbl (%edi),%eax
  8020ae:	83 c7 01             	add    $0x1,%edi
  8020b1:	83 f8 25             	cmp    $0x25,%eax
  8020b4:	75 db                	jne    802091 <vprintfmt+0x15>
  8020b6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8020ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020bf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8020c6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8020cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8020d2:	be 00 00 00 00       	mov    $0x0,%esi
  8020d7:	eb 06                	jmp    8020df <vprintfmt+0x63>
  8020d9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8020dd:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020df:	0f b6 17             	movzbl (%edi),%edx
  8020e2:	0f b6 c2             	movzbl %dl,%eax
  8020e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020e8:	8d 47 01             	lea    0x1(%edi),%eax
  8020eb:	83 ea 23             	sub    $0x23,%edx
  8020ee:	80 fa 55             	cmp    $0x55,%dl
  8020f1:	0f 87 60 05 00 00    	ja     802657 <vprintfmt+0x5db>
  8020f7:	0f b6 d2             	movzbl %dl,%edx
  8020fa:	ff 24 95 40 46 80 00 	jmp    *0x804640(,%edx,4)
  802101:	b9 01 00 00 00       	mov    $0x1,%ecx
  802106:	eb d5                	jmp    8020dd <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  802108:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80210b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80210e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  802111:	8d 7a d0             	lea    -0x30(%edx),%edi
  802114:	83 ff 09             	cmp    $0x9,%edi
  802117:	76 08                	jbe    802121 <vprintfmt+0xa5>
  802119:	eb 40                	jmp    80215b <vprintfmt+0xdf>
  80211b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80211f:	eb bc                	jmp    8020dd <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  802121:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  802124:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  802127:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80212b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80212e:	8d 7a d0             	lea    -0x30(%edx),%edi
  802131:	83 ff 09             	cmp    $0x9,%edi
  802134:	76 eb                	jbe    802121 <vprintfmt+0xa5>
  802136:	eb 23                	jmp    80215b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  802138:	8b 55 14             	mov    0x14(%ebp),%edx
  80213b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80213e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  802141:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  802143:	eb 16                	jmp    80215b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  802145:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802148:	c1 fa 1f             	sar    $0x1f,%edx
  80214b:	f7 d2                	not    %edx
  80214d:	21 55 d8             	and    %edx,-0x28(%ebp)
  802150:	eb 8b                	jmp    8020dd <vprintfmt+0x61>
  802152:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  802159:	eb 82                	jmp    8020dd <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80215b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80215f:	0f 89 78 ff ff ff    	jns    8020dd <vprintfmt+0x61>
  802165:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  802168:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80216b:	e9 6d ff ff ff       	jmp    8020dd <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  802170:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  802173:	e9 65 ff ff ff       	jmp    8020dd <vprintfmt+0x61>
  802178:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80217b:	8b 45 14             	mov    0x14(%ebp),%eax
  80217e:	8d 50 04             	lea    0x4(%eax),%edx
  802181:	89 55 14             	mov    %edx,0x14(%ebp)
  802184:	8b 55 0c             	mov    0xc(%ebp),%edx
  802187:	89 54 24 04          	mov    %edx,0x4(%esp)
  80218b:	8b 00                	mov    (%eax),%eax
  80218d:	89 04 24             	mov    %eax,(%esp)
  802190:	ff 55 08             	call   *0x8(%ebp)
  802193:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  802196:	e9 10 ff ff ff       	jmp    8020ab <vprintfmt+0x2f>
  80219b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80219e:	8b 45 14             	mov    0x14(%ebp),%eax
  8021a1:	8d 50 04             	lea    0x4(%eax),%edx
  8021a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8021a7:	8b 00                	mov    (%eax),%eax
  8021a9:	89 c2                	mov    %eax,%edx
  8021ab:	c1 fa 1f             	sar    $0x1f,%edx
  8021ae:	31 d0                	xor    %edx,%eax
  8021b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8021b2:	83 f8 0f             	cmp    $0xf,%eax
  8021b5:	7f 0b                	jg     8021c2 <vprintfmt+0x146>
  8021b7:	8b 14 85 a0 47 80 00 	mov    0x8047a0(,%eax,4),%edx
  8021be:	85 d2                	test   %edx,%edx
  8021c0:	75 26                	jne    8021e8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8021c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021c6:	c7 44 24 08 80 44 80 	movl   $0x804480,0x8(%esp)
  8021cd:	00 
  8021ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8021d8:	89 1c 24             	mov    %ebx,(%esp)
  8021db:	e8 a7 05 00 00       	call   802787 <printfmt>
  8021e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8021e3:	e9 c3 fe ff ff       	jmp    8020ab <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8021e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021ec:	c7 44 24 08 1f 3f 80 	movl   $0x803f1f,0x8(%esp)
  8021f3:	00 
  8021f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8021fe:	89 14 24             	mov    %edx,(%esp)
  802201:	e8 81 05 00 00       	call   802787 <printfmt>
  802206:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802209:	e9 9d fe ff ff       	jmp    8020ab <vprintfmt+0x2f>
  80220e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802211:	89 c7                	mov    %eax,%edi
  802213:	89 d9                	mov    %ebx,%ecx
  802215:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802218:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80221b:	8b 45 14             	mov    0x14(%ebp),%eax
  80221e:	8d 50 04             	lea    0x4(%eax),%edx
  802221:	89 55 14             	mov    %edx,0x14(%ebp)
  802224:	8b 30                	mov    (%eax),%esi
  802226:	85 f6                	test   %esi,%esi
  802228:	75 05                	jne    80222f <vprintfmt+0x1b3>
  80222a:	be 89 44 80 00       	mov    $0x804489,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80222f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  802233:	7e 06                	jle    80223b <vprintfmt+0x1bf>
  802235:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  802239:	75 10                	jne    80224b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80223b:	0f be 06             	movsbl (%esi),%eax
  80223e:	85 c0                	test   %eax,%eax
  802240:	0f 85 a2 00 00 00    	jne    8022e8 <vprintfmt+0x26c>
  802246:	e9 92 00 00 00       	jmp    8022dd <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80224b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80224f:	89 34 24             	mov    %esi,(%esp)
  802252:	e8 74 05 00 00       	call   8027cb <strnlen>
  802257:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80225a:	29 c2                	sub    %eax,%edx
  80225c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80225f:	85 d2                	test   %edx,%edx
  802261:	7e d8                	jle    80223b <vprintfmt+0x1bf>
					putch(padc, putdat);
  802263:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  802267:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80226a:	89 d3                	mov    %edx,%ebx
  80226c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80226f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  802272:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802275:	89 ce                	mov    %ecx,%esi
  802277:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80227b:	89 34 24             	mov    %esi,(%esp)
  80227e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802281:	83 eb 01             	sub    $0x1,%ebx
  802284:	85 db                	test   %ebx,%ebx
  802286:	7f ef                	jg     802277 <vprintfmt+0x1fb>
  802288:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80228b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80228e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  802291:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  802298:	eb a1                	jmp    80223b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80229a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80229e:	74 1b                	je     8022bb <vprintfmt+0x23f>
  8022a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8022a3:	83 fa 5e             	cmp    $0x5e,%edx
  8022a6:	76 13                	jbe    8022bb <vprintfmt+0x23f>
					putch('?', putdat);
  8022a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022af:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8022b6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8022b9:	eb 0d                	jmp    8022c8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8022bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c2:	89 04 24             	mov    %eax,(%esp)
  8022c5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8022c8:	83 ef 01             	sub    $0x1,%edi
  8022cb:	0f be 06             	movsbl (%esi),%eax
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	74 05                	je     8022d7 <vprintfmt+0x25b>
  8022d2:	83 c6 01             	add    $0x1,%esi
  8022d5:	eb 1a                	jmp    8022f1 <vprintfmt+0x275>
  8022d7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8022da:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8022dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8022e1:	7f 1f                	jg     802302 <vprintfmt+0x286>
  8022e3:	e9 c0 fd ff ff       	jmp    8020a8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8022e8:	83 c6 01             	add    $0x1,%esi
  8022eb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8022ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8022f1:	85 db                	test   %ebx,%ebx
  8022f3:	78 a5                	js     80229a <vprintfmt+0x21e>
  8022f5:	83 eb 01             	sub    $0x1,%ebx
  8022f8:	79 a0                	jns    80229a <vprintfmt+0x21e>
  8022fa:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8022fd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  802300:	eb db                	jmp    8022dd <vprintfmt+0x261>
  802302:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  802305:	8b 75 0c             	mov    0xc(%ebp),%esi
  802308:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80230b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80230e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802312:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802319:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80231b:	83 eb 01             	sub    $0x1,%ebx
  80231e:	85 db                	test   %ebx,%ebx
  802320:	7f ec                	jg     80230e <vprintfmt+0x292>
  802322:	8b 7d d8             	mov    -0x28(%ebp),%edi
  802325:	e9 81 fd ff ff       	jmp    8020ab <vprintfmt+0x2f>
  80232a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80232d:	83 fe 01             	cmp    $0x1,%esi
  802330:	7e 10                	jle    802342 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  802332:	8b 45 14             	mov    0x14(%ebp),%eax
  802335:	8d 50 08             	lea    0x8(%eax),%edx
  802338:	89 55 14             	mov    %edx,0x14(%ebp)
  80233b:	8b 18                	mov    (%eax),%ebx
  80233d:	8b 70 04             	mov    0x4(%eax),%esi
  802340:	eb 26                	jmp    802368 <vprintfmt+0x2ec>
	else if (lflag)
  802342:	85 f6                	test   %esi,%esi
  802344:	74 12                	je     802358 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  802346:	8b 45 14             	mov    0x14(%ebp),%eax
  802349:	8d 50 04             	lea    0x4(%eax),%edx
  80234c:	89 55 14             	mov    %edx,0x14(%ebp)
  80234f:	8b 18                	mov    (%eax),%ebx
  802351:	89 de                	mov    %ebx,%esi
  802353:	c1 fe 1f             	sar    $0x1f,%esi
  802356:	eb 10                	jmp    802368 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  802358:	8b 45 14             	mov    0x14(%ebp),%eax
  80235b:	8d 50 04             	lea    0x4(%eax),%edx
  80235e:	89 55 14             	mov    %edx,0x14(%ebp)
  802361:	8b 18                	mov    (%eax),%ebx
  802363:	89 de                	mov    %ebx,%esi
  802365:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  802368:	83 f9 01             	cmp    $0x1,%ecx
  80236b:	75 1e                	jne    80238b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80236d:	85 f6                	test   %esi,%esi
  80236f:	78 1a                	js     80238b <vprintfmt+0x30f>
  802371:	85 f6                	test   %esi,%esi
  802373:	7f 05                	jg     80237a <vprintfmt+0x2fe>
  802375:	83 fb 00             	cmp    $0x0,%ebx
  802378:	76 11                	jbe    80238b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80237a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80237d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802381:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  802388:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80238b:	85 f6                	test   %esi,%esi
  80238d:	78 13                	js     8023a2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80238f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  802392:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  802395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802398:	b8 0a 00 00 00       	mov    $0xa,%eax
  80239d:	e9 da 00 00 00       	jmp    80247c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8023a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8023b0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8023b3:	89 da                	mov    %ebx,%edx
  8023b5:	89 f1                	mov    %esi,%ecx
  8023b7:	f7 da                	neg    %edx
  8023b9:	83 d1 00             	adc    $0x0,%ecx
  8023bc:	f7 d9                	neg    %ecx
  8023be:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8023c1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8023c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8023c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8023cc:	e9 ab 00 00 00       	jmp    80247c <vprintfmt+0x400>
  8023d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8023d4:	89 f2                	mov    %esi,%edx
  8023d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8023d9:	e8 47 fc ff ff       	call   802025 <getuint>
  8023de:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8023e1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8023e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8023e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8023ec:	e9 8b 00 00 00       	jmp    80247c <vprintfmt+0x400>
  8023f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8023f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023fb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802402:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  802405:	89 f2                	mov    %esi,%edx
  802407:	8d 45 14             	lea    0x14(%ebp),%eax
  80240a:	e8 16 fc ff ff       	call   802025 <getuint>
  80240f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  802412:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  802415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802418:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80241d:	eb 5d                	jmp    80247c <vprintfmt+0x400>
  80241f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  802422:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802425:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802429:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802430:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  802433:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802437:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80243e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  802441:	8b 45 14             	mov    0x14(%ebp),%eax
  802444:	8d 50 04             	lea    0x4(%eax),%edx
  802447:	89 55 14             	mov    %edx,0x14(%ebp)
  80244a:	8b 10                	mov    (%eax),%edx
  80244c:	b9 00 00 00 00       	mov    $0x0,%ecx
  802451:	89 55 b0             	mov    %edx,-0x50(%ebp)
  802454:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  802457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80245a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80245f:	eb 1b                	jmp    80247c <vprintfmt+0x400>
  802461:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802464:	89 f2                	mov    %esi,%edx
  802466:	8d 45 14             	lea    0x14(%ebp),%eax
  802469:	e8 b7 fb ff ff       	call   802025 <getuint>
  80246e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  802471:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  802474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802477:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80247c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  802480:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  802483:	89 45 cc             	mov    %eax,-0x34(%ebp)
  802486:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80248a:	77 09                	ja     802495 <vprintfmt+0x419>
  80248c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80248f:	0f 82 ac 00 00 00    	jb     802541 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  802495:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  802498:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80249c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80249f:	83 ea 01             	sub    $0x1,%edx
  8024a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024aa:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024ae:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024b2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8024b5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8024b8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8024bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8024c6:	00 
  8024c7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8024ca:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8024cd:	89 0c 24             	mov    %ecx,(%esp)
  8024d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024d4:	e8 b7 17 00 00       	call   803c90 <__udivdi3>
  8024d9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8024dc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8024df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8024e7:	89 04 24             	mov    %eax,(%esp)
  8024ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f4:	e8 37 fa ff ff       	call   801f30 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8024f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8024fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802500:	8b 74 24 04          	mov    0x4(%esp),%esi
  802504:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802507:	89 44 24 08          	mov    %eax,0x8(%esp)
  80250b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802512:	00 
  802513:	8b 55 b0             	mov    -0x50(%ebp),%edx
  802516:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  802519:	89 14 24             	mov    %edx,(%esp)
  80251c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802520:	e8 9b 18 00 00       	call   803dc0 <__umoddi3>
  802525:	89 74 24 04          	mov    %esi,0x4(%esp)
  802529:	0f be 80 6f 44 80 00 	movsbl 0x80446f(%eax),%eax
  802530:	89 04 24             	mov    %eax,(%esp)
  802533:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  802536:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80253a:	74 54                	je     802590 <vprintfmt+0x514>
  80253c:	e9 67 fb ff ff       	jmp    8020a8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  802541:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  802545:	8d 76 00             	lea    0x0(%esi),%esi
  802548:	0f 84 2a 01 00 00    	je     802678 <vprintfmt+0x5fc>
		while (--width > 0)
  80254e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  802551:	83 ef 01             	sub    $0x1,%edi
  802554:	85 ff                	test   %edi,%edi
  802556:	0f 8e 5e 01 00 00    	jle    8026ba <vprintfmt+0x63e>
  80255c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80255f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  802562:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  802565:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  802568:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80256b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80256e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802572:	89 1c 24             	mov    %ebx,(%esp)
  802575:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  802578:	83 ef 01             	sub    $0x1,%edi
  80257b:	85 ff                	test   %edi,%edi
  80257d:	7f ef                	jg     80256e <vprintfmt+0x4f2>
  80257f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802582:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802585:	89 45 b0             	mov    %eax,-0x50(%ebp)
  802588:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80258b:	e9 2a 01 00 00       	jmp    8026ba <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  802590:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  802593:	83 eb 01             	sub    $0x1,%ebx
  802596:	85 db                	test   %ebx,%ebx
  802598:	0f 8e 0a fb ff ff    	jle    8020a8 <vprintfmt+0x2c>
  80259e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025a1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8025a4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8025a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8025b2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8025b4:	83 eb 01             	sub    $0x1,%ebx
  8025b7:	85 db                	test   %ebx,%ebx
  8025b9:	7f ec                	jg     8025a7 <vprintfmt+0x52b>
  8025bb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8025be:	e9 e8 fa ff ff       	jmp    8020ab <vprintfmt+0x2f>
  8025c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8025c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8025c9:	8d 50 04             	lea    0x4(%eax),%edx
  8025cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8025cf:	8b 00                	mov    (%eax),%eax
  8025d1:	85 c0                	test   %eax,%eax
  8025d3:	75 2a                	jne    8025ff <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8025d5:	c7 44 24 0c a4 45 80 	movl   $0x8045a4,0xc(%esp)
  8025dc:	00 
  8025dd:	c7 44 24 08 1f 3f 80 	movl   $0x803f1f,0x8(%esp)
  8025e4:	00 
  8025e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025ef:	89 0c 24             	mov    %ecx,(%esp)
  8025f2:	e8 90 01 00 00       	call   802787 <printfmt>
  8025f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8025fa:	e9 ac fa ff ff       	jmp    8020ab <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8025ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802602:	8b 13                	mov    (%ebx),%edx
  802604:	83 fa 7f             	cmp    $0x7f,%edx
  802607:	7e 29                	jle    802632 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  802609:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80260b:	c7 44 24 0c dc 45 80 	movl   $0x8045dc,0xc(%esp)
  802612:	00 
  802613:	c7 44 24 08 1f 3f 80 	movl   $0x803f1f,0x8(%esp)
  80261a:	00 
  80261b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80261f:	8b 45 08             	mov    0x8(%ebp),%eax
  802622:	89 04 24             	mov    %eax,(%esp)
  802625:	e8 5d 01 00 00       	call   802787 <printfmt>
  80262a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80262d:	e9 79 fa ff ff       	jmp    8020ab <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  802632:	88 10                	mov    %dl,(%eax)
  802634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802637:	e9 6f fa ff ff       	jmp    8020ab <vprintfmt+0x2f>
  80263c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80263f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  802642:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802645:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802649:	89 14 24             	mov    %edx,(%esp)
  80264c:	ff 55 08             	call   *0x8(%ebp)
  80264f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  802652:	e9 54 fa ff ff       	jmp    8020ab <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802657:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80265a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80265e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802665:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  802668:	8d 47 ff             	lea    -0x1(%edi),%eax
  80266b:	80 38 25             	cmpb   $0x25,(%eax)
  80266e:	0f 84 37 fa ff ff    	je     8020ab <vprintfmt+0x2f>
  802674:	89 c7                	mov    %eax,%edi
  802676:	eb f0                	jmp    802668 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  802678:	8b 45 0c             	mov    0xc(%ebp),%eax
  80267b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80267f:	8b 74 24 04          	mov    0x4(%esp),%esi
  802683:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802686:	89 54 24 08          	mov    %edx,0x8(%esp)
  80268a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802691:	00 
  802692:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802695:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  802698:	89 04 24             	mov    %eax,(%esp)
  80269b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80269f:	e8 1c 17 00 00       	call   803dc0 <__umoddi3>
  8026a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a8:	0f be 80 6f 44 80 00 	movsbl 0x80446f(%eax),%eax
  8026af:	89 04 24             	mov    %eax,(%esp)
  8026b2:	ff 55 08             	call   *0x8(%ebp)
  8026b5:	e9 d6 fe ff ff       	jmp    802590 <vprintfmt+0x514>
  8026ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026c1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026c5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8026c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8026d3:	00 
  8026d4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8026d7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8026da:	89 04 24             	mov    %eax,(%esp)
  8026dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026e1:	e8 da 16 00 00       	call   803dc0 <__umoddi3>
  8026e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ea:	0f be 80 6f 44 80 00 	movsbl 0x80446f(%eax),%eax
  8026f1:	89 04 24             	mov    %eax,(%esp)
  8026f4:	ff 55 08             	call   *0x8(%ebp)
  8026f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8026fa:	e9 ac f9 ff ff       	jmp    8020ab <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8026ff:	83 c4 6c             	add    $0x6c,%esp
  802702:	5b                   	pop    %ebx
  802703:	5e                   	pop    %esi
  802704:	5f                   	pop    %edi
  802705:	5d                   	pop    %ebp
  802706:	c3                   	ret    

00802707 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802707:	55                   	push   %ebp
  802708:	89 e5                	mov    %esp,%ebp
  80270a:	83 ec 28             	sub    $0x28,%esp
  80270d:	8b 45 08             	mov    0x8(%ebp),%eax
  802710:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  802713:	85 c0                	test   %eax,%eax
  802715:	74 04                	je     80271b <vsnprintf+0x14>
  802717:	85 d2                	test   %edx,%edx
  802719:	7f 07                	jg     802722 <vsnprintf+0x1b>
  80271b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802720:	eb 3b                	jmp    80275d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  802722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802725:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  802729:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80272c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802733:	8b 45 14             	mov    0x14(%ebp),%eax
  802736:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80273a:	8b 45 10             	mov    0x10(%ebp),%eax
  80273d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802744:	89 44 24 04          	mov    %eax,0x4(%esp)
  802748:	c7 04 24 5f 20 80 00 	movl   $0x80205f,(%esp)
  80274f:	e8 28 f9 ff ff       	call   80207c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802754:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802757:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80275a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80275d:	c9                   	leave  
  80275e:	c3                   	ret    

0080275f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80275f:	55                   	push   %ebp
  802760:	89 e5                	mov    %esp,%ebp
  802762:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  802765:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  802768:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80276c:	8b 45 10             	mov    0x10(%ebp),%eax
  80276f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802773:	8b 45 0c             	mov    0xc(%ebp),%eax
  802776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80277a:	8b 45 08             	mov    0x8(%ebp),%eax
  80277d:	89 04 24             	mov    %eax,(%esp)
  802780:	e8 82 ff ff ff       	call   802707 <vsnprintf>
	va_end(ap);

	return rc;
}
  802785:	c9                   	leave  
  802786:	c3                   	ret    

00802787 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  802787:	55                   	push   %ebp
  802788:	89 e5                	mov    %esp,%ebp
  80278a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80278d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  802790:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802794:	8b 45 10             	mov    0x10(%ebp),%eax
  802797:	89 44 24 08          	mov    %eax,0x8(%esp)
  80279b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80279e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a5:	89 04 24             	mov    %eax,(%esp)
  8027a8:	e8 cf f8 ff ff       	call   80207c <vprintfmt>
	va_end(ap);
}
  8027ad:	c9                   	leave  
  8027ae:	c3                   	ret    
	...

008027b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8027b0:	55                   	push   %ebp
  8027b1:	89 e5                	mov    %esp,%ebp
  8027b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8027b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8027bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8027be:	74 09                	je     8027c9 <strlen+0x19>
		n++;
  8027c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8027c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8027c7:	75 f7                	jne    8027c0 <strlen+0x10>
		n++;
	return n;
}
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    

008027cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8027cb:	55                   	push   %ebp
  8027cc:	89 e5                	mov    %esp,%ebp
  8027ce:	53                   	push   %ebx
  8027cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8027d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8027d5:	85 c9                	test   %ecx,%ecx
  8027d7:	74 19                	je     8027f2 <strnlen+0x27>
  8027d9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8027dc:	74 14                	je     8027f2 <strnlen+0x27>
  8027de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8027e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8027e6:	39 c8                	cmp    %ecx,%eax
  8027e8:	74 0d                	je     8027f7 <strnlen+0x2c>
  8027ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8027ee:	75 f3                	jne    8027e3 <strnlen+0x18>
  8027f0:	eb 05                	jmp    8027f7 <strnlen+0x2c>
  8027f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8027f7:	5b                   	pop    %ebx
  8027f8:	5d                   	pop    %ebp
  8027f9:	c3                   	ret    

008027fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8027fa:	55                   	push   %ebp
  8027fb:	89 e5                	mov    %esp,%ebp
  8027fd:	53                   	push   %ebx
  8027fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802804:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802809:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80280d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  802810:	83 c2 01             	add    $0x1,%edx
  802813:	84 c9                	test   %cl,%cl
  802815:	75 f2                	jne    802809 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  802817:	5b                   	pop    %ebx
  802818:	5d                   	pop    %ebp
  802819:	c3                   	ret    

0080281a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80281a:	55                   	push   %ebp
  80281b:	89 e5                	mov    %esp,%ebp
  80281d:	53                   	push   %ebx
  80281e:	83 ec 08             	sub    $0x8,%esp
  802821:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802824:	89 1c 24             	mov    %ebx,(%esp)
  802827:	e8 84 ff ff ff       	call   8027b0 <strlen>
	strcpy(dst + len, src);
  80282c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80282f:	89 54 24 04          	mov    %edx,0x4(%esp)
  802833:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  802836:	89 04 24             	mov    %eax,(%esp)
  802839:	e8 bc ff ff ff       	call   8027fa <strcpy>
	return dst;
}
  80283e:	89 d8                	mov    %ebx,%eax
  802840:	83 c4 08             	add    $0x8,%esp
  802843:	5b                   	pop    %ebx
  802844:	5d                   	pop    %ebp
  802845:	c3                   	ret    

00802846 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802846:	55                   	push   %ebp
  802847:	89 e5                	mov    %esp,%ebp
  802849:	56                   	push   %esi
  80284a:	53                   	push   %ebx
  80284b:	8b 45 08             	mov    0x8(%ebp),%eax
  80284e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802851:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802854:	85 f6                	test   %esi,%esi
  802856:	74 18                	je     802870 <strncpy+0x2a>
  802858:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80285d:	0f b6 1a             	movzbl (%edx),%ebx
  802860:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802863:	80 3a 01             	cmpb   $0x1,(%edx)
  802866:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802869:	83 c1 01             	add    $0x1,%ecx
  80286c:	39 ce                	cmp    %ecx,%esi
  80286e:	77 ed                	ja     80285d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802870:	5b                   	pop    %ebx
  802871:	5e                   	pop    %esi
  802872:	5d                   	pop    %ebp
  802873:	c3                   	ret    

00802874 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802874:	55                   	push   %ebp
  802875:	89 e5                	mov    %esp,%ebp
  802877:	56                   	push   %esi
  802878:	53                   	push   %ebx
  802879:	8b 75 08             	mov    0x8(%ebp),%esi
  80287c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80287f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802882:	89 f0                	mov    %esi,%eax
  802884:	85 c9                	test   %ecx,%ecx
  802886:	74 27                	je     8028af <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  802888:	83 e9 01             	sub    $0x1,%ecx
  80288b:	74 1d                	je     8028aa <strlcpy+0x36>
  80288d:	0f b6 1a             	movzbl (%edx),%ebx
  802890:	84 db                	test   %bl,%bl
  802892:	74 16                	je     8028aa <strlcpy+0x36>
			*dst++ = *src++;
  802894:	88 18                	mov    %bl,(%eax)
  802896:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802899:	83 e9 01             	sub    $0x1,%ecx
  80289c:	74 0e                	je     8028ac <strlcpy+0x38>
			*dst++ = *src++;
  80289e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8028a1:	0f b6 1a             	movzbl (%edx),%ebx
  8028a4:	84 db                	test   %bl,%bl
  8028a6:	75 ec                	jne    802894 <strlcpy+0x20>
  8028a8:	eb 02                	jmp    8028ac <strlcpy+0x38>
  8028aa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8028ac:	c6 00 00             	movb   $0x0,(%eax)
  8028af:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8028b1:	5b                   	pop    %ebx
  8028b2:	5e                   	pop    %esi
  8028b3:	5d                   	pop    %ebp
  8028b4:	c3                   	ret    

008028b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8028b5:	55                   	push   %ebp
  8028b6:	89 e5                	mov    %esp,%ebp
  8028b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8028be:	0f b6 01             	movzbl (%ecx),%eax
  8028c1:	84 c0                	test   %al,%al
  8028c3:	74 15                	je     8028da <strcmp+0x25>
  8028c5:	3a 02                	cmp    (%edx),%al
  8028c7:	75 11                	jne    8028da <strcmp+0x25>
		p++, q++;
  8028c9:	83 c1 01             	add    $0x1,%ecx
  8028cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8028cf:	0f b6 01             	movzbl (%ecx),%eax
  8028d2:	84 c0                	test   %al,%al
  8028d4:	74 04                	je     8028da <strcmp+0x25>
  8028d6:	3a 02                	cmp    (%edx),%al
  8028d8:	74 ef                	je     8028c9 <strcmp+0x14>
  8028da:	0f b6 c0             	movzbl %al,%eax
  8028dd:	0f b6 12             	movzbl (%edx),%edx
  8028e0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8028e2:	5d                   	pop    %ebp
  8028e3:	c3                   	ret    

008028e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8028e4:	55                   	push   %ebp
  8028e5:	89 e5                	mov    %esp,%ebp
  8028e7:	53                   	push   %ebx
  8028e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8028eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028ee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8028f1:	85 c0                	test   %eax,%eax
  8028f3:	74 23                	je     802918 <strncmp+0x34>
  8028f5:	0f b6 1a             	movzbl (%edx),%ebx
  8028f8:	84 db                	test   %bl,%bl
  8028fa:	74 25                	je     802921 <strncmp+0x3d>
  8028fc:	3a 19                	cmp    (%ecx),%bl
  8028fe:	75 21                	jne    802921 <strncmp+0x3d>
  802900:	83 e8 01             	sub    $0x1,%eax
  802903:	74 13                	je     802918 <strncmp+0x34>
		n--, p++, q++;
  802905:	83 c2 01             	add    $0x1,%edx
  802908:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80290b:	0f b6 1a             	movzbl (%edx),%ebx
  80290e:	84 db                	test   %bl,%bl
  802910:	74 0f                	je     802921 <strncmp+0x3d>
  802912:	3a 19                	cmp    (%ecx),%bl
  802914:	74 ea                	je     802900 <strncmp+0x1c>
  802916:	eb 09                	jmp    802921 <strncmp+0x3d>
  802918:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80291d:	5b                   	pop    %ebx
  80291e:	5d                   	pop    %ebp
  80291f:	90                   	nop
  802920:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802921:	0f b6 02             	movzbl (%edx),%eax
  802924:	0f b6 11             	movzbl (%ecx),%edx
  802927:	29 d0                	sub    %edx,%eax
  802929:	eb f2                	jmp    80291d <strncmp+0x39>

0080292b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80292b:	55                   	push   %ebp
  80292c:	89 e5                	mov    %esp,%ebp
  80292e:	8b 45 08             	mov    0x8(%ebp),%eax
  802931:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802935:	0f b6 10             	movzbl (%eax),%edx
  802938:	84 d2                	test   %dl,%dl
  80293a:	74 18                	je     802954 <strchr+0x29>
		if (*s == c)
  80293c:	38 ca                	cmp    %cl,%dl
  80293e:	75 0a                	jne    80294a <strchr+0x1f>
  802940:	eb 17                	jmp    802959 <strchr+0x2e>
  802942:	38 ca                	cmp    %cl,%dl
  802944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802948:	74 0f                	je     802959 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80294a:	83 c0 01             	add    $0x1,%eax
  80294d:	0f b6 10             	movzbl (%eax),%edx
  802950:	84 d2                	test   %dl,%dl
  802952:	75 ee                	jne    802942 <strchr+0x17>
  802954:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  802959:	5d                   	pop    %ebp
  80295a:	c3                   	ret    

0080295b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80295b:	55                   	push   %ebp
  80295c:	89 e5                	mov    %esp,%ebp
  80295e:	8b 45 08             	mov    0x8(%ebp),%eax
  802961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802965:	0f b6 10             	movzbl (%eax),%edx
  802968:	84 d2                	test   %dl,%dl
  80296a:	74 18                	je     802984 <strfind+0x29>
		if (*s == c)
  80296c:	38 ca                	cmp    %cl,%dl
  80296e:	75 0a                	jne    80297a <strfind+0x1f>
  802970:	eb 12                	jmp    802984 <strfind+0x29>
  802972:	38 ca                	cmp    %cl,%dl
  802974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802978:	74 0a                	je     802984 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80297a:	83 c0 01             	add    $0x1,%eax
  80297d:	0f b6 10             	movzbl (%eax),%edx
  802980:	84 d2                	test   %dl,%dl
  802982:	75 ee                	jne    802972 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  802984:	5d                   	pop    %ebp
  802985:	c3                   	ret    

00802986 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802986:	55                   	push   %ebp
  802987:	89 e5                	mov    %esp,%ebp
  802989:	83 ec 0c             	sub    $0xc,%esp
  80298c:	89 1c 24             	mov    %ebx,(%esp)
  80298f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802993:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802997:	8b 7d 08             	mov    0x8(%ebp),%edi
  80299a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80299d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8029a0:	85 c9                	test   %ecx,%ecx
  8029a2:	74 30                	je     8029d4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8029a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8029aa:	75 25                	jne    8029d1 <memset+0x4b>
  8029ac:	f6 c1 03             	test   $0x3,%cl
  8029af:	75 20                	jne    8029d1 <memset+0x4b>
		c &= 0xFF;
  8029b1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8029b4:	89 d3                	mov    %edx,%ebx
  8029b6:	c1 e3 08             	shl    $0x8,%ebx
  8029b9:	89 d6                	mov    %edx,%esi
  8029bb:	c1 e6 18             	shl    $0x18,%esi
  8029be:	89 d0                	mov    %edx,%eax
  8029c0:	c1 e0 10             	shl    $0x10,%eax
  8029c3:	09 f0                	or     %esi,%eax
  8029c5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8029c7:	09 d8                	or     %ebx,%eax
  8029c9:	c1 e9 02             	shr    $0x2,%ecx
  8029cc:	fc                   	cld    
  8029cd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8029cf:	eb 03                	jmp    8029d4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8029d1:	fc                   	cld    
  8029d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8029d4:	89 f8                	mov    %edi,%eax
  8029d6:	8b 1c 24             	mov    (%esp),%ebx
  8029d9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8029dd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8029e1:	89 ec                	mov    %ebp,%esp
  8029e3:	5d                   	pop    %ebp
  8029e4:	c3                   	ret    

008029e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8029e5:	55                   	push   %ebp
  8029e6:	89 e5                	mov    %esp,%ebp
  8029e8:	83 ec 08             	sub    $0x8,%esp
  8029eb:	89 34 24             	mov    %esi,(%esp)
  8029ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8029f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8029f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8029f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8029fb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8029fd:	39 c6                	cmp    %eax,%esi
  8029ff:	73 35                	jae    802a36 <memmove+0x51>
  802a01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802a04:	39 d0                	cmp    %edx,%eax
  802a06:	73 2e                	jae    802a36 <memmove+0x51>
		s += n;
		d += n;
  802a08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802a0a:	f6 c2 03             	test   $0x3,%dl
  802a0d:	75 1b                	jne    802a2a <memmove+0x45>
  802a0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802a15:	75 13                	jne    802a2a <memmove+0x45>
  802a17:	f6 c1 03             	test   $0x3,%cl
  802a1a:	75 0e                	jne    802a2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  802a1c:	83 ef 04             	sub    $0x4,%edi
  802a1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  802a22:	c1 e9 02             	shr    $0x2,%ecx
  802a25:	fd                   	std    
  802a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802a28:	eb 09                	jmp    802a33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802a2a:	83 ef 01             	sub    $0x1,%edi
  802a2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  802a30:	fd                   	std    
  802a31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802a33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802a34:	eb 20                	jmp    802a56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802a36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802a3c:	75 15                	jne    802a53 <memmove+0x6e>
  802a3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802a44:	75 0d                	jne    802a53 <memmove+0x6e>
  802a46:	f6 c1 03             	test   $0x3,%cl
  802a49:	75 08                	jne    802a53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  802a4b:	c1 e9 02             	shr    $0x2,%ecx
  802a4e:	fc                   	cld    
  802a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802a51:	eb 03                	jmp    802a56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802a53:	fc                   	cld    
  802a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802a56:	8b 34 24             	mov    (%esp),%esi
  802a59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a5d:	89 ec                	mov    %ebp,%esp
  802a5f:	5d                   	pop    %ebp
  802a60:	c3                   	ret    

00802a61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  802a61:	55                   	push   %ebp
  802a62:	89 e5                	mov    %esp,%ebp
  802a64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802a67:	8b 45 10             	mov    0x10(%ebp),%eax
  802a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a75:	8b 45 08             	mov    0x8(%ebp),%eax
  802a78:	89 04 24             	mov    %eax,(%esp)
  802a7b:	e8 65 ff ff ff       	call   8029e5 <memmove>
}
  802a80:	c9                   	leave  
  802a81:	c3                   	ret    

00802a82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802a82:	55                   	push   %ebp
  802a83:	89 e5                	mov    %esp,%ebp
  802a85:	57                   	push   %edi
  802a86:	56                   	push   %esi
  802a87:	53                   	push   %ebx
  802a88:	8b 75 08             	mov    0x8(%ebp),%esi
  802a8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802a91:	85 c9                	test   %ecx,%ecx
  802a93:	74 36                	je     802acb <memcmp+0x49>
		if (*s1 != *s2)
  802a95:	0f b6 06             	movzbl (%esi),%eax
  802a98:	0f b6 1f             	movzbl (%edi),%ebx
  802a9b:	38 d8                	cmp    %bl,%al
  802a9d:	74 20                	je     802abf <memcmp+0x3d>
  802a9f:	eb 14                	jmp    802ab5 <memcmp+0x33>
  802aa1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  802aa6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  802aab:	83 c2 01             	add    $0x1,%edx
  802aae:	83 e9 01             	sub    $0x1,%ecx
  802ab1:	38 d8                	cmp    %bl,%al
  802ab3:	74 12                	je     802ac7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  802ab5:	0f b6 c0             	movzbl %al,%eax
  802ab8:	0f b6 db             	movzbl %bl,%ebx
  802abb:	29 d8                	sub    %ebx,%eax
  802abd:	eb 11                	jmp    802ad0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802abf:	83 e9 01             	sub    $0x1,%ecx
  802ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  802ac7:	85 c9                	test   %ecx,%ecx
  802ac9:	75 d6                	jne    802aa1 <memcmp+0x1f>
  802acb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802ad0:	5b                   	pop    %ebx
  802ad1:	5e                   	pop    %esi
  802ad2:	5f                   	pop    %edi
  802ad3:	5d                   	pop    %ebp
  802ad4:	c3                   	ret    

00802ad5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802ad5:	55                   	push   %ebp
  802ad6:	89 e5                	mov    %esp,%ebp
  802ad8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802adb:	89 c2                	mov    %eax,%edx
  802add:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802ae0:	39 d0                	cmp    %edx,%eax
  802ae2:	73 15                	jae    802af9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802ae4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  802ae8:	38 08                	cmp    %cl,(%eax)
  802aea:	75 06                	jne    802af2 <memfind+0x1d>
  802aec:	eb 0b                	jmp    802af9 <memfind+0x24>
  802aee:	38 08                	cmp    %cl,(%eax)
  802af0:	74 07                	je     802af9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802af2:	83 c0 01             	add    $0x1,%eax
  802af5:	39 c2                	cmp    %eax,%edx
  802af7:	77 f5                	ja     802aee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802af9:	5d                   	pop    %ebp
  802afa:	c3                   	ret    

00802afb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802afb:	55                   	push   %ebp
  802afc:	89 e5                	mov    %esp,%ebp
  802afe:	57                   	push   %edi
  802aff:	56                   	push   %esi
  802b00:	53                   	push   %ebx
  802b01:	83 ec 04             	sub    $0x4,%esp
  802b04:	8b 55 08             	mov    0x8(%ebp),%edx
  802b07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802b0a:	0f b6 02             	movzbl (%edx),%eax
  802b0d:	3c 20                	cmp    $0x20,%al
  802b0f:	74 04                	je     802b15 <strtol+0x1a>
  802b11:	3c 09                	cmp    $0x9,%al
  802b13:	75 0e                	jne    802b23 <strtol+0x28>
		s++;
  802b15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802b18:	0f b6 02             	movzbl (%edx),%eax
  802b1b:	3c 20                	cmp    $0x20,%al
  802b1d:	74 f6                	je     802b15 <strtol+0x1a>
  802b1f:	3c 09                	cmp    $0x9,%al
  802b21:	74 f2                	je     802b15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  802b23:	3c 2b                	cmp    $0x2b,%al
  802b25:	75 0c                	jne    802b33 <strtol+0x38>
		s++;
  802b27:	83 c2 01             	add    $0x1,%edx
  802b2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802b31:	eb 15                	jmp    802b48 <strtol+0x4d>
	else if (*s == '-')
  802b33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802b3a:	3c 2d                	cmp    $0x2d,%al
  802b3c:	75 0a                	jne    802b48 <strtol+0x4d>
		s++, neg = 1;
  802b3e:	83 c2 01             	add    $0x1,%edx
  802b41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802b48:	85 db                	test   %ebx,%ebx
  802b4a:	0f 94 c0             	sete   %al
  802b4d:	74 05                	je     802b54 <strtol+0x59>
  802b4f:	83 fb 10             	cmp    $0x10,%ebx
  802b52:	75 18                	jne    802b6c <strtol+0x71>
  802b54:	80 3a 30             	cmpb   $0x30,(%edx)
  802b57:	75 13                	jne    802b6c <strtol+0x71>
  802b59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802b5d:	8d 76 00             	lea    0x0(%esi),%esi
  802b60:	75 0a                	jne    802b6c <strtol+0x71>
		s += 2, base = 16;
  802b62:	83 c2 02             	add    $0x2,%edx
  802b65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802b6a:	eb 15                	jmp    802b81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802b6c:	84 c0                	test   %al,%al
  802b6e:	66 90                	xchg   %ax,%ax
  802b70:	74 0f                	je     802b81 <strtol+0x86>
  802b72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802b77:	80 3a 30             	cmpb   $0x30,(%edx)
  802b7a:	75 05                	jne    802b81 <strtol+0x86>
		s++, base = 8;
  802b7c:	83 c2 01             	add    $0x1,%edx
  802b7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802b81:	b8 00 00 00 00       	mov    $0x0,%eax
  802b86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802b88:	0f b6 0a             	movzbl (%edx),%ecx
  802b8b:	89 cf                	mov    %ecx,%edi
  802b8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802b90:	80 fb 09             	cmp    $0x9,%bl
  802b93:	77 08                	ja     802b9d <strtol+0xa2>
			dig = *s - '0';
  802b95:	0f be c9             	movsbl %cl,%ecx
  802b98:	83 e9 30             	sub    $0x30,%ecx
  802b9b:	eb 1e                	jmp    802bbb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  802b9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  802ba0:	80 fb 19             	cmp    $0x19,%bl
  802ba3:	77 08                	ja     802bad <strtol+0xb2>
			dig = *s - 'a' + 10;
  802ba5:	0f be c9             	movsbl %cl,%ecx
  802ba8:	83 e9 57             	sub    $0x57,%ecx
  802bab:	eb 0e                	jmp    802bbb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  802bad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  802bb0:	80 fb 19             	cmp    $0x19,%bl
  802bb3:	77 15                	ja     802bca <strtol+0xcf>
			dig = *s - 'A' + 10;
  802bb5:	0f be c9             	movsbl %cl,%ecx
  802bb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802bbb:	39 f1                	cmp    %esi,%ecx
  802bbd:	7d 0b                	jge    802bca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  802bbf:	83 c2 01             	add    $0x1,%edx
  802bc2:	0f af c6             	imul   %esi,%eax
  802bc5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  802bc8:	eb be                	jmp    802b88 <strtol+0x8d>
  802bca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  802bcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802bd0:	74 05                	je     802bd7 <strtol+0xdc>
		*endptr = (char *) s;
  802bd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802bd5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802bd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802bdb:	74 04                	je     802be1 <strtol+0xe6>
  802bdd:	89 c8                	mov    %ecx,%eax
  802bdf:	f7 d8                	neg    %eax
}
  802be1:	83 c4 04             	add    $0x4,%esp
  802be4:	5b                   	pop    %ebx
  802be5:	5e                   	pop    %esi
  802be6:	5f                   	pop    %edi
  802be7:	5d                   	pop    %ebp
  802be8:	c3                   	ret    
  802be9:	00 00                	add    %al,(%eax)
	...

00802bec <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  802bec:	55                   	push   %ebp
  802bed:	89 e5                	mov    %esp,%ebp
  802bef:	83 ec 08             	sub    $0x8,%esp
  802bf2:	89 1c 24             	mov    %ebx,(%esp)
  802bf5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  802bfe:	b8 01 00 00 00       	mov    $0x1,%eax
  802c03:	89 d1                	mov    %edx,%ecx
  802c05:	89 d3                	mov    %edx,%ebx
  802c07:	89 d7                	mov    %edx,%edi
  802c09:	51                   	push   %ecx
  802c0a:	52                   	push   %edx
  802c0b:	53                   	push   %ebx
  802c0c:	54                   	push   %esp
  802c0d:	55                   	push   %ebp
  802c0e:	56                   	push   %esi
  802c0f:	57                   	push   %edi
  802c10:	54                   	push   %esp
  802c11:	5d                   	pop    %ebp
  802c12:	8d 35 1a 2c 80 00    	lea    0x802c1a,%esi
  802c18:	0f 34                	sysenter 
  802c1a:	5f                   	pop    %edi
  802c1b:	5e                   	pop    %esi
  802c1c:	5d                   	pop    %ebp
  802c1d:	5c                   	pop    %esp
  802c1e:	5b                   	pop    %ebx
  802c1f:	5a                   	pop    %edx
  802c20:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802c21:	8b 1c 24             	mov    (%esp),%ebx
  802c24:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802c28:	89 ec                	mov    %ebp,%esp
  802c2a:	5d                   	pop    %ebp
  802c2b:	c3                   	ret    

00802c2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802c2c:	55                   	push   %ebp
  802c2d:	89 e5                	mov    %esp,%ebp
  802c2f:	83 ec 08             	sub    $0x8,%esp
  802c32:	89 1c 24             	mov    %ebx,(%esp)
  802c35:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802c39:	b8 00 00 00 00       	mov    $0x0,%eax
  802c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c41:	8b 55 08             	mov    0x8(%ebp),%edx
  802c44:	89 c3                	mov    %eax,%ebx
  802c46:	89 c7                	mov    %eax,%edi
  802c48:	51                   	push   %ecx
  802c49:	52                   	push   %edx
  802c4a:	53                   	push   %ebx
  802c4b:	54                   	push   %esp
  802c4c:	55                   	push   %ebp
  802c4d:	56                   	push   %esi
  802c4e:	57                   	push   %edi
  802c4f:	54                   	push   %esp
  802c50:	5d                   	pop    %ebp
  802c51:	8d 35 59 2c 80 00    	lea    0x802c59,%esi
  802c57:	0f 34                	sysenter 
  802c59:	5f                   	pop    %edi
  802c5a:	5e                   	pop    %esi
  802c5b:	5d                   	pop    %ebp
  802c5c:	5c                   	pop    %esp
  802c5d:	5b                   	pop    %ebx
  802c5e:	5a                   	pop    %edx
  802c5f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802c60:	8b 1c 24             	mov    (%esp),%ebx
  802c63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802c67:	89 ec                	mov    %ebp,%esp
  802c69:	5d                   	pop    %ebp
  802c6a:	c3                   	ret    

00802c6b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  802c6b:	55                   	push   %ebp
  802c6c:	89 e5                	mov    %esp,%ebp
  802c6e:	83 ec 08             	sub    $0x8,%esp
  802c71:	89 1c 24             	mov    %ebx,(%esp)
  802c74:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802c78:	b8 10 00 00 00       	mov    $0x10,%eax
  802c7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  802c80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c86:	8b 55 08             	mov    0x8(%ebp),%edx
  802c89:	51                   	push   %ecx
  802c8a:	52                   	push   %edx
  802c8b:	53                   	push   %ebx
  802c8c:	54                   	push   %esp
  802c8d:	55                   	push   %ebp
  802c8e:	56                   	push   %esi
  802c8f:	57                   	push   %edi
  802c90:	54                   	push   %esp
  802c91:	5d                   	pop    %ebp
  802c92:	8d 35 9a 2c 80 00    	lea    0x802c9a,%esi
  802c98:	0f 34                	sysenter 
  802c9a:	5f                   	pop    %edi
  802c9b:	5e                   	pop    %esi
  802c9c:	5d                   	pop    %ebp
  802c9d:	5c                   	pop    %esp
  802c9e:	5b                   	pop    %ebx
  802c9f:	5a                   	pop    %edx
  802ca0:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  802ca1:	8b 1c 24             	mov    (%esp),%ebx
  802ca4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802ca8:	89 ec                	mov    %ebp,%esp
  802caa:	5d                   	pop    %ebp
  802cab:	c3                   	ret    

00802cac <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  802cac:	55                   	push   %ebp
  802cad:	89 e5                	mov    %esp,%ebp
  802caf:	83 ec 28             	sub    $0x28,%esp
  802cb2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802cb5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  802cbd:	b8 0f 00 00 00       	mov    $0xf,%eax
  802cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  802cc8:	89 df                	mov    %ebx,%edi
  802cca:	51                   	push   %ecx
  802ccb:	52                   	push   %edx
  802ccc:	53                   	push   %ebx
  802ccd:	54                   	push   %esp
  802cce:	55                   	push   %ebp
  802ccf:	56                   	push   %esi
  802cd0:	57                   	push   %edi
  802cd1:	54                   	push   %esp
  802cd2:	5d                   	pop    %ebp
  802cd3:	8d 35 db 2c 80 00    	lea    0x802cdb,%esi
  802cd9:	0f 34                	sysenter 
  802cdb:	5f                   	pop    %edi
  802cdc:	5e                   	pop    %esi
  802cdd:	5d                   	pop    %ebp
  802cde:	5c                   	pop    %esp
  802cdf:	5b                   	pop    %ebx
  802ce0:	5a                   	pop    %edx
  802ce1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  802ce2:	85 c0                	test   %eax,%eax
  802ce4:	7e 28                	jle    802d0e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  802ce6:	89 44 24 10          	mov    %eax,0x10(%esp)
  802cea:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  802cf1:	00 
  802cf2:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  802cf9:	00 
  802cfa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802d01:	00 
  802d02:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  802d09:	e8 06 f1 ff ff       	call   801e14 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  802d0e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802d11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802d14:	89 ec                	mov    %ebp,%esp
  802d16:	5d                   	pop    %ebp
  802d17:	c3                   	ret    

00802d18 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  802d18:	55                   	push   %ebp
  802d19:	89 e5                	mov    %esp,%ebp
  802d1b:	83 ec 08             	sub    $0x8,%esp
  802d1e:	89 1c 24             	mov    %ebx,(%esp)
  802d21:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802d25:	b9 00 00 00 00       	mov    $0x0,%ecx
  802d2a:	b8 11 00 00 00       	mov    $0x11,%eax
  802d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  802d32:	89 cb                	mov    %ecx,%ebx
  802d34:	89 cf                	mov    %ecx,%edi
  802d36:	51                   	push   %ecx
  802d37:	52                   	push   %edx
  802d38:	53                   	push   %ebx
  802d39:	54                   	push   %esp
  802d3a:	55                   	push   %ebp
  802d3b:	56                   	push   %esi
  802d3c:	57                   	push   %edi
  802d3d:	54                   	push   %esp
  802d3e:	5d                   	pop    %ebp
  802d3f:	8d 35 47 2d 80 00    	lea    0x802d47,%esi
  802d45:	0f 34                	sysenter 
  802d47:	5f                   	pop    %edi
  802d48:	5e                   	pop    %esi
  802d49:	5d                   	pop    %ebp
  802d4a:	5c                   	pop    %esp
  802d4b:	5b                   	pop    %ebx
  802d4c:	5a                   	pop    %edx
  802d4d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  802d4e:	8b 1c 24             	mov    (%esp),%ebx
  802d51:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802d55:	89 ec                	mov    %ebp,%esp
  802d57:	5d                   	pop    %ebp
  802d58:	c3                   	ret    

00802d59 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  802d59:	55                   	push   %ebp
  802d5a:	89 e5                	mov    %esp,%ebp
  802d5c:	83 ec 28             	sub    $0x28,%esp
  802d5f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802d62:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802d65:	b9 00 00 00 00       	mov    $0x0,%ecx
  802d6a:	b8 0e 00 00 00       	mov    $0xe,%eax
  802d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  802d72:	89 cb                	mov    %ecx,%ebx
  802d74:	89 cf                	mov    %ecx,%edi
  802d76:	51                   	push   %ecx
  802d77:	52                   	push   %edx
  802d78:	53                   	push   %ebx
  802d79:	54                   	push   %esp
  802d7a:	55                   	push   %ebp
  802d7b:	56                   	push   %esi
  802d7c:	57                   	push   %edi
  802d7d:	54                   	push   %esp
  802d7e:	5d                   	pop    %ebp
  802d7f:	8d 35 87 2d 80 00    	lea    0x802d87,%esi
  802d85:	0f 34                	sysenter 
  802d87:	5f                   	pop    %edi
  802d88:	5e                   	pop    %esi
  802d89:	5d                   	pop    %ebp
  802d8a:	5c                   	pop    %esp
  802d8b:	5b                   	pop    %ebx
  802d8c:	5a                   	pop    %edx
  802d8d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  802d8e:	85 c0                	test   %eax,%eax
  802d90:	7e 28                	jle    802dba <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  802d92:	89 44 24 10          	mov    %eax,0x10(%esp)
  802d96:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  802d9d:	00 
  802d9e:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  802da5:	00 
  802da6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802dad:	00 
  802dae:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  802db5:	e8 5a f0 ff ff       	call   801e14 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802dba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802dbd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802dc0:	89 ec                	mov    %ebp,%esp
  802dc2:	5d                   	pop    %ebp
  802dc3:	c3                   	ret    

00802dc4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802dc4:	55                   	push   %ebp
  802dc5:	89 e5                	mov    %esp,%ebp
  802dc7:	83 ec 08             	sub    $0x8,%esp
  802dca:	89 1c 24             	mov    %ebx,(%esp)
  802dcd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802dd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  802dd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  802dd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  802de2:	51                   	push   %ecx
  802de3:	52                   	push   %edx
  802de4:	53                   	push   %ebx
  802de5:	54                   	push   %esp
  802de6:	55                   	push   %ebp
  802de7:	56                   	push   %esi
  802de8:	57                   	push   %edi
  802de9:	54                   	push   %esp
  802dea:	5d                   	pop    %ebp
  802deb:	8d 35 f3 2d 80 00    	lea    0x802df3,%esi
  802df1:	0f 34                	sysenter 
  802df3:	5f                   	pop    %edi
  802df4:	5e                   	pop    %esi
  802df5:	5d                   	pop    %ebp
  802df6:	5c                   	pop    %esp
  802df7:	5b                   	pop    %ebx
  802df8:	5a                   	pop    %edx
  802df9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802dfa:	8b 1c 24             	mov    (%esp),%ebx
  802dfd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802e01:	89 ec                	mov    %ebp,%esp
  802e03:	5d                   	pop    %ebp
  802e04:	c3                   	ret    

00802e05 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802e05:	55                   	push   %ebp
  802e06:	89 e5                	mov    %esp,%ebp
  802e08:	83 ec 28             	sub    $0x28,%esp
  802e0b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802e0e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802e11:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e16:	b8 0b 00 00 00       	mov    $0xb,%eax
  802e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  802e21:	89 df                	mov    %ebx,%edi
  802e23:	51                   	push   %ecx
  802e24:	52                   	push   %edx
  802e25:	53                   	push   %ebx
  802e26:	54                   	push   %esp
  802e27:	55                   	push   %ebp
  802e28:	56                   	push   %esi
  802e29:	57                   	push   %edi
  802e2a:	54                   	push   %esp
  802e2b:	5d                   	pop    %ebp
  802e2c:	8d 35 34 2e 80 00    	lea    0x802e34,%esi
  802e32:	0f 34                	sysenter 
  802e34:	5f                   	pop    %edi
  802e35:	5e                   	pop    %esi
  802e36:	5d                   	pop    %ebp
  802e37:	5c                   	pop    %esp
  802e38:	5b                   	pop    %ebx
  802e39:	5a                   	pop    %edx
  802e3a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  802e3b:	85 c0                	test   %eax,%eax
  802e3d:	7e 28                	jle    802e67 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  802e3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  802e43:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  802e4a:	00 
  802e4b:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  802e52:	00 
  802e53:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802e5a:	00 
  802e5b:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  802e62:	e8 ad ef ff ff       	call   801e14 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802e67:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802e6a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802e6d:	89 ec                	mov    %ebp,%esp
  802e6f:	5d                   	pop    %ebp
  802e70:	c3                   	ret    

00802e71 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802e71:	55                   	push   %ebp
  802e72:	89 e5                	mov    %esp,%ebp
  802e74:	83 ec 28             	sub    $0x28,%esp
  802e77:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802e7a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e82:	b8 0a 00 00 00       	mov    $0xa,%eax
  802e87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  802e8d:	89 df                	mov    %ebx,%edi
  802e8f:	51                   	push   %ecx
  802e90:	52                   	push   %edx
  802e91:	53                   	push   %ebx
  802e92:	54                   	push   %esp
  802e93:	55                   	push   %ebp
  802e94:	56                   	push   %esi
  802e95:	57                   	push   %edi
  802e96:	54                   	push   %esp
  802e97:	5d                   	pop    %ebp
  802e98:	8d 35 a0 2e 80 00    	lea    0x802ea0,%esi
  802e9e:	0f 34                	sysenter 
  802ea0:	5f                   	pop    %edi
  802ea1:	5e                   	pop    %esi
  802ea2:	5d                   	pop    %ebp
  802ea3:	5c                   	pop    %esp
  802ea4:	5b                   	pop    %ebx
  802ea5:	5a                   	pop    %edx
  802ea6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  802ea7:	85 c0                	test   %eax,%eax
  802ea9:	7e 28                	jle    802ed3 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  802eab:	89 44 24 10          	mov    %eax,0x10(%esp)
  802eaf:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802eb6:	00 
  802eb7:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  802ebe:	00 
  802ebf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802ec6:	00 
  802ec7:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  802ece:	e8 41 ef ff ff       	call   801e14 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802ed3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802ed6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802ed9:	89 ec                	mov    %ebp,%esp
  802edb:	5d                   	pop    %ebp
  802edc:	c3                   	ret    

00802edd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802edd:	55                   	push   %ebp
  802ede:	89 e5                	mov    %esp,%ebp
  802ee0:	83 ec 28             	sub    $0x28,%esp
  802ee3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802ee6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  802eee:	b8 09 00 00 00       	mov    $0x9,%eax
  802ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  802ef9:	89 df                	mov    %ebx,%edi
  802efb:	51                   	push   %ecx
  802efc:	52                   	push   %edx
  802efd:	53                   	push   %ebx
  802efe:	54                   	push   %esp
  802eff:	55                   	push   %ebp
  802f00:	56                   	push   %esi
  802f01:	57                   	push   %edi
  802f02:	54                   	push   %esp
  802f03:	5d                   	pop    %ebp
  802f04:	8d 35 0c 2f 80 00    	lea    0x802f0c,%esi
  802f0a:	0f 34                	sysenter 
  802f0c:	5f                   	pop    %edi
  802f0d:	5e                   	pop    %esi
  802f0e:	5d                   	pop    %ebp
  802f0f:	5c                   	pop    %esp
  802f10:	5b                   	pop    %ebx
  802f11:	5a                   	pop    %edx
  802f12:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  802f13:	85 c0                	test   %eax,%eax
  802f15:	7e 28                	jle    802f3f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  802f17:	89 44 24 10          	mov    %eax,0x10(%esp)
  802f1b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802f22:	00 
  802f23:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  802f2a:	00 
  802f2b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802f32:	00 
  802f33:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  802f3a:	e8 d5 ee ff ff       	call   801e14 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802f3f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802f42:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802f45:	89 ec                	mov    %ebp,%esp
  802f47:	5d                   	pop    %ebp
  802f48:	c3                   	ret    

00802f49 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  802f49:	55                   	push   %ebp
  802f4a:	89 e5                	mov    %esp,%ebp
  802f4c:	83 ec 28             	sub    $0x28,%esp
  802f4f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802f52:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f5a:	b8 07 00 00 00       	mov    $0x7,%eax
  802f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f62:	8b 55 08             	mov    0x8(%ebp),%edx
  802f65:	89 df                	mov    %ebx,%edi
  802f67:	51                   	push   %ecx
  802f68:	52                   	push   %edx
  802f69:	53                   	push   %ebx
  802f6a:	54                   	push   %esp
  802f6b:	55                   	push   %ebp
  802f6c:	56                   	push   %esi
  802f6d:	57                   	push   %edi
  802f6e:	54                   	push   %esp
  802f6f:	5d                   	pop    %ebp
  802f70:	8d 35 78 2f 80 00    	lea    0x802f78,%esi
  802f76:	0f 34                	sysenter 
  802f78:	5f                   	pop    %edi
  802f79:	5e                   	pop    %esi
  802f7a:	5d                   	pop    %ebp
  802f7b:	5c                   	pop    %esp
  802f7c:	5b                   	pop    %ebx
  802f7d:	5a                   	pop    %edx
  802f7e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  802f7f:	85 c0                	test   %eax,%eax
  802f81:	7e 28                	jle    802fab <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  802f83:	89 44 24 10          	mov    %eax,0x10(%esp)
  802f87:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802f8e:	00 
  802f8f:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  802f96:	00 
  802f97:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802f9e:	00 
  802f9f:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  802fa6:	e8 69 ee ff ff       	call   801e14 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802fab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802fae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802fb1:	89 ec                	mov    %ebp,%esp
  802fb3:	5d                   	pop    %ebp
  802fb4:	c3                   	ret    

00802fb5 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802fb5:	55                   	push   %ebp
  802fb6:	89 e5                	mov    %esp,%ebp
  802fb8:	83 ec 28             	sub    $0x28,%esp
  802fbb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802fbe:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802fc1:	8b 7d 18             	mov    0x18(%ebp),%edi
  802fc4:	0b 7d 14             	or     0x14(%ebp),%edi
  802fc7:	b8 06 00 00 00       	mov    $0x6,%eax
  802fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802fcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802fd2:	8b 55 08             	mov    0x8(%ebp),%edx
  802fd5:	51                   	push   %ecx
  802fd6:	52                   	push   %edx
  802fd7:	53                   	push   %ebx
  802fd8:	54                   	push   %esp
  802fd9:	55                   	push   %ebp
  802fda:	56                   	push   %esi
  802fdb:	57                   	push   %edi
  802fdc:	54                   	push   %esp
  802fdd:	5d                   	pop    %ebp
  802fde:	8d 35 e6 2f 80 00    	lea    0x802fe6,%esi
  802fe4:	0f 34                	sysenter 
  802fe6:	5f                   	pop    %edi
  802fe7:	5e                   	pop    %esi
  802fe8:	5d                   	pop    %ebp
  802fe9:	5c                   	pop    %esp
  802fea:	5b                   	pop    %ebx
  802feb:	5a                   	pop    %edx
  802fec:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  802fed:	85 c0                	test   %eax,%eax
  802fef:	7e 28                	jle    803019 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  802ff1:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ff5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802ffc:	00 
  802ffd:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  803004:	00 
  803005:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80300c:	00 
  80300d:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  803014:	e8 fb ed ff ff       	call   801e14 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  803019:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80301c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80301f:	89 ec                	mov    %ebp,%esp
  803021:	5d                   	pop    %ebp
  803022:	c3                   	ret    

00803023 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  803023:	55                   	push   %ebp
  803024:	89 e5                	mov    %esp,%ebp
  803026:	83 ec 28             	sub    $0x28,%esp
  803029:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80302c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80302f:	bf 00 00 00 00       	mov    $0x0,%edi
  803034:	b8 05 00 00 00       	mov    $0x5,%eax
  803039:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80303c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80303f:	8b 55 08             	mov    0x8(%ebp),%edx
  803042:	51                   	push   %ecx
  803043:	52                   	push   %edx
  803044:	53                   	push   %ebx
  803045:	54                   	push   %esp
  803046:	55                   	push   %ebp
  803047:	56                   	push   %esi
  803048:	57                   	push   %edi
  803049:	54                   	push   %esp
  80304a:	5d                   	pop    %ebp
  80304b:	8d 35 53 30 80 00    	lea    0x803053,%esi
  803051:	0f 34                	sysenter 
  803053:	5f                   	pop    %edi
  803054:	5e                   	pop    %esi
  803055:	5d                   	pop    %ebp
  803056:	5c                   	pop    %esp
  803057:	5b                   	pop    %ebx
  803058:	5a                   	pop    %edx
  803059:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80305a:	85 c0                	test   %eax,%eax
  80305c:	7e 28                	jle    803086 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80305e:	89 44 24 10          	mov    %eax,0x10(%esp)
  803062:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  803069:	00 
  80306a:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  803071:	00 
  803072:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  803079:	00 
  80307a:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  803081:	e8 8e ed ff ff       	call   801e14 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  803086:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803089:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80308c:	89 ec                	mov    %ebp,%esp
  80308e:	5d                   	pop    %ebp
  80308f:	c3                   	ret    

00803090 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  803090:	55                   	push   %ebp
  803091:	89 e5                	mov    %esp,%ebp
  803093:	83 ec 08             	sub    $0x8,%esp
  803096:	89 1c 24             	mov    %ebx,(%esp)
  803099:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80309d:	ba 00 00 00 00       	mov    $0x0,%edx
  8030a2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8030a7:	89 d1                	mov    %edx,%ecx
  8030a9:	89 d3                	mov    %edx,%ebx
  8030ab:	89 d7                	mov    %edx,%edi
  8030ad:	51                   	push   %ecx
  8030ae:	52                   	push   %edx
  8030af:	53                   	push   %ebx
  8030b0:	54                   	push   %esp
  8030b1:	55                   	push   %ebp
  8030b2:	56                   	push   %esi
  8030b3:	57                   	push   %edi
  8030b4:	54                   	push   %esp
  8030b5:	5d                   	pop    %ebp
  8030b6:	8d 35 be 30 80 00    	lea    0x8030be,%esi
  8030bc:	0f 34                	sysenter 
  8030be:	5f                   	pop    %edi
  8030bf:	5e                   	pop    %esi
  8030c0:	5d                   	pop    %ebp
  8030c1:	5c                   	pop    %esp
  8030c2:	5b                   	pop    %ebx
  8030c3:	5a                   	pop    %edx
  8030c4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8030c5:	8b 1c 24             	mov    (%esp),%ebx
  8030c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8030cc:	89 ec                	mov    %ebp,%esp
  8030ce:	5d                   	pop    %ebp
  8030cf:	c3                   	ret    

008030d0 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8030d0:	55                   	push   %ebp
  8030d1:	89 e5                	mov    %esp,%ebp
  8030d3:	83 ec 08             	sub    $0x8,%esp
  8030d6:	89 1c 24             	mov    %ebx,(%esp)
  8030d9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8030dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8030e2:	b8 04 00 00 00       	mov    $0x4,%eax
  8030e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8030ed:	89 df                	mov    %ebx,%edi
  8030ef:	51                   	push   %ecx
  8030f0:	52                   	push   %edx
  8030f1:	53                   	push   %ebx
  8030f2:	54                   	push   %esp
  8030f3:	55                   	push   %ebp
  8030f4:	56                   	push   %esi
  8030f5:	57                   	push   %edi
  8030f6:	54                   	push   %esp
  8030f7:	5d                   	pop    %ebp
  8030f8:	8d 35 00 31 80 00    	lea    0x803100,%esi
  8030fe:	0f 34                	sysenter 
  803100:	5f                   	pop    %edi
  803101:	5e                   	pop    %esi
  803102:	5d                   	pop    %ebp
  803103:	5c                   	pop    %esp
  803104:	5b                   	pop    %ebx
  803105:	5a                   	pop    %edx
  803106:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  803107:	8b 1c 24             	mov    (%esp),%ebx
  80310a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80310e:	89 ec                	mov    %ebp,%esp
  803110:	5d                   	pop    %ebp
  803111:	c3                   	ret    

00803112 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  803112:	55                   	push   %ebp
  803113:	89 e5                	mov    %esp,%ebp
  803115:	83 ec 08             	sub    $0x8,%esp
  803118:	89 1c 24             	mov    %ebx,(%esp)
  80311b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80311f:	ba 00 00 00 00       	mov    $0x0,%edx
  803124:	b8 02 00 00 00       	mov    $0x2,%eax
  803129:	89 d1                	mov    %edx,%ecx
  80312b:	89 d3                	mov    %edx,%ebx
  80312d:	89 d7                	mov    %edx,%edi
  80312f:	51                   	push   %ecx
  803130:	52                   	push   %edx
  803131:	53                   	push   %ebx
  803132:	54                   	push   %esp
  803133:	55                   	push   %ebp
  803134:	56                   	push   %esi
  803135:	57                   	push   %edi
  803136:	54                   	push   %esp
  803137:	5d                   	pop    %ebp
  803138:	8d 35 40 31 80 00    	lea    0x803140,%esi
  80313e:	0f 34                	sysenter 
  803140:	5f                   	pop    %edi
  803141:	5e                   	pop    %esi
  803142:	5d                   	pop    %ebp
  803143:	5c                   	pop    %esp
  803144:	5b                   	pop    %ebx
  803145:	5a                   	pop    %edx
  803146:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  803147:	8b 1c 24             	mov    (%esp),%ebx
  80314a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80314e:	89 ec                	mov    %ebp,%esp
  803150:	5d                   	pop    %ebp
  803151:	c3                   	ret    

00803152 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  803152:	55                   	push   %ebp
  803153:	89 e5                	mov    %esp,%ebp
  803155:	83 ec 28             	sub    $0x28,%esp
  803158:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80315b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80315e:	b9 00 00 00 00       	mov    $0x0,%ecx
  803163:	b8 03 00 00 00       	mov    $0x3,%eax
  803168:	8b 55 08             	mov    0x8(%ebp),%edx
  80316b:	89 cb                	mov    %ecx,%ebx
  80316d:	89 cf                	mov    %ecx,%edi
  80316f:	51                   	push   %ecx
  803170:	52                   	push   %edx
  803171:	53                   	push   %ebx
  803172:	54                   	push   %esp
  803173:	55                   	push   %ebp
  803174:	56                   	push   %esi
  803175:	57                   	push   %edi
  803176:	54                   	push   %esp
  803177:	5d                   	pop    %ebp
  803178:	8d 35 80 31 80 00    	lea    0x803180,%esi
  80317e:	0f 34                	sysenter 
  803180:	5f                   	pop    %edi
  803181:	5e                   	pop    %esi
  803182:	5d                   	pop    %ebp
  803183:	5c                   	pop    %esp
  803184:	5b                   	pop    %ebx
  803185:	5a                   	pop    %edx
  803186:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  803187:	85 c0                	test   %eax,%eax
  803189:	7e 28                	jle    8031b3 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80318b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80318f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  803196:	00 
  803197:	c7 44 24 08 e0 47 80 	movl   $0x8047e0,0x8(%esp)
  80319e:	00 
  80319f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8031a6:	00 
  8031a7:	c7 04 24 fd 47 80 00 	movl   $0x8047fd,(%esp)
  8031ae:	e8 61 ec ff ff       	call   801e14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8031b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8031b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8031b9:	89 ec                	mov    %ebp,%esp
  8031bb:	5d                   	pop    %ebp
  8031bc:	c3                   	ret    
  8031bd:	00 00                	add    %al,(%eax)
	...

008031c0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8031c0:	55                   	push   %ebp
  8031c1:	89 e5                	mov    %esp,%ebp
  8031c3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8031c6:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8031cd:	75 30                	jne    8031ff <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8031cf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8031d6:	00 
  8031d7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8031de:	ee 
  8031df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031e6:	e8 38 fe ff ff       	call   803023 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8031eb:	c7 44 24 04 0c 32 80 	movl   $0x80320c,0x4(%esp)
  8031f2:	00 
  8031f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031fa:	e8 06 fc ff ff       	call   802e05 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8031ff:	8b 45 08             	mov    0x8(%ebp),%eax
  803202:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  803207:	c9                   	leave  
  803208:	c3                   	ret    
  803209:	00 00                	add    %al,(%eax)
	...

0080320c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80320c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80320d:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  803212:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803214:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  803217:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  80321b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  80321f:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  803222:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  803224:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  803228:	83 c4 08             	add    $0x8,%esp
        popal
  80322b:	61                   	popa   
        addl $0x4,%esp
  80322c:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  80322f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  803230:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  803231:	c3                   	ret    
	...

00803240 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803240:	55                   	push   %ebp
  803241:	89 e5                	mov    %esp,%ebp
  803243:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  803246:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80324c:	b8 01 00 00 00       	mov    $0x1,%eax
  803251:	39 ca                	cmp    %ecx,%edx
  803253:	75 04                	jne    803259 <ipc_find_env+0x19>
  803255:	b0 00                	mov    $0x0,%al
  803257:	eb 12                	jmp    80326b <ipc_find_env+0x2b>
  803259:	89 c2                	mov    %eax,%edx
  80325b:	c1 e2 07             	shl    $0x7,%edx
  80325e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  803265:	8b 12                	mov    (%edx),%edx
  803267:	39 ca                	cmp    %ecx,%edx
  803269:	75 10                	jne    80327b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80326b:	89 c2                	mov    %eax,%edx
  80326d:	c1 e2 07             	shl    $0x7,%edx
  803270:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  803277:	8b 00                	mov    (%eax),%eax
  803279:	eb 0e                	jmp    803289 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80327b:	83 c0 01             	add    $0x1,%eax
  80327e:	3d 00 04 00 00       	cmp    $0x400,%eax
  803283:	75 d4                	jne    803259 <ipc_find_env+0x19>
  803285:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  803289:	5d                   	pop    %ebp
  80328a:	c3                   	ret    

0080328b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80328b:	55                   	push   %ebp
  80328c:	89 e5                	mov    %esp,%ebp
  80328e:	57                   	push   %edi
  80328f:	56                   	push   %esi
  803290:	53                   	push   %ebx
  803291:	83 ec 1c             	sub    $0x1c,%esp
  803294:	8b 75 08             	mov    0x8(%ebp),%esi
  803297:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80329a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80329d:	85 db                	test   %ebx,%ebx
  80329f:	74 19                	je     8032ba <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8032a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8032a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8032a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8032b0:	89 34 24             	mov    %esi,(%esp)
  8032b3:	e8 0c fb ff ff       	call   802dc4 <sys_ipc_try_send>
  8032b8:	eb 1b                	jmp    8032d5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8032ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8032bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8032c1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8032c8:	ee 
  8032c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8032cd:	89 34 24             	mov    %esi,(%esp)
  8032d0:	e8 ef fa ff ff       	call   802dc4 <sys_ipc_try_send>
           if(ret == 0)
  8032d5:	85 c0                	test   %eax,%eax
  8032d7:	74 28                	je     803301 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8032d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8032dc:	74 1c                	je     8032fa <ipc_send+0x6f>
              panic("ipc send error");
  8032de:	c7 44 24 08 0b 48 80 	movl   $0x80480b,0x8(%esp)
  8032e5:	00 
  8032e6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8032ed:	00 
  8032ee:	c7 04 24 1a 48 80 00 	movl   $0x80481a,(%esp)
  8032f5:	e8 1a eb ff ff       	call   801e14 <_panic>
           sys_yield();
  8032fa:	e8 91 fd ff ff       	call   803090 <sys_yield>
        }
  8032ff:	eb 9c                	jmp    80329d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  803301:	83 c4 1c             	add    $0x1c,%esp
  803304:	5b                   	pop    %ebx
  803305:	5e                   	pop    %esi
  803306:	5f                   	pop    %edi
  803307:	5d                   	pop    %ebp
  803308:	c3                   	ret    

00803309 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803309:	55                   	push   %ebp
  80330a:	89 e5                	mov    %esp,%ebp
  80330c:	56                   	push   %esi
  80330d:	53                   	push   %ebx
  80330e:	83 ec 10             	sub    $0x10,%esp
  803311:	8b 75 08             	mov    0x8(%ebp),%esi
  803314:	8b 45 0c             	mov    0xc(%ebp),%eax
  803317:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80331a:	85 c0                	test   %eax,%eax
  80331c:	75 0e                	jne    80332c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80331e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  803325:	e8 2f fa ff ff       	call   802d59 <sys_ipc_recv>
  80332a:	eb 08                	jmp    803334 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80332c:	89 04 24             	mov    %eax,(%esp)
  80332f:	e8 25 fa ff ff       	call   802d59 <sys_ipc_recv>
        if(ret == 0){
  803334:	85 c0                	test   %eax,%eax
  803336:	75 26                	jne    80335e <ipc_recv+0x55>
           if(from_env_store)
  803338:	85 f6                	test   %esi,%esi
  80333a:	74 0a                	je     803346 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80333c:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803341:	8b 40 78             	mov    0x78(%eax),%eax
  803344:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  803346:	85 db                	test   %ebx,%ebx
  803348:	74 0a                	je     803354 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80334a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80334f:	8b 40 7c             	mov    0x7c(%eax),%eax
  803352:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  803354:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803359:	8b 40 74             	mov    0x74(%eax),%eax
  80335c:	eb 14                	jmp    803372 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80335e:	85 f6                	test   %esi,%esi
  803360:	74 06                	je     803368 <ipc_recv+0x5f>
              *from_env_store = 0;
  803362:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  803368:	85 db                	test   %ebx,%ebx
  80336a:	74 06                	je     803372 <ipc_recv+0x69>
              *perm_store = 0;
  80336c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  803372:	83 c4 10             	add    $0x10,%esp
  803375:	5b                   	pop    %ebx
  803376:	5e                   	pop    %esi
  803377:	5d                   	pop    %ebp
  803378:	c3                   	ret    
  803379:	00 00                	add    %al,(%eax)
  80337b:	00 00                	add    %al,(%eax)
  80337d:	00 00                	add    %al,(%eax)
	...

00803380 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  803380:	55                   	push   %ebp
  803381:	89 e5                	mov    %esp,%ebp
  803383:	8b 45 08             	mov    0x8(%ebp),%eax
  803386:	05 00 00 00 30       	add    $0x30000000,%eax
  80338b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80338e:	5d                   	pop    %ebp
  80338f:	c3                   	ret    

00803390 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  803390:	55                   	push   %ebp
  803391:	89 e5                	mov    %esp,%ebp
  803393:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  803396:	8b 45 08             	mov    0x8(%ebp),%eax
  803399:	89 04 24             	mov    %eax,(%esp)
  80339c:	e8 df ff ff ff       	call   803380 <fd2num>
  8033a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8033a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8033a9:	c9                   	leave  
  8033aa:	c3                   	ret    

008033ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8033ab:	55                   	push   %ebp
  8033ac:	89 e5                	mov    %esp,%ebp
  8033ae:	57                   	push   %edi
  8033af:	56                   	push   %esi
  8033b0:	53                   	push   %ebx
  8033b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8033b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8033b9:	a8 01                	test   $0x1,%al
  8033bb:	74 36                	je     8033f3 <fd_alloc+0x48>
  8033bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8033c2:	a8 01                	test   $0x1,%al
  8033c4:	74 2d                	je     8033f3 <fd_alloc+0x48>
  8033c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8033cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8033d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8033d5:	89 c3                	mov    %eax,%ebx
  8033d7:	89 c2                	mov    %eax,%edx
  8033d9:	c1 ea 16             	shr    $0x16,%edx
  8033dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8033df:	f6 c2 01             	test   $0x1,%dl
  8033e2:	74 14                	je     8033f8 <fd_alloc+0x4d>
  8033e4:	89 c2                	mov    %eax,%edx
  8033e6:	c1 ea 0c             	shr    $0xc,%edx
  8033e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8033ec:	f6 c2 01             	test   $0x1,%dl
  8033ef:	75 10                	jne    803401 <fd_alloc+0x56>
  8033f1:	eb 05                	jmp    8033f8 <fd_alloc+0x4d>
  8033f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8033f8:	89 1f                	mov    %ebx,(%edi)
  8033fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8033ff:	eb 17                	jmp    803418 <fd_alloc+0x6d>
  803401:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  803406:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80340b:	75 c8                	jne    8033d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80340d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  803413:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  803418:	5b                   	pop    %ebx
  803419:	5e                   	pop    %esi
  80341a:	5f                   	pop    %edi
  80341b:	5d                   	pop    %ebp
  80341c:	c3                   	ret    

0080341d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80341d:	55                   	push   %ebp
  80341e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  803420:	8b 45 08             	mov    0x8(%ebp),%eax
  803423:	83 f8 1f             	cmp    $0x1f,%eax
  803426:	77 36                	ja     80345e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  803428:	05 00 00 0d 00       	add    $0xd0000,%eax
  80342d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  803430:	89 c2                	mov    %eax,%edx
  803432:	c1 ea 16             	shr    $0x16,%edx
  803435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80343c:	f6 c2 01             	test   $0x1,%dl
  80343f:	74 1d                	je     80345e <fd_lookup+0x41>
  803441:	89 c2                	mov    %eax,%edx
  803443:	c1 ea 0c             	shr    $0xc,%edx
  803446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80344d:	f6 c2 01             	test   $0x1,%dl
  803450:	74 0c                	je     80345e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  803452:	8b 55 0c             	mov    0xc(%ebp),%edx
  803455:	89 02                	mov    %eax,(%edx)
  803457:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80345c:	eb 05                	jmp    803463 <fd_lookup+0x46>
  80345e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  803463:	5d                   	pop    %ebp
  803464:	c3                   	ret    

00803465 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  803465:	55                   	push   %ebp
  803466:	89 e5                	mov    %esp,%ebp
  803468:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80346b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80346e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803472:	8b 45 08             	mov    0x8(%ebp),%eax
  803475:	89 04 24             	mov    %eax,(%esp)
  803478:	e8 a0 ff ff ff       	call   80341d <fd_lookup>
  80347d:	85 c0                	test   %eax,%eax
  80347f:	78 0e                	js     80348f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803481:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803484:	8b 55 0c             	mov    0xc(%ebp),%edx
  803487:	89 50 04             	mov    %edx,0x4(%eax)
  80348a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80348f:	c9                   	leave  
  803490:	c3                   	ret    

00803491 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  803491:	55                   	push   %ebp
  803492:	89 e5                	mov    %esp,%ebp
  803494:	56                   	push   %esi
  803495:	53                   	push   %ebx
  803496:	83 ec 10             	sub    $0x10,%esp
  803499:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80349c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80349f:	b8 68 90 80 00       	mov    $0x809068,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8034a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8034a9:	be a4 48 80 00       	mov    $0x8048a4,%esi
		if (devtab[i]->dev_id == dev_id) {
  8034ae:	39 08                	cmp    %ecx,(%eax)
  8034b0:	75 10                	jne    8034c2 <dev_lookup+0x31>
  8034b2:	eb 04                	jmp    8034b8 <dev_lookup+0x27>
  8034b4:	39 08                	cmp    %ecx,(%eax)
  8034b6:	75 0a                	jne    8034c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8034b8:	89 03                	mov    %eax,(%ebx)
  8034ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8034bf:	90                   	nop
  8034c0:	eb 31                	jmp    8034f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8034c2:	83 c2 01             	add    $0x1,%edx
  8034c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8034c8:	85 c0                	test   %eax,%eax
  8034ca:	75 e8                	jne    8034b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8034cc:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8034d1:	8b 40 48             	mov    0x48(%eax),%eax
  8034d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8034d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034dc:	c7 04 24 24 48 80 00 	movl   $0x804824,(%esp)
  8034e3:	e8 e5 e9 ff ff       	call   801ecd <cprintf>
	*dev = 0;
  8034e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8034ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8034f3:	83 c4 10             	add    $0x10,%esp
  8034f6:	5b                   	pop    %ebx
  8034f7:	5e                   	pop    %esi
  8034f8:	5d                   	pop    %ebp
  8034f9:	c3                   	ret    

008034fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8034fa:	55                   	push   %ebp
  8034fb:	89 e5                	mov    %esp,%ebp
  8034fd:	53                   	push   %ebx
  8034fe:	83 ec 24             	sub    $0x24,%esp
  803501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803504:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80350b:	8b 45 08             	mov    0x8(%ebp),%eax
  80350e:	89 04 24             	mov    %eax,(%esp)
  803511:	e8 07 ff ff ff       	call   80341d <fd_lookup>
  803516:	85 c0                	test   %eax,%eax
  803518:	78 53                	js     80356d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80351a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80351d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803524:	8b 00                	mov    (%eax),%eax
  803526:	89 04 24             	mov    %eax,(%esp)
  803529:	e8 63 ff ff ff       	call   803491 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80352e:	85 c0                	test   %eax,%eax
  803530:	78 3b                	js     80356d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  803532:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803537:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80353a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80353e:	74 2d                	je     80356d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  803540:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  803543:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80354a:	00 00 00 
	stat->st_isdir = 0;
  80354d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803554:	00 00 00 
	stat->st_dev = dev;
  803557:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80355a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  803560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803564:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803567:	89 14 24             	mov    %edx,(%esp)
  80356a:	ff 50 14             	call   *0x14(%eax)
}
  80356d:	83 c4 24             	add    $0x24,%esp
  803570:	5b                   	pop    %ebx
  803571:	5d                   	pop    %ebp
  803572:	c3                   	ret    

00803573 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  803573:	55                   	push   %ebp
  803574:	89 e5                	mov    %esp,%ebp
  803576:	53                   	push   %ebx
  803577:	83 ec 24             	sub    $0x24,%esp
  80357a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80357d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803580:	89 44 24 04          	mov    %eax,0x4(%esp)
  803584:	89 1c 24             	mov    %ebx,(%esp)
  803587:	e8 91 fe ff ff       	call   80341d <fd_lookup>
  80358c:	85 c0                	test   %eax,%eax
  80358e:	78 5f                	js     8035ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803593:	89 44 24 04          	mov    %eax,0x4(%esp)
  803597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80359a:	8b 00                	mov    (%eax),%eax
  80359c:	89 04 24             	mov    %eax,(%esp)
  80359f:	e8 ed fe ff ff       	call   803491 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8035a4:	85 c0                	test   %eax,%eax
  8035a6:	78 47                	js     8035ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8035a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8035ab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8035af:	75 23                	jne    8035d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8035b1:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8035b6:	8b 40 48             	mov    0x48(%eax),%eax
  8035b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8035bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035c1:	c7 04 24 44 48 80 00 	movl   $0x804844,(%esp)
  8035c8:	e8 00 e9 ff ff       	call   801ecd <cprintf>
  8035cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8035d2:	eb 1b                	jmp    8035ef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8035d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035d7:	8b 48 18             	mov    0x18(%eax),%ecx
  8035da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8035df:	85 c9                	test   %ecx,%ecx
  8035e1:	74 0c                	je     8035ef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8035e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035ea:	89 14 24             	mov    %edx,(%esp)
  8035ed:	ff d1                	call   *%ecx
}
  8035ef:	83 c4 24             	add    $0x24,%esp
  8035f2:	5b                   	pop    %ebx
  8035f3:	5d                   	pop    %ebp
  8035f4:	c3                   	ret    

008035f5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8035f5:	55                   	push   %ebp
  8035f6:	89 e5                	mov    %esp,%ebp
  8035f8:	53                   	push   %ebx
  8035f9:	83 ec 24             	sub    $0x24,%esp
  8035fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8035ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803602:	89 44 24 04          	mov    %eax,0x4(%esp)
  803606:	89 1c 24             	mov    %ebx,(%esp)
  803609:	e8 0f fe ff ff       	call   80341d <fd_lookup>
  80360e:	85 c0                	test   %eax,%eax
  803610:	78 66                	js     803678 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803612:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803615:	89 44 24 04          	mov    %eax,0x4(%esp)
  803619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80361c:	8b 00                	mov    (%eax),%eax
  80361e:	89 04 24             	mov    %eax,(%esp)
  803621:	e8 6b fe ff ff       	call   803491 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803626:	85 c0                	test   %eax,%eax
  803628:	78 4e                	js     803678 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80362a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80362d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  803631:	75 23                	jne    803656 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  803633:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803638:	8b 40 48             	mov    0x48(%eax),%eax
  80363b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80363f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803643:	c7 04 24 68 48 80 00 	movl   $0x804868,(%esp)
  80364a:	e8 7e e8 ff ff       	call   801ecd <cprintf>
  80364f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  803654:	eb 22                	jmp    803678 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  803656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803659:	8b 48 0c             	mov    0xc(%eax),%ecx
  80365c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803661:	85 c9                	test   %ecx,%ecx
  803663:	74 13                	je     803678 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  803665:	8b 45 10             	mov    0x10(%ebp),%eax
  803668:	89 44 24 08          	mov    %eax,0x8(%esp)
  80366c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80366f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803673:	89 14 24             	mov    %edx,(%esp)
  803676:	ff d1                	call   *%ecx
}
  803678:	83 c4 24             	add    $0x24,%esp
  80367b:	5b                   	pop    %ebx
  80367c:	5d                   	pop    %ebp
  80367d:	c3                   	ret    

0080367e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80367e:	55                   	push   %ebp
  80367f:	89 e5                	mov    %esp,%ebp
  803681:	53                   	push   %ebx
  803682:	83 ec 24             	sub    $0x24,%esp
  803685:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803688:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80368b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80368f:	89 1c 24             	mov    %ebx,(%esp)
  803692:	e8 86 fd ff ff       	call   80341d <fd_lookup>
  803697:	85 c0                	test   %eax,%eax
  803699:	78 6b                	js     803706 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80369b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80369e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8036a5:	8b 00                	mov    (%eax),%eax
  8036a7:	89 04 24             	mov    %eax,(%esp)
  8036aa:	e8 e2 fd ff ff       	call   803491 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8036af:	85 c0                	test   %eax,%eax
  8036b1:	78 53                	js     803706 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8036b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8036b6:	8b 42 08             	mov    0x8(%edx),%eax
  8036b9:	83 e0 03             	and    $0x3,%eax
  8036bc:	83 f8 01             	cmp    $0x1,%eax
  8036bf:	75 23                	jne    8036e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8036c1:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8036c6:	8b 40 48             	mov    0x48(%eax),%eax
  8036c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8036cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036d1:	c7 04 24 85 48 80 00 	movl   $0x804885,(%esp)
  8036d8:	e8 f0 e7 ff ff       	call   801ecd <cprintf>
  8036dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8036e2:	eb 22                	jmp    803706 <read+0x88>
	}
	if (!dev->dev_read)
  8036e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036e7:	8b 48 08             	mov    0x8(%eax),%ecx
  8036ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8036ef:	85 c9                	test   %ecx,%ecx
  8036f1:	74 13                	je     803706 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8036f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8036f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8036fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8036fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  803701:	89 14 24             	mov    %edx,(%esp)
  803704:	ff d1                	call   *%ecx
}
  803706:	83 c4 24             	add    $0x24,%esp
  803709:	5b                   	pop    %ebx
  80370a:	5d                   	pop    %ebp
  80370b:	c3                   	ret    

0080370c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80370c:	55                   	push   %ebp
  80370d:	89 e5                	mov    %esp,%ebp
  80370f:	57                   	push   %edi
  803710:	56                   	push   %esi
  803711:	53                   	push   %ebx
  803712:	83 ec 1c             	sub    $0x1c,%esp
  803715:	8b 7d 08             	mov    0x8(%ebp),%edi
  803718:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80371b:	ba 00 00 00 00       	mov    $0x0,%edx
  803720:	bb 00 00 00 00       	mov    $0x0,%ebx
  803725:	b8 00 00 00 00       	mov    $0x0,%eax
  80372a:	85 f6                	test   %esi,%esi
  80372c:	74 29                	je     803757 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80372e:	89 f0                	mov    %esi,%eax
  803730:	29 d0                	sub    %edx,%eax
  803732:	89 44 24 08          	mov    %eax,0x8(%esp)
  803736:	03 55 0c             	add    0xc(%ebp),%edx
  803739:	89 54 24 04          	mov    %edx,0x4(%esp)
  80373d:	89 3c 24             	mov    %edi,(%esp)
  803740:	e8 39 ff ff ff       	call   80367e <read>
		if (m < 0)
  803745:	85 c0                	test   %eax,%eax
  803747:	78 0e                	js     803757 <readn+0x4b>
			return m;
		if (m == 0)
  803749:	85 c0                	test   %eax,%eax
  80374b:	74 08                	je     803755 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80374d:	01 c3                	add    %eax,%ebx
  80374f:	89 da                	mov    %ebx,%edx
  803751:	39 f3                	cmp    %esi,%ebx
  803753:	72 d9                	jb     80372e <readn+0x22>
  803755:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  803757:	83 c4 1c             	add    $0x1c,%esp
  80375a:	5b                   	pop    %ebx
  80375b:	5e                   	pop    %esi
  80375c:	5f                   	pop    %edi
  80375d:	5d                   	pop    %ebp
  80375e:	c3                   	ret    

0080375f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80375f:	55                   	push   %ebp
  803760:	89 e5                	mov    %esp,%ebp
  803762:	56                   	push   %esi
  803763:	53                   	push   %ebx
  803764:	83 ec 20             	sub    $0x20,%esp
  803767:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80376a:	89 34 24             	mov    %esi,(%esp)
  80376d:	e8 0e fc ff ff       	call   803380 <fd2num>
  803772:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803775:	89 54 24 04          	mov    %edx,0x4(%esp)
  803779:	89 04 24             	mov    %eax,(%esp)
  80377c:	e8 9c fc ff ff       	call   80341d <fd_lookup>
  803781:	89 c3                	mov    %eax,%ebx
  803783:	85 c0                	test   %eax,%eax
  803785:	78 05                	js     80378c <fd_close+0x2d>
  803787:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80378a:	74 0c                	je     803798 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80378c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  803790:	19 c0                	sbb    %eax,%eax
  803792:	f7 d0                	not    %eax
  803794:	21 c3                	and    %eax,%ebx
  803796:	eb 3d                	jmp    8037d5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  803798:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80379b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80379f:	8b 06                	mov    (%esi),%eax
  8037a1:	89 04 24             	mov    %eax,(%esp)
  8037a4:	e8 e8 fc ff ff       	call   803491 <dev_lookup>
  8037a9:	89 c3                	mov    %eax,%ebx
  8037ab:	85 c0                	test   %eax,%eax
  8037ad:	78 16                	js     8037c5 <fd_close+0x66>
		if (dev->dev_close)
  8037af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8037b2:	8b 40 10             	mov    0x10(%eax),%eax
  8037b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8037ba:	85 c0                	test   %eax,%eax
  8037bc:	74 07                	je     8037c5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8037be:	89 34 24             	mov    %esi,(%esp)
  8037c1:	ff d0                	call   *%eax
  8037c3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8037c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037d0:	e8 74 f7 ff ff       	call   802f49 <sys_page_unmap>
	return r;
}
  8037d5:	89 d8                	mov    %ebx,%eax
  8037d7:	83 c4 20             	add    $0x20,%esp
  8037da:	5b                   	pop    %ebx
  8037db:	5e                   	pop    %esi
  8037dc:	5d                   	pop    %ebp
  8037dd:	c3                   	ret    

008037de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8037de:	55                   	push   %ebp
  8037df:	89 e5                	mov    %esp,%ebp
  8037e1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8037e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8037ee:	89 04 24             	mov    %eax,(%esp)
  8037f1:	e8 27 fc ff ff       	call   80341d <fd_lookup>
  8037f6:	85 c0                	test   %eax,%eax
  8037f8:	78 13                	js     80380d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8037fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803801:	00 
  803802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803805:	89 04 24             	mov    %eax,(%esp)
  803808:	e8 52 ff ff ff       	call   80375f <fd_close>
}
  80380d:	c9                   	leave  
  80380e:	c3                   	ret    

0080380f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80380f:	55                   	push   %ebp
  803810:	89 e5                	mov    %esp,%ebp
  803812:	83 ec 18             	sub    $0x18,%esp
  803815:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  803818:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80381b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803822:	00 
  803823:	8b 45 08             	mov    0x8(%ebp),%eax
  803826:	89 04 24             	mov    %eax,(%esp)
  803829:	e8 79 03 00 00       	call   803ba7 <open>
  80382e:	89 c3                	mov    %eax,%ebx
  803830:	85 c0                	test   %eax,%eax
  803832:	78 1b                	js     80384f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  803834:	8b 45 0c             	mov    0xc(%ebp),%eax
  803837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80383b:	89 1c 24             	mov    %ebx,(%esp)
  80383e:	e8 b7 fc ff ff       	call   8034fa <fstat>
  803843:	89 c6                	mov    %eax,%esi
	close(fd);
  803845:	89 1c 24             	mov    %ebx,(%esp)
  803848:	e8 91 ff ff ff       	call   8037de <close>
  80384d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80384f:	89 d8                	mov    %ebx,%eax
  803851:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803854:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803857:	89 ec                	mov    %ebp,%esp
  803859:	5d                   	pop    %ebp
  80385a:	c3                   	ret    

0080385b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80385b:	55                   	push   %ebp
  80385c:	89 e5                	mov    %esp,%ebp
  80385e:	53                   	push   %ebx
  80385f:	83 ec 14             	sub    $0x14,%esp
  803862:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  803867:	89 1c 24             	mov    %ebx,(%esp)
  80386a:	e8 6f ff ff ff       	call   8037de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80386f:	83 c3 01             	add    $0x1,%ebx
  803872:	83 fb 20             	cmp    $0x20,%ebx
  803875:	75 f0                	jne    803867 <close_all+0xc>
		close(i);
}
  803877:	83 c4 14             	add    $0x14,%esp
  80387a:	5b                   	pop    %ebx
  80387b:	5d                   	pop    %ebp
  80387c:	c3                   	ret    

0080387d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80387d:	55                   	push   %ebp
  80387e:	89 e5                	mov    %esp,%ebp
  803880:	83 ec 58             	sub    $0x58,%esp
  803883:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  803886:	89 75 f8             	mov    %esi,-0x8(%ebp)
  803889:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80388c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80388f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803892:	89 44 24 04          	mov    %eax,0x4(%esp)
  803896:	8b 45 08             	mov    0x8(%ebp),%eax
  803899:	89 04 24             	mov    %eax,(%esp)
  80389c:	e8 7c fb ff ff       	call   80341d <fd_lookup>
  8038a1:	89 c3                	mov    %eax,%ebx
  8038a3:	85 c0                	test   %eax,%eax
  8038a5:	0f 88 e0 00 00 00    	js     80398b <dup+0x10e>
		return r;
	close(newfdnum);
  8038ab:	89 3c 24             	mov    %edi,(%esp)
  8038ae:	e8 2b ff ff ff       	call   8037de <close>

	newfd = INDEX2FD(newfdnum);
  8038b3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8038b9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8038bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038bf:	89 04 24             	mov    %eax,(%esp)
  8038c2:	e8 c9 fa ff ff       	call   803390 <fd2data>
  8038c7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8038c9:	89 34 24             	mov    %esi,(%esp)
  8038cc:	e8 bf fa ff ff       	call   803390 <fd2data>
  8038d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8038d4:	89 da                	mov    %ebx,%edx
  8038d6:	89 d8                	mov    %ebx,%eax
  8038d8:	c1 e8 16             	shr    $0x16,%eax
  8038db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8038e2:	a8 01                	test   $0x1,%al
  8038e4:	74 43                	je     803929 <dup+0xac>
  8038e6:	c1 ea 0c             	shr    $0xc,%edx
  8038e9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8038f0:	a8 01                	test   $0x1,%al
  8038f2:	74 35                	je     803929 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8038f4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8038fb:	25 07 0e 00 00       	and    $0xe07,%eax
  803900:	89 44 24 10          	mov    %eax,0x10(%esp)
  803904:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803907:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80390b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803912:	00 
  803913:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803917:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80391e:	e8 92 f6 ff ff       	call   802fb5 <sys_page_map>
  803923:	89 c3                	mov    %eax,%ebx
  803925:	85 c0                	test   %eax,%eax
  803927:	78 3f                	js     803968 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  803929:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80392c:	89 c2                	mov    %eax,%edx
  80392e:	c1 ea 0c             	shr    $0xc,%edx
  803931:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  803938:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80393e:	89 54 24 10          	mov    %edx,0x10(%esp)
  803942:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803946:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80394d:	00 
  80394e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803952:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803959:	e8 57 f6 ff ff       	call   802fb5 <sys_page_map>
  80395e:	89 c3                	mov    %eax,%ebx
  803960:	85 c0                	test   %eax,%eax
  803962:	78 04                	js     803968 <dup+0xeb>
  803964:	89 fb                	mov    %edi,%ebx
  803966:	eb 23                	jmp    80398b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  803968:	89 74 24 04          	mov    %esi,0x4(%esp)
  80396c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803973:	e8 d1 f5 ff ff       	call   802f49 <sys_page_unmap>
	sys_page_unmap(0, nva);
  803978:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80397b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80397f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803986:	e8 be f5 ff ff       	call   802f49 <sys_page_unmap>
	return r;
}
  80398b:	89 d8                	mov    %ebx,%eax
  80398d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  803990:	8b 75 f8             	mov    -0x8(%ebp),%esi
  803993:	8b 7d fc             	mov    -0x4(%ebp),%edi
  803996:	89 ec                	mov    %ebp,%esp
  803998:	5d                   	pop    %ebp
  803999:	c3                   	ret    
	...

0080399c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80399c:	55                   	push   %ebp
  80399d:	89 e5                	mov    %esp,%ebp
  80399f:	83 ec 18             	sub    $0x18,%esp
  8039a2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8039a5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8039a8:	89 c3                	mov    %eax,%ebx
  8039aa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8039ac:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  8039b3:	75 11                	jne    8039c6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8039b5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8039bc:	e8 7f f8 ff ff       	call   803240 <ipc_find_env>
  8039c1:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8039c6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8039cd:	00 
  8039ce:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  8039d5:	00 
  8039d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8039da:	a1 00 a0 80 00       	mov    0x80a000,%eax
  8039df:	89 04 24             	mov    %eax,(%esp)
  8039e2:	e8 a4 f8 ff ff       	call   80328b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8039e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8039ee:	00 
  8039ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8039f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8039fa:	e8 0a f9 ff ff       	call   803309 <ipc_recv>
}
  8039ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803a02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803a05:	89 ec                	mov    %ebp,%esp
  803a07:	5d                   	pop    %ebp
  803a08:	c3                   	ret    

00803a09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  803a09:	55                   	push   %ebp
  803a0a:	89 e5                	mov    %esp,%ebp
  803a0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  803a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  803a12:	8b 40 0c             	mov    0xc(%eax),%eax
  803a15:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  803a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a1d:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  803a22:	ba 00 00 00 00       	mov    $0x0,%edx
  803a27:	b8 02 00 00 00       	mov    $0x2,%eax
  803a2c:	e8 6b ff ff ff       	call   80399c <fsipc>
}
  803a31:	c9                   	leave  
  803a32:	c3                   	ret    

00803a33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  803a33:	55                   	push   %ebp
  803a34:	89 e5                	mov    %esp,%ebp
  803a36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803a39:	8b 45 08             	mov    0x8(%ebp),%eax
  803a3c:	8b 40 0c             	mov    0xc(%eax),%eax
  803a3f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  803a44:	ba 00 00 00 00       	mov    $0x0,%edx
  803a49:	b8 06 00 00 00       	mov    $0x6,%eax
  803a4e:	e8 49 ff ff ff       	call   80399c <fsipc>
}
  803a53:	c9                   	leave  
  803a54:	c3                   	ret    

00803a55 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  803a55:	55                   	push   %ebp
  803a56:	89 e5                	mov    %esp,%ebp
  803a58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  803a60:	b8 08 00 00 00       	mov    $0x8,%eax
  803a65:	e8 32 ff ff ff       	call   80399c <fsipc>
}
  803a6a:	c9                   	leave  
  803a6b:	c3                   	ret    

00803a6c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  803a6c:	55                   	push   %ebp
  803a6d:	89 e5                	mov    %esp,%ebp
  803a6f:	53                   	push   %ebx
  803a70:	83 ec 14             	sub    $0x14,%esp
  803a73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803a76:	8b 45 08             	mov    0x8(%ebp),%eax
  803a79:	8b 40 0c             	mov    0xc(%eax),%eax
  803a7c:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803a81:	ba 00 00 00 00       	mov    $0x0,%edx
  803a86:	b8 05 00 00 00       	mov    $0x5,%eax
  803a8b:	e8 0c ff ff ff       	call   80399c <fsipc>
  803a90:	85 c0                	test   %eax,%eax
  803a92:	78 2b                	js     803abf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803a94:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803a9b:	00 
  803a9c:	89 1c 24             	mov    %ebx,(%esp)
  803a9f:	e8 56 ed ff ff       	call   8027fa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803aa4:	a1 80 b0 80 00       	mov    0x80b080,%eax
  803aa9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803aaf:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803ab4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  803aba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  803abf:	83 c4 14             	add    $0x14,%esp
  803ac2:	5b                   	pop    %ebx
  803ac3:	5d                   	pop    %ebp
  803ac4:	c3                   	ret    

00803ac5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803ac5:	55                   	push   %ebp
  803ac6:	89 e5                	mov    %esp,%ebp
  803ac8:	83 ec 18             	sub    $0x18,%esp
  803acb:	8b 45 10             	mov    0x10(%ebp),%eax
  803ace:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  803ad3:	76 05                	jbe    803ada <devfile_write+0x15>
  803ad5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  803ada:	8b 55 08             	mov    0x8(%ebp),%edx
  803add:	8b 52 0c             	mov    0xc(%edx),%edx
  803ae0:	89 15 00 b0 80 00    	mov    %edx,0x80b000
        fsipcbuf.write.req_n = n;
  803ae6:	a3 04 b0 80 00       	mov    %eax,0x80b004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  803aeb:	89 44 24 08          	mov    %eax,0x8(%esp)
  803aef:	8b 45 0c             	mov    0xc(%ebp),%eax
  803af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  803af6:	c7 04 24 08 b0 80 00 	movl   $0x80b008,(%esp)
  803afd:	e8 e3 ee ff ff       	call   8029e5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  803b02:	ba 00 00 00 00       	mov    $0x0,%edx
  803b07:	b8 04 00 00 00       	mov    $0x4,%eax
  803b0c:	e8 8b fe ff ff       	call   80399c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  803b11:	c9                   	leave  
  803b12:	c3                   	ret    

00803b13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  803b13:	55                   	push   %ebp
  803b14:	89 e5                	mov    %esp,%ebp
  803b16:	53                   	push   %ebx
  803b17:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  803b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  803b1d:	8b 40 0c             	mov    0xc(%eax),%eax
  803b20:	a3 00 b0 80 00       	mov    %eax,0x80b000
        fsipcbuf.read.req_n = n;
  803b25:	8b 45 10             	mov    0x10(%ebp),%eax
  803b28:	a3 04 b0 80 00       	mov    %eax,0x80b004
        r = fsipc(FSREQ_READ,NULL);
  803b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  803b32:	b8 03 00 00 00       	mov    $0x3,%eax
  803b37:	e8 60 fe ff ff       	call   80399c <fsipc>
  803b3c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  803b3e:	85 c0                	test   %eax,%eax
  803b40:	78 17                	js     803b59 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  803b42:	89 44 24 08          	mov    %eax,0x8(%esp)
  803b46:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803b4d:	00 
  803b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803b51:	89 04 24             	mov    %eax,(%esp)
  803b54:	e8 8c ee ff ff       	call   8029e5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  803b59:	89 d8                	mov    %ebx,%eax
  803b5b:	83 c4 14             	add    $0x14,%esp
  803b5e:	5b                   	pop    %ebx
  803b5f:	5d                   	pop    %ebp
  803b60:	c3                   	ret    

00803b61 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  803b61:	55                   	push   %ebp
  803b62:	89 e5                	mov    %esp,%ebp
  803b64:	53                   	push   %ebx
  803b65:	83 ec 14             	sub    $0x14,%esp
  803b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  803b6b:	89 1c 24             	mov    %ebx,(%esp)
  803b6e:	e8 3d ec ff ff       	call   8027b0 <strlen>
  803b73:	89 c2                	mov    %eax,%edx
  803b75:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  803b7a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  803b80:	7f 1f                	jg     803ba1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  803b82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803b86:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  803b8d:	e8 68 ec ff ff       	call   8027fa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  803b92:	ba 00 00 00 00       	mov    $0x0,%edx
  803b97:	b8 07 00 00 00       	mov    $0x7,%eax
  803b9c:	e8 fb fd ff ff       	call   80399c <fsipc>
}
  803ba1:	83 c4 14             	add    $0x14,%esp
  803ba4:	5b                   	pop    %ebx
  803ba5:	5d                   	pop    %ebp
  803ba6:	c3                   	ret    

00803ba7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803ba7:	55                   	push   %ebp
  803ba8:	89 e5                	mov    %esp,%ebp
  803baa:	83 ec 28             	sub    $0x28,%esp
  803bad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  803bb0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  803bb3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  803bb6:	89 34 24             	mov    %esi,(%esp)
  803bb9:	e8 f2 eb ff ff       	call   8027b0 <strlen>
  803bbe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  803bc3:	3d 00 04 00 00       	cmp    $0x400,%eax
  803bc8:	7f 6d                	jg     803c37 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  803bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803bcd:	89 04 24             	mov    %eax,(%esp)
  803bd0:	e8 d6 f7 ff ff       	call   8033ab <fd_alloc>
  803bd5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  803bd7:	85 c0                	test   %eax,%eax
  803bd9:	78 5c                	js     803c37 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  803bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  803bde:	a3 00 b4 80 00       	mov    %eax,0x80b400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  803be3:	89 34 24             	mov    %esi,(%esp)
  803be6:	e8 c5 eb ff ff       	call   8027b0 <strlen>
  803beb:	83 c0 01             	add    $0x1,%eax
  803bee:	89 44 24 08          	mov    %eax,0x8(%esp)
  803bf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  803bf6:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  803bfd:	e8 e3 ed ff ff       	call   8029e5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  803c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803c05:	b8 01 00 00 00       	mov    $0x1,%eax
  803c0a:	e8 8d fd ff ff       	call   80399c <fsipc>
  803c0f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  803c11:	85 c0                	test   %eax,%eax
  803c13:	79 15                	jns    803c2a <open+0x83>
             fd_close(fd,0);
  803c15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803c1c:	00 
  803c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803c20:	89 04 24             	mov    %eax,(%esp)
  803c23:	e8 37 fb ff ff       	call   80375f <fd_close>
             return r;
  803c28:	eb 0d                	jmp    803c37 <open+0x90>
        }
        return fd2num(fd);
  803c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803c2d:	89 04 24             	mov    %eax,(%esp)
  803c30:	e8 4b f7 ff ff       	call   803380 <fd2num>
  803c35:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  803c37:	89 d8                	mov    %ebx,%eax
  803c39:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803c3c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803c3f:	89 ec                	mov    %ebp,%esp
  803c41:	5d                   	pop    %ebp
  803c42:	c3                   	ret    
	...

00803c44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803c44:	55                   	push   %ebp
  803c45:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  803c47:	8b 45 08             	mov    0x8(%ebp),%eax
  803c4a:	89 c2                	mov    %eax,%edx
  803c4c:	c1 ea 16             	shr    $0x16,%edx
  803c4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  803c56:	f6 c2 01             	test   $0x1,%dl
  803c59:	74 20                	je     803c7b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  803c5b:	c1 e8 0c             	shr    $0xc,%eax
  803c5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803c65:	a8 01                	test   $0x1,%al
  803c67:	74 12                	je     803c7b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803c69:	c1 e8 0c             	shr    $0xc,%eax
  803c6c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  803c71:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  803c76:	0f b7 c0             	movzwl %ax,%eax
  803c79:	eb 05                	jmp    803c80 <pageref+0x3c>
  803c7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803c80:	5d                   	pop    %ebp
  803c81:	c3                   	ret    
	...

00803c90 <__udivdi3>:
  803c90:	55                   	push   %ebp
  803c91:	89 e5                	mov    %esp,%ebp
  803c93:	57                   	push   %edi
  803c94:	56                   	push   %esi
  803c95:	83 ec 10             	sub    $0x10,%esp
  803c98:	8b 45 14             	mov    0x14(%ebp),%eax
  803c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  803c9e:	8b 75 10             	mov    0x10(%ebp),%esi
  803ca1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803ca4:	85 c0                	test   %eax,%eax
  803ca6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  803ca9:	75 35                	jne    803ce0 <__udivdi3+0x50>
  803cab:	39 fe                	cmp    %edi,%esi
  803cad:	77 61                	ja     803d10 <__udivdi3+0x80>
  803caf:	85 f6                	test   %esi,%esi
  803cb1:	75 0b                	jne    803cbe <__udivdi3+0x2e>
  803cb3:	b8 01 00 00 00       	mov    $0x1,%eax
  803cb8:	31 d2                	xor    %edx,%edx
  803cba:	f7 f6                	div    %esi
  803cbc:	89 c6                	mov    %eax,%esi
  803cbe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  803cc1:	31 d2                	xor    %edx,%edx
  803cc3:	89 f8                	mov    %edi,%eax
  803cc5:	f7 f6                	div    %esi
  803cc7:	89 c7                	mov    %eax,%edi
  803cc9:	89 c8                	mov    %ecx,%eax
  803ccb:	f7 f6                	div    %esi
  803ccd:	89 c1                	mov    %eax,%ecx
  803ccf:	89 fa                	mov    %edi,%edx
  803cd1:	89 c8                	mov    %ecx,%eax
  803cd3:	83 c4 10             	add    $0x10,%esp
  803cd6:	5e                   	pop    %esi
  803cd7:	5f                   	pop    %edi
  803cd8:	5d                   	pop    %ebp
  803cd9:	c3                   	ret    
  803cda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803ce0:	39 f8                	cmp    %edi,%eax
  803ce2:	77 1c                	ja     803d00 <__udivdi3+0x70>
  803ce4:	0f bd d0             	bsr    %eax,%edx
  803ce7:	83 f2 1f             	xor    $0x1f,%edx
  803cea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803ced:	75 39                	jne    803d28 <__udivdi3+0x98>
  803cef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  803cf2:	0f 86 a0 00 00 00    	jbe    803d98 <__udivdi3+0x108>
  803cf8:	39 f8                	cmp    %edi,%eax
  803cfa:	0f 82 98 00 00 00    	jb     803d98 <__udivdi3+0x108>
  803d00:	31 ff                	xor    %edi,%edi
  803d02:	31 c9                	xor    %ecx,%ecx
  803d04:	89 c8                	mov    %ecx,%eax
  803d06:	89 fa                	mov    %edi,%edx
  803d08:	83 c4 10             	add    $0x10,%esp
  803d0b:	5e                   	pop    %esi
  803d0c:	5f                   	pop    %edi
  803d0d:	5d                   	pop    %ebp
  803d0e:	c3                   	ret    
  803d0f:	90                   	nop
  803d10:	89 d1                	mov    %edx,%ecx
  803d12:	89 fa                	mov    %edi,%edx
  803d14:	89 c8                	mov    %ecx,%eax
  803d16:	31 ff                	xor    %edi,%edi
  803d18:	f7 f6                	div    %esi
  803d1a:	89 c1                	mov    %eax,%ecx
  803d1c:	89 fa                	mov    %edi,%edx
  803d1e:	89 c8                	mov    %ecx,%eax
  803d20:	83 c4 10             	add    $0x10,%esp
  803d23:	5e                   	pop    %esi
  803d24:	5f                   	pop    %edi
  803d25:	5d                   	pop    %ebp
  803d26:	c3                   	ret    
  803d27:	90                   	nop
  803d28:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803d2c:	89 f2                	mov    %esi,%edx
  803d2e:	d3 e0                	shl    %cl,%eax
  803d30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803d33:	b8 20 00 00 00       	mov    $0x20,%eax
  803d38:	2b 45 f4             	sub    -0xc(%ebp),%eax
  803d3b:	89 c1                	mov    %eax,%ecx
  803d3d:	d3 ea                	shr    %cl,%edx
  803d3f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803d43:	0b 55 ec             	or     -0x14(%ebp),%edx
  803d46:	d3 e6                	shl    %cl,%esi
  803d48:	89 c1                	mov    %eax,%ecx
  803d4a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  803d4d:	89 fe                	mov    %edi,%esi
  803d4f:	d3 ee                	shr    %cl,%esi
  803d51:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803d55:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803d58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803d5b:	d3 e7                	shl    %cl,%edi
  803d5d:	89 c1                	mov    %eax,%ecx
  803d5f:	d3 ea                	shr    %cl,%edx
  803d61:	09 d7                	or     %edx,%edi
  803d63:	89 f2                	mov    %esi,%edx
  803d65:	89 f8                	mov    %edi,%eax
  803d67:	f7 75 ec             	divl   -0x14(%ebp)
  803d6a:	89 d6                	mov    %edx,%esi
  803d6c:	89 c7                	mov    %eax,%edi
  803d6e:	f7 65 e8             	mull   -0x18(%ebp)
  803d71:	39 d6                	cmp    %edx,%esi
  803d73:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803d76:	72 30                	jb     803da8 <__udivdi3+0x118>
  803d78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803d7b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803d7f:	d3 e2                	shl    %cl,%edx
  803d81:	39 c2                	cmp    %eax,%edx
  803d83:	73 05                	jae    803d8a <__udivdi3+0xfa>
  803d85:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  803d88:	74 1e                	je     803da8 <__udivdi3+0x118>
  803d8a:	89 f9                	mov    %edi,%ecx
  803d8c:	31 ff                	xor    %edi,%edi
  803d8e:	e9 71 ff ff ff       	jmp    803d04 <__udivdi3+0x74>
  803d93:	90                   	nop
  803d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803d98:	31 ff                	xor    %edi,%edi
  803d9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  803d9f:	e9 60 ff ff ff       	jmp    803d04 <__udivdi3+0x74>
  803da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803da8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  803dab:	31 ff                	xor    %edi,%edi
  803dad:	89 c8                	mov    %ecx,%eax
  803daf:	89 fa                	mov    %edi,%edx
  803db1:	83 c4 10             	add    $0x10,%esp
  803db4:	5e                   	pop    %esi
  803db5:	5f                   	pop    %edi
  803db6:	5d                   	pop    %ebp
  803db7:	c3                   	ret    
	...

00803dc0 <__umoddi3>:
  803dc0:	55                   	push   %ebp
  803dc1:	89 e5                	mov    %esp,%ebp
  803dc3:	57                   	push   %edi
  803dc4:	56                   	push   %esi
  803dc5:	83 ec 20             	sub    $0x20,%esp
  803dc8:	8b 55 14             	mov    0x14(%ebp),%edx
  803dcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803dce:	8b 7d 10             	mov    0x10(%ebp),%edi
  803dd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  803dd4:	85 d2                	test   %edx,%edx
  803dd6:	89 c8                	mov    %ecx,%eax
  803dd8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  803ddb:	75 13                	jne    803df0 <__umoddi3+0x30>
  803ddd:	39 f7                	cmp    %esi,%edi
  803ddf:	76 3f                	jbe    803e20 <__umoddi3+0x60>
  803de1:	89 f2                	mov    %esi,%edx
  803de3:	f7 f7                	div    %edi
  803de5:	89 d0                	mov    %edx,%eax
  803de7:	31 d2                	xor    %edx,%edx
  803de9:	83 c4 20             	add    $0x20,%esp
  803dec:	5e                   	pop    %esi
  803ded:	5f                   	pop    %edi
  803dee:	5d                   	pop    %ebp
  803def:	c3                   	ret    
  803df0:	39 f2                	cmp    %esi,%edx
  803df2:	77 4c                	ja     803e40 <__umoddi3+0x80>
  803df4:	0f bd ca             	bsr    %edx,%ecx
  803df7:	83 f1 1f             	xor    $0x1f,%ecx
  803dfa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  803dfd:	75 51                	jne    803e50 <__umoddi3+0x90>
  803dff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  803e02:	0f 87 e0 00 00 00    	ja     803ee8 <__umoddi3+0x128>
  803e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e0b:	29 f8                	sub    %edi,%eax
  803e0d:	19 d6                	sbb    %edx,%esi
  803e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e15:	89 f2                	mov    %esi,%edx
  803e17:	83 c4 20             	add    $0x20,%esp
  803e1a:	5e                   	pop    %esi
  803e1b:	5f                   	pop    %edi
  803e1c:	5d                   	pop    %ebp
  803e1d:	c3                   	ret    
  803e1e:	66 90                	xchg   %ax,%ax
  803e20:	85 ff                	test   %edi,%edi
  803e22:	75 0b                	jne    803e2f <__umoddi3+0x6f>
  803e24:	b8 01 00 00 00       	mov    $0x1,%eax
  803e29:	31 d2                	xor    %edx,%edx
  803e2b:	f7 f7                	div    %edi
  803e2d:	89 c7                	mov    %eax,%edi
  803e2f:	89 f0                	mov    %esi,%eax
  803e31:	31 d2                	xor    %edx,%edx
  803e33:	f7 f7                	div    %edi
  803e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e38:	f7 f7                	div    %edi
  803e3a:	eb a9                	jmp    803de5 <__umoddi3+0x25>
  803e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803e40:	89 c8                	mov    %ecx,%eax
  803e42:	89 f2                	mov    %esi,%edx
  803e44:	83 c4 20             	add    $0x20,%esp
  803e47:	5e                   	pop    %esi
  803e48:	5f                   	pop    %edi
  803e49:	5d                   	pop    %ebp
  803e4a:	c3                   	ret    
  803e4b:	90                   	nop
  803e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803e50:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803e54:	d3 e2                	shl    %cl,%edx
  803e56:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803e59:	ba 20 00 00 00       	mov    $0x20,%edx
  803e5e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  803e61:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803e64:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803e68:	89 fa                	mov    %edi,%edx
  803e6a:	d3 ea                	shr    %cl,%edx
  803e6c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803e70:	0b 55 f4             	or     -0xc(%ebp),%edx
  803e73:	d3 e7                	shl    %cl,%edi
  803e75:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803e79:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803e7c:	89 f2                	mov    %esi,%edx
  803e7e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  803e81:	89 c7                	mov    %eax,%edi
  803e83:	d3 ea                	shr    %cl,%edx
  803e85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803e89:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  803e8c:	89 c2                	mov    %eax,%edx
  803e8e:	d3 e6                	shl    %cl,%esi
  803e90:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803e94:	d3 ea                	shr    %cl,%edx
  803e96:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803e9a:	09 d6                	or     %edx,%esi
  803e9c:	89 f0                	mov    %esi,%eax
  803e9e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  803ea1:	d3 e7                	shl    %cl,%edi
  803ea3:	89 f2                	mov    %esi,%edx
  803ea5:	f7 75 f4             	divl   -0xc(%ebp)
  803ea8:	89 d6                	mov    %edx,%esi
  803eaa:	f7 65 e8             	mull   -0x18(%ebp)
  803ead:	39 d6                	cmp    %edx,%esi
  803eaf:	72 2b                	jb     803edc <__umoddi3+0x11c>
  803eb1:	39 c7                	cmp    %eax,%edi
  803eb3:	72 23                	jb     803ed8 <__umoddi3+0x118>
  803eb5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803eb9:	29 c7                	sub    %eax,%edi
  803ebb:	19 d6                	sbb    %edx,%esi
  803ebd:	89 f0                	mov    %esi,%eax
  803ebf:	89 f2                	mov    %esi,%edx
  803ec1:	d3 ef                	shr    %cl,%edi
  803ec3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803ec7:	d3 e0                	shl    %cl,%eax
  803ec9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803ecd:	09 f8                	or     %edi,%eax
  803ecf:	d3 ea                	shr    %cl,%edx
  803ed1:	83 c4 20             	add    $0x20,%esp
  803ed4:	5e                   	pop    %esi
  803ed5:	5f                   	pop    %edi
  803ed6:	5d                   	pop    %ebp
  803ed7:	c3                   	ret    
  803ed8:	39 d6                	cmp    %edx,%esi
  803eda:	75 d9                	jne    803eb5 <__umoddi3+0xf5>
  803edc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  803edf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  803ee2:	eb d1                	jmp    803eb5 <__umoddi3+0xf5>
  803ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803ee8:	39 f2                	cmp    %esi,%edx
  803eea:	0f 82 18 ff ff ff    	jb     803e08 <__umoddi3+0x48>
  803ef0:	e9 1d ff ff ff       	jmp    803e12 <__umoddi3+0x52>
