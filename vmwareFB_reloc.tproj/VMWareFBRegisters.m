/*
 * Copyright (c) 2002 by Atomic Object LLC
 * All rights reserved.
 *
 * VMWareFBRegisters.m -- registers methods for VMWare display driver
 *
 * Created by Bill Bereza 2001/01/17
 * $Id$
 */

#import "VMWareFB.h"

#import <driverkit/i386/IOPCIDeviceDescription.h>
#import <driverkit/i386/IOPCIDirectDevice.h>

/* The 'VMWareFBRegisters category of 'VMWareFB' */
@implementation VMWareFB (Registers)

/*
 * Return the VMWare SVGA ID using the given index and value ports.
 */
+ (uint32) getVMWareSVGAIDAtIndexRegister: (uint16)indexRegister 
														valueRegister: (uint16)valueRegister
{
	return VMXGetVMwareSvgaId(indexRegister, valueRegister);
}

/*
 * Get the index and value I/O register addresses from the PCI
 * configuration using the given device description.
 * Return IO_R_SUCCESS if values are retrieved.
 */
+ (IOReturn)getIndexRegister: (uint16 *)indexRegister
							 valueRegister: (uint16 *)valueRegister
			 withDeviceDescription: deviceDescription
{
	IOPCIConfigSpace pciConfig;	/* PCI Configuration */
	IOReturn configReturn;				// return value from getPCIConfigSpace

	if( ( configReturn =  [self getPCIConfigSpace: &pciConfig 
															withDeviceDescription: deviceDescription] )
		!= IO_R_SUCCESS ) {
		IOLog("VMWareFB: Failed to get PCI config data.\n");
		return configReturn;
	}

	VMLog("VMWareFB: getting registers for PCI device: %04x vendor: %04x.\n",
		pciConfig.DeviceID, pciConfig.VendorID);
	
	// sanity check to see that the vendor id is VMWares
	if ( pciConfig.VendorID != PCI_VENDOR_ID_VMWARE ) {
		IOLog("VMWareFB: Got called for some other vendor: %04x\n", 
			pciConfig.VendorID);
		return IO_R_NO_DEVICE;
	}
	
	// the old device has a fixed base port
	if ( pciConfig.DeviceID == PCI_DEVICE_ID_VMWARE_SVGA ) {
		IOLog("VMWareFB: Legacy device found.\n");
		*indexRegister = SVGA_LEGACY_BASE_PORT + SVGA_INDEX_PORT * sizeof(uint32);
		*valueRegister = SVGA_LEGACY_BASE_PORT + SVGA_VALUE_PORT * sizeof(uint32);
	} else {
		// assume a new model vmware device
		// base port is base address register 0

		unsigned long basePort;

		// Use the NextStep masks to see if the base address for this
		// PCI device is actually an I/O port address
		if( (pciConfig.BaseAddress[0] & PCI_BASE_ADDRESS_SPACE)
			!= PCI_BASE_ADDRESS_SPACE_IO ) 
		{
			// This shouldn't happen. Don't know what to do if it does.
			IOLog("VMWareFB: WARNING: BaseAddress[0] may not be an I/O address!\n");
			// FIXME: not returning failure may be mistake
		}
		
		basePort = pciConfig.BaseAddress[0] & PCI_BASE_ADDRESS_IO_MASK;
		
		*indexRegister = basePort + SVGA_INDEX_PORT;
		*valueRegister = basePort + SVGA_VALUE_PORT;
	}

	return IO_R_SUCCESS;
}

/* VMWare specific methods. */

- (CARD32) readRegister: (int) index 
{
	return vmwareReadReg(indexReg, valueReg, index);
}

- (void) writeRegister: (int) index value: (CARD32) value 
{
	vmwareWriteReg(indexReg, valueReg, index, value);
}

- (void) writeWordToFIFO: (CARD32) value 
{
	vmwareWriteWordToFIFO(fifo, indexReg, valueReg, value);
}

- (void) updateDisplayX1: (int) x1
											Y1: (int) y1
											X2: (int) x2
											Y2: (int) y2 
{
	[self writeWordToFIFO: SVGA_CMD_UPDATE];
	[self writeWordToFIFO: x1];
	[self writeWordToFIFO: y1];
	[self writeWordToFIFO: x2];
	[self writeWordToFIFO: y2];
}
	
- (void) updateFullScreen 
{
	IODisplayInfo *displayInfo;		// current display info

	/* get our display info */
	displayInfo = [self displayInfo];

	[self updateDisplayX1: 0
				Y1: 0
				X2: displayInfo->width
				Y2: displayInfo->height];
}
	
	
@end
 
