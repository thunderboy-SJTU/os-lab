#include "ns.h"
#include <inc/lib.h>
#include <kern/e1000.h>

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
        int r = 0;
        struct tx_desc td;
        while(1){            
            r = sys_ipc_recv(&nsipcbuf);
            if(r != 0 || thisenv->env_ipc_from != ns_envid || thisenv->env_ipc_value != NSREQ_OUTPUT)
                continue;
          
            uint32_t addr = (uint32_t)nsipcbuf.pkt.jp_data;
            uint32_t length = nsipcbuf.pkt.jp_len;
            r = sys_transmit_packet(addr,length);
            if(r < 0)
               panic("transmit_packet error\n");
            }
         
}
