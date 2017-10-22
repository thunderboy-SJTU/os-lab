// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>
#include <kern/env.h>


#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
        { "time", "get cycles",mon_time },
        { "showmappings", "show address mappings",mon_showmappings},
        { "changeperm", "change permission of pages",mon_changeperm},
        { "dump","show memory data with virtual or physical address",mon_dump},
        { "c","continue",mon_c},
        { "si","next step",mon_si},
        { "x","show memory",mon_x},
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int 
mon_x(int argc,char **argv,struct Trapframe *tf){
   if(argc != 2)
     cprintf("Usage: x [addr]\n");   
   else if(tf == NULL)
     cprintf("trapframe error\n");
   else{
       uint32_t addr = strtol(argv[1],0,0);
       uint32_t value = 0; 
       value = *((uint32_t*)addr);
       cprintf("%d\n",value);
    }
    return 0;
}

int 
mon_si(int argc,char **argv,struct Trapframe *tf){
  if(argc != 1)
    cprintf("Usage: si\n");
  else if(tf == NULL)
    cprintf("trapframe error\n");
  else{
    struct Eipdebuginfo info;
    tf->tf_eflags = tf->tf_eflags | 0x100;
    cprintf("tf_eip=%08x\n",tf->tf_eip);
    debuginfo_eip(tf->tf_eip,&info);
    cprintf("%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,tf->tf_eip-info.eip_fn_addr);
    curenv->env_tf = *tf;		
    tf = &curenv->env_tf;
    env_run(curenv);
  }
  return 0;
}

int 
mon_c(int argc,char **argv,struct Trapframe *tf){
  if(argc != 1)
    cprintf("Usage: c\n");
  else if(tf == NULL)
    cprintf("trapframe error\n");
  else{
     curenv->env_tf = *tf;		
     tf = &curenv->env_tf;
     env_run(curenv);
  }

  return 0;
} 


int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
	return 0;
}


static uint64_t rdtsc() {
    uint32_t lo,hi;
   __asm__ __volatile__
   (
      "rdtsc":"=a"(lo),"=d"(hi)
   );
   return (uint64_t) hi<<32|lo;    
}

int 
mon_time(int argc, char**argv,struct Trapframe *tf)
{
   int i;
   int ret;
   int flag = 0;
   uint64_t begin;
   uint64_t end;
   for(i = 0;i<NCOMMANDS;i++){
       if(strcmp(argv[1],commands[i].name) == 0){
          begin = rdtsc();
          ret = (commands[i].func)(argc-1,&argv[1],tf);
          end = rdtsc();
          cprintf("%s cycles: %d\n",commands[i].name,end-begin);
          flag = 1;
          break;
       }
   }
   if(flag == 0)
     cprintf("no such command %s\n",argv[1]);
   return 0;
}

int 
mon_showmappings(int argc,char**argv,struct Trapframe *tf)
{
   if(argc != 3)
      return 0;
   uintptr_t begin = strtol(argv[1],0,0);
   uintptr_t end = strtol(argv[2],0,0);
   if(begin > end || begin != ROUNDUP(begin,PGSIZE)){
      cprintf("wrong virtual address\n");
      return 0;
   }
   while(begin < end){
      pte_t* pte = pgdir_walk(kern_pgdir,(void*)begin,0);
      if(pte && ((*pte) & PTE_P)&&((*pte) & PTE_PS)){
          cprintf("0x%08x - 0x%08x   ",begin,begin+PTSIZE-1);
          cprintf("0x%08x - 0x%08x   ",PTE_ADDR(*pte),PTE_ADDR(*pte)+PTSIZE-1);
          cprintf("kernel:");
          if((*pte)& PTE_W)
            cprintf("R/W  ");
          else
            cprintf("R/-  ");
          cprintf("user:");
          if((*pte)& PTE_U){
              if((*pte)& PTE_W)
                cprintf("R/W  \n");
              else
                cprintf("R/-  \n");
          }
          else
            cprintf("-/-  \n");
          if(begin + PTSIZE < begin)
            break;
          begin += PTSIZE;
      }
      else if(pte && ((*pte) & PTE_P)){
          cprintf("0x%08x - 0x%08x   ",begin,begin+PGSIZE-1);
          cprintf("0x%08x - 0x%08x   ",PTE_ADDR(*pte),PTE_ADDR(*pte)+PGSIZE-1);
          cprintf("kernel:");
          if((*pte)& PTE_W)
            cprintf("R/W  ");
          else
            cprintf("R/-  ");
          cprintf("user:");
          if((*pte)& PTE_U){
              if((*pte)& PTE_W)
                cprintf("R/W  \n");
              else
                cprintf("R/-  \n");
          }
          else
            cprintf("-/-  \n");
          if(begin + PGSIZE < begin)
             break;
          begin += PGSIZE;
      }
      else{
          if(begin + PGSIZE < begin)
            break;
          begin += PGSIZE;
      }
   }
   return 0;
}

int 
mon_changeperm(int argc,char**argv,struct Trapframe *tf)
{
    if(argc != 3 && argc != 4){
      cprintf("Usage: changeperm [op] [addr] ([perm])\n");
      return 0;
    }
    char* op = argv[1];
    uintptr_t addr = strtol(argv[2],0,0);
    pte_t* pte = pgdir_walk(kern_pgdir,(void*)addr,1);
    if(pte == NULL){
       cprintf("pte error\n");
       return 0;
    }
    if(strcmp(op,"set") == 0 || strcmp(op,"change") == 0){
       if(argc != 4){
         cprintf("Usage: changeperm [op] [addr] ([perm])\n");
         return 0;
       }
       uintptr_t perm = strtol(argv[3],0,0);
       if((perm & 0x00000FFF) != perm){
          cprintf("wrong perm\n");
          return 0;
       }
       *pte = ((*pte)& 0xFFFFF000) | perm;
    }
    else if(strcmp(op,"clear") == 0){
       if(argc != 3){
         cprintf("Usage: changeperm [op] [addr] ([perm])\n");
         return 0;
       }
       *pte = ((*pte)& 0xFFFFF000);
    }
    else{
      cprintf("Usage: changeperm [op] [addr] ([perm])\n");
      return 0;
    }
    cprintf("success\n");
    return 0;
}

int 
mon_dump(int argc,char** argv,struct Trapframe* tf)
{
   if(argc != 4){
      cprintf("Usage: dump [op] [addr] [size]\n");
      return 0;
   }
   char* op = argv[1];
   uint32_t size = strtol(argv[3],0,0);
   uint32_t value = 0;
   if(strcmp(op,"v") == 0){
      uintptr_t addr = strtol(argv[2],0,0); 
      if(addr != ROUNDUP(addr,PGSIZE)){
        cprintf("wrong address\n");
        return 0;
      }     
      int i = 0;
      for(i = 0; i<size;i++){
        if(addr + i*4 < addr + (i-1)*4 && i != 0)
            break;
        if(i%4 == 0){
          if(i != 0)
             cprintf("\n");
          cprintf("0x%08x: ",addr + i*4);
        }
        pte_t* pte = pgdir_walk(kern_pgdir,(void*)(addr+i*4),0);
        if((!pte) || (!(*pte) & PTE_P))
            cprintf("--         ");
        else{
          value = *((uint32_t*)(addr + i*4));
          cprintf("0x%08x ",value);
        }
      }
      cprintf("\n");
    }
    else if(strcmp(op,"p") == 0){
        physaddr_t addr = strtol(argv[2],0,0); 
        if(addr != ROUNDUP(addr,PGSIZE)){
           cprintf("wrong address\n");
           return 0;
        }  
        uintptr_t vaddr = 0;   
        int i = 0;       
        for(i = 0; i<size;i++){
          if(addr + i*4 < addr + (i-1)*4 && i != 0)
              break;
          if(i%4 == 0){
             if(i != 0)
               cprintf("\n");
             cprintf("0x%08x: ",addr + i*4);
          }
          vaddr = (uintptr_t)KADDR(addr + i*4);
          pte_t* pte = pgdir_walk(kern_pgdir,(void*)(vaddr+i*4),0);
          if((!pte) || (!(*pte) & PTE_P))
              cprintf("--         ");
          else{
            value = *((uint32_t*)(vaddr));
            cprintf("0x%08x ",value);
          }
        }
         cprintf("\n");
    }
    else{
        cprintf("Usage: dump [op] [addr] [size]\n");
        return 0;
    }
    return 0;
}
   
       
 

// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
    return pretaddr;
    
}

void
do_overflow(void)
{
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
	// You should use a techique similar to buffer overflow
	// to invoke the do_overflow function and
	// the procedure must return normally.

    // And you must use the "cprintf" function with %n specifier
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

    char str[256] = {};
    int nstr = 0;
    char *pret_addr;
    int i = 0;
    pret_addr = (char*)read_pretaddr();
    uint32_t oldret = *((uint32_t*)pret_addr);
    uint32_t overflowaddr = (uint32_t)do_overflow;
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&overflowaddr);
       unsigned char num = (unsigned char)((*(addr + i)) &0xFF);
       for(j = 0; j<num;j++)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + i);
    }
    for(i = 0;i<4;i++){
       unsigned int j;
       for(j = 0;j<256;j++)
           str[j] = 0;
       char* addr = (char*)(&oldret);
       unsigned char num = (unsigned char)((*(addr + i))&0xFF);
       for(j = 0; j<num;j++)
           str[j] = ' ';
       cprintf("%s%n\n",str,pret_addr + 4 + i);
    }
    

	// Your code here.
}

void
overflow_me(void)
{
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
    overflow_me();
    cprintf("Stack backtrace:\n");
    uint32_t* ebp = (uint32_t*)read_ebp();
    struct Eipdebuginfo info;
    while(ebp != 0){
    int i = 0;
    cprintf("eip %08x  ebp %08x  ",ebp[1],ebp);
    debuginfo_eip(ebp[1],&info);
    cprintf("args ");
    for(i = 0; i< 5;i++){
       cprintf("%08x ",ebp[i+2]);
    }
    cprintf("\n");
    cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
    ebp = (uint32_t*)(*(ebp));
    }
    cprintf("Backtrace success\n");
    return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;
        if(tf == NULL){
	   cprintf("Welcome to the JOS kernel monitor!\n");
	   cprintf("Type 'help' for a list of commands.\n");
        }

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}

// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
	return callerpc;
}
