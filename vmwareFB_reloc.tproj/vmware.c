/*
 * Copyright (c) 2002 by Atomic Object LLC
 * All rights reserved.
 *
 * vmware.c -- low-level C functions for reading and writing registers
 *
 * Base on code from vmware.c in the XFree86 driver.
 * Portions copyright VMware, Inc.
 *
 * $Id$
 */
/* **********************************************************
 * Copyright (C) 1998-2001 VMware, Inc.
 * All Rights Reserved
 * **********************************************************/
#include "vmware.h"

/* VMware specific functions */

CARD32
 vmwareCalculateWeight(CARD32 mask)
{
	CARD32 weight;
	
	for (weight = 0; mask; mask >>= 1) {
		if (mask & 1) {
	    weight++;
		}
	}
	return weight;
}

CARD32
 vmwareReadReg(uint16 indexReg, uint16 valueReg, int index)
{
	outl(indexReg, index);
	return inl(valueReg);
}

void
 vmwareWriteReg(uint16 indexReg, uint16 valueReg, int index, CARD32 value)
{
	outl(indexReg, index);
	outl(valueReg, value);
}

void
 vmwareWriteWordToFIFO(CARD32* vmwareFIFO, uint16 indexReg, uint16 valueReg, CARD32 value)
{
	/* Need to sync? */
	if ((vmwareFIFO[SVGA_FIFO_NEXT_CMD] + sizeof(CARD32) == vmwareFIFO[SVGA_FIFO_STOP])
		|| (vmwareFIFO[SVGA_FIFO_NEXT_CMD] == vmwareFIFO[SVGA_FIFO_MAX] - sizeof(CARD32) &&
			vmwareFIFO[SVGA_FIFO_STOP] == vmwareFIFO[SVGA_FIFO_MIN])) {
		vmwareWriteReg(indexReg, valueReg, SVGA_REG_SYNC, 1);
		while (vmwareReadReg(indexReg, valueReg, SVGA_REG_BUSY)) ;
	}
	vmwareFIFO[vmwareFIFO[SVGA_FIFO_NEXT_CMD] / sizeof(CARD32)] = value;
	vmwareFIFO[SVGA_FIFO_NEXT_CMD] += sizeof(CARD32);
	if (vmwareFIFO[SVGA_FIFO_NEXT_CMD] == vmwareFIFO[SVGA_FIFO_MAX]) {
		vmwareFIFO[SVGA_FIFO_NEXT_CMD] = vmwareFIFO[SVGA_FIFO_MIN];
	}
}

/*
 *-----------------------------------------------------------------------------
 *
 * VMXGetVMwareSvgaId --
 *
 *    Retrieve the SVGA_ID of the VMware SVGA adapter.
 *    This function should hide any backward compatibility mess.
 *
 * Results:
 *    The SVGA_ID_* of the present VMware adapter.
 *
 * Side effects:
 *    ins/outs
 *
 *-----------------------------------------------------------------------------
 */

uint32
 VMXGetVMwareSvgaId(uint16 indexReg, uint16 valueReg)
{
	uint32 vmware_svga_id;

	/* Any version with any SVGA_ID_* support will initialize SVGA_REG_ID
	 * to SVGA_ID_0 to support versions of this driver with SVGA_ID_0.
	 *
	 * Versions of SVGA_ID_0 ignore writes to the SVGA_REG_ID register.
	 *
	 * Versions of SVGA_ID_1 will allow us to overwrite the content
	 * of the SVGA_REG_ID register only with the values SVGA_ID_0 or SVGA_ID_1.
	 *
	 * Versions of SVGA_ID_2 will allow us to overwrite the content
	 * of the SVGA_REG_ID register only with the values SVGA_ID_0 or SVGA_ID_1
	 * or SVGA_ID_2.
	 */

	vmwareWriteReg(indexReg, valueReg, SVGA_REG_ID, SVGA_ID_2);
	vmware_svga_id = vmwareReadReg(indexReg, valueReg, SVGA_REG_ID);
	IOLog("VMWareFB: read ID: (0x%08x)\n", vmware_svga_id);
	if (vmware_svga_id == SVGA_ID_2) {
		return SVGA_ID_2;
	}

	vmwareWriteReg(indexReg, valueReg, SVGA_REG_ID, SVGA_ID_1);
	vmware_svga_id = vmwareReadReg(indexReg, valueReg, SVGA_REG_ID);
	IOLog("VMWareFB: read ID: (0x%08x)\n", vmware_svga_id);
	if (vmware_svga_id == SVGA_ID_1) {
		return SVGA_ID_1;
	}

	if (vmware_svga_id == SVGA_ID_0) {
		return SVGA_ID_0;
	}

	/* No supported VMware SVGA devices found */
	return SVGA_ID_INVALID;
}

