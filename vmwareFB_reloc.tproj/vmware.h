#ifndef VMWARE_H
#define VMWARE_H

#import <driverkit/generalFuncs.h>
#import <driverkit/i386/ioPorts.h>

#include "svga_reg.h"
#include "svga_limits.h"
#include "guest_os.h"
#include "vm_basic_types.h"
#include "vm_device_version.h"

#ifndef CARD32
typedef uint32 CARD32;
#endif

#ifndef PCI_BASE_ADDRESS_SPACE
/* mask (&) with baseAddress value to find out if it is memory or IO */
#define PCI_BASE_ADDRESS_SPACE 0x01 /* 0 = memory, 1 = I/O */
#define PCI_BASE_ADDRESS_SPACE_IO 0x01
#define PCI_BASE_ADDRESS_SPACE_MEMORY 0x00

/* mask (&) with baseAddress to get mem address */
#define PCI_BASE_ADDRESS_MASK (~0x0fUL)
/* mask (&) with baseAddress to get io address */
#define PCI_BASE_ADDRESS_IO_MASK (~0x03UL)
#endif


extern CARD32 vmwareReadReg(uint16 indexReg, uint16 valueReg, int index);

extern void vmwareWriteReg(uint16 indexReg, uint16 valueReg, int index, CARD32 value);

extern void vmwareWriteWordToFIFO(CARD32* vmwareFIFO, uint16 indexReg, uint16 valueReg, CARD32 value);

extern uint32 VMXGetVMwareSvgaId(uint16 indexReg, uint16 valueReg);

extern CARD32 vmwareCalculateWeight(CARD32 mask);

#endif							/* VMWARE_H */
