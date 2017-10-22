#include <kern/e1000.h>
#include <kern/pmap.h>
#include <inc/string.h>

// LAB 6: Your driver code here

volatile uint32_t* tdh;
volatile uint32_t* tdt;
volatile uint32_t* rdh;
volatile uint32_t* rdt;
struct tx_desc tx_table[TXDESC_LENGTH];
struct rx_desc rx_table[RXDESC_LENGTH];
struct rcvbuf rx_buf[RXDESC_LENGTH];

static int init_table(){
     int i;
     memset(tx_table,0,sizeof(struct tx_desc)*TXDESC_LENGTH);
     for(i = 0; i<TXDESC_LENGTH;i++)
        tx_table[i].status |= E1000_TXD_STAT_DD;
     memset(rx_table,0,sizeof(struct rx_desc)*RXDESC_LENGTH);
     for(i = 0; i<RXDESC_LENGTH;i++)
        rx_table[i].buffer_addr = PADDR(rx_buf[i].buf);
     return 0;
}

int pci_e1000_attach(struct pci_func *pcif)
{
    pci_func_enable(pcif);
    base = e1000_map_region(pcif->reg_base[0],pcif->reg_size[0]);
    //cprintf("test:%08x\n",*(uint32_t*)E1000_REG(base,0x00008));
    init_table();
    uintptr_t tdbal = E1000_REG(base,E1000_TDBAL);
    *(uint32_t*)tdbal = PADDR(tx_table);
    uintptr_t tdbah = E1000_REG(base,E1000_TDBAH);
    *(uint32_t*)tdbah = 0;
    uintptr_t tdlen = E1000_REG(base,E1000_TDLEN);
    *(uint32_t*)tdlen = sizeof(struct tx_desc)*TXDESC_LENGTH;
    tdh = (uint32_t*)E1000_REG(base,E1000_TDH);
    *tdh = 0;
    tdt = (uint32_t*)E1000_REG(base,E1000_TDT);
    *tdt = 0;
    uintptr_t tctl = E1000_REG(base,E1000_TCTL);
    uint32_t tmp = 0;
    tmp |= E1000_TCTL_EN;
    tmp |= E1000_TCTL_PSP;
    tmp |= 0x40 << 12;   //E1000_TCTL_COLD  = 0x003ff000
    *(uint32_t*)tctl = tmp;
    uintptr_t tipg = E1000_REG(base,E1000_TIPG);
    tmp = 0;
    tmp |= 10;
    tmp |= 4 << 10;
    tmp |= 6 << 20;
    *(uint32_t*)tipg = tmp;
    /*struct tx_desc td;
    transmit_packet(&td);*/
    uintptr_t ral = E1000_REG(base,E1000_RA);
    uintptr_t rah = ral + sizeof(uint32_t);

    /**(uint32_t*)ral = 0x12005452;
    *(uint32_t*)rah = 0x5634 | E1000_RAH_AV;*/
    volatile uintptr_t eerd = E1000_REG(base,E1000_EERD);
    *(uint32_t*)eerd = 0x0 << E1000_EEPROM_RW_ADDR_SHIFT;
    *(uint32_t*)eerd |= E1000_EEPROM_RW_REG_START;
    while(1){
         if((*(uint32_t*)eerd) & E1000_EEPROM_RW_REG_DONE)
             break;
         
    }
    *(uint32_t*)ral = (*(uint32_t*)eerd) >> E1000_EEPROM_RW_REG_DATA;
    *(uint32_t*)eerd = 0x1 << E1000_EEPROM_RW_ADDR_SHIFT;
    *(uint32_t*)eerd |= E1000_EEPROM_RW_REG_START;
     while(1){
         if((*(uint32_t*)eerd) & E1000_EEPROM_RW_REG_DONE)
             break;
         
    }
    *(uint32_t*)ral |= (*(uint32_t*)eerd) & 0xffff0000;
    *(uint32_t*)eerd = 0x2 << E1000_EEPROM_RW_ADDR_SHIFT;
    *(uint32_t*)eerd |= E1000_EEPROM_RW_REG_START;
     while(1){
         if((*(uint32_t*)eerd) & E1000_EEPROM_RW_REG_DONE)
             break;
         
    }
    *(uint32_t*)rah = (*(uint32_t*)eerd) >> E1000_EEPROM_RW_REG_DATA;
    *(uint32_t*)rah |= E1000_RAH_AV;
    //cprintf("rah:%08x\n",*(uint32_t*)rah);
    //cprintf("ral:%08x\n",*(uint32_t*)ral);

    uintptr_t rdbal = E1000_REG(base,E1000_RDBAL);
    *(uint32_t*)rdbal = PADDR(rx_table);
    uintptr_t rdbah = E1000_REG(base,E1000_RDBAH);
    *(uint32_t*)rdbah = 0;
    uintptr_t rdlen = E1000_REG(base,E1000_RDLEN);
    *(uint32_t*)rdlen = sizeof(struct rx_desc)*RXDESC_LENGTH;
    rdh = (uint32_t*)E1000_REG(base,E1000_RDH);
    *(uint32_t*)rdh = 0;
    rdt = (uint32_t*)E1000_REG(base,E1000_RDT);
    *(uint32_t*)rdt = RXDESC_LENGTH - 1;
    uintptr_t rctl = E1000_REG(base,E1000_RCTL);
    tmp = 0;
    tmp |= E1000_RCTL_EN;
    tmp |= E1000_RCTL_BAM;
    tmp |= E1000_RCTL_SZ_2048;
    tmp |= E1000_RCTL_SECRC;
    *(uint32_t*)rctl = tmp;
       
    return 0;
}



int transmit_packet(struct tx_desc* td){
   struct tx_desc* begin = &tx_table[*tdt];
   if(!(begin->status & E1000_TXD_STAT_DD)){
       cprintf("transmit queue is full\n");
       return -1;
   }
   *begin = *td;
   begin->cmd |= E1000_TXD_CMD_RS >> 24;
   begin->cmd |= E1000_TXD_CMD_EOP>> 24;
   *tdt = (*tdt + 1) % TXDESC_LENGTH;
   /*int i;
   for(i = 0; i<begin->length;i++)
       cprintf("%x ",*((char*)((uint32_t)begin->addr) + i));
   cprintf("%d\n",begin->cmd);*/
   return 0;
}

int receive_packet(struct rx_desc* rd){
    uint32_t num = (*rdt + 1) % RXDESC_LENGTH; 
    //cprintf("%d\n",num);
    if(rx_table[num].status & E1000_RXD_STAT_DD){
       if(!(rx_table[num].status & E1000_RXD_STAT_EOP)){
            cprintf("eop miss\n");
            return -1;
       }
       *rd = rx_table[num];
       rx_table[num].status &= ~E1000_RXD_STAT_DD;
       rx_table[num].status &= ~E1000_RXD_STAT_EOP;
       *rdt = num;
       //cprintf("length:%d\n",rx_table[num].length);
       return 0;
    }
    return -1;
}
