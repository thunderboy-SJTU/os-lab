#ifndef JOS_KERN_E1000_H
#define JOS_KERN_E1000_H

#include <kern/pci.h>

#define E1000_VENDOR 0x8086
#define E1000_DEVICE 0x100E

#define E1000_REG(base,offset) (((uintptr_t)base)+(offset))

#define TXDESC_LENGTH  64
#define RXDESC_LENGTH  128

#define MAXBUFLEN 2048

#define E1000_TDBAL    0x03800  /* TX Descriptor Base Address Low - RW */
#define E1000_TDBAH    0x03804  /* TX Descriptor Base Address High - RW */
#define E1000_TDLEN    0x03808  /* TX Descriptor Length - RW */
#define E1000_TDH      0x03810  /* TX Descriptor Head - RW */
#define E1000_TDT      0x03818  /* TX Descripotr Tail - RW */
#define E1000_TCTL     0x00400  /* TX Control - RW */
#define E1000_TIPG     0x00410  /* TX Inter-packet gap -RW */

/* Transmit Control */
#define E1000_TCTL_EN     0x00000002    /* enable tx */
#define E1000_TCTL_PSP    0x00000008    /* pad short packets */
#define E1000_TCTL_COLD   0x003ff000    /* collision distance */

#define E1000_TXD_STAT_DD    0x00000001 /* Descriptor Done */
/* Receive Descriptor bit definitions */
#define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */

/* Transmit Descriptor bit definitions */
#define E1000_TXD_CMD_RS     0x08000000 /* Report Status */
#define E1000_TXD_CMD_EOP    0x01000000 /* End of Packet */

#define E1000_RA       0x05400  /* Receive Address - RW Array */
#define E1000_RDBAL    0x02800  /* RX Descriptor Base Address Low - RW */
#define E1000_RDBAH    0x02804  /* RX Descriptor Base Address High - RW */
#define E1000_RDLEN    0x02808  /* RX Descriptor Length - RW */
#define E1000_RDH      0x02810  /* RX Descriptor Head - RW */
#define E1000_RDT      0x02818  /* RX Descriptor Tail - RW */
#define E1000_RCTL     0x00100  /* RX Control - RW */

/* Receive Control */
#define E1000_RCTL_EN             0x00000002    /* enable */
#define E1000_RCTL_BAM            0x00008000    /* broadcast enable */
#define E1000_RCTL_SZ_2048        0x00000000    /* rx buffer size 2048 */
#define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */

/* Receive Address */
#define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */

#define E1000_RXD_STAT_EOP      0x02    /* End of Packet */

#define E1000_EERD     0x00014  /* EEPROM Read - RW */
#define E1000_EEPROM_RW_REG_DATA   16   /* Offset to data in EEPROM read/write registers */
#define E1000_EEPROM_RW_REG_DONE   0x10 /* Offset to READ/WRITE done bit */
#define E1000_EEPROM_RW_REG_START  1    /* First bit for telling part to start operation */
#define E1000_EEPROM_RW_ADDR_SHIFT 8    /* Shift to the address bits */




/* Transmit Descriptor */
struct tx_desc
{
	uint64_t addr;
	uint16_t length;
	uint8_t cso;
	uint8_t cmd;
	uint8_t status;
	uint8_t css;
	uint16_t special;
};

/* Receive Descriptor */
struct rx_desc {
    uint64_t buffer_addr; /* Address of the descriptor's data buffer */
    uint16_t length;     /* Length of data DMAed into data buffer */
    uint16_t csum;       /* Packet checksum */
    uint8_t status;      /* Descriptor status */
    uint8_t errors;      /* Descriptor Errors */
    uint16_t special;
};

struct rcvbuf{
    char buf[MAXBUFLEN];
};

volatile uint32_t* base;

int pci_e1000_attach(struct pci_func *pcif);
int transmit_packet(struct tx_desc* td);
int receive_packet(struct rx_desc* rd);
#endif	// JOS_KERN_E1000_H
