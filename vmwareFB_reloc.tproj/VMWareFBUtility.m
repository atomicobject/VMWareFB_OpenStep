/*
 * Copyright (c) 2002 by Atomic Object LLC
 * All rights reserved.
 *
 * VMWareFBUtility.m -- utility methods for VMWare display driver
 *
 * Created by Bill Bereza 2001/01/17
 * $Id$
 */

#import "VMWareFB.h"
#import <driverkit/i386/IOPCIDeviceDescription.h>
#import <driverkit/i386/IOPCIDirectDevice.h>

/* The 'VMWareFBUtility' category of 'VMWareFB' */
@implementation VMWareFB (Utility)
/*
 * Use IOLog to print information about this device.
 */
- (void) logInfo
{
	IODisplayInfo *displayInfo;		// selected display info

	displayInfo = [self displayInfo];

	IOLog("VMWareFB Display Driver by Atomic Object LLC\n");
	IOLog("Build Date: %s\n", VM_BUILD_DATE);
	IOLog("--------------------------------------------\n");
	IOLog("index register: \t0x%04x\n", indexReg);
	IOLog("value register: \t0x%04x\n", valueReg);
	IOLog("vmware Capability: \t0x%08x\n", vmwareCapability);
	IOLog("selected mode: \t%d\n", selectedMode);
	IOLog("\n");
	IOLog("IODisplayInfo\n");
	IOLog("-------------\n");
	IOLog("width: \t%d\n", displayInfo->width);
	IOLog("height: \t%d\n", displayInfo->height);
	IOLog("totalWidth: \t%d\n", displayInfo->totalWidth);
	IOLog("rowBytes: \t%d\n", displayInfo->rowBytes);
	IOLog("frameBuffer virtual address: \t0x%08x\n", (unsigned int)displayInfo->frameBuffer);
	// 2002-02-13 no fifo
	//IOLog("fifo virtual address: \t0x%08x\n",  (unsigned int)fifo);
	IOLog("bits-per-pixel: \t");
	switch(displayInfo->bitsPerPixel) 
	{
	case IO_2BitsPerPixel:
		IOLog("IO_2BitsPerPixel");
		break;
	case IO_8BitsPerPixel:
		IOLog("IO_8BitsPerPixel");
		break;
	case IO_12BitsPerPixel:
		IOLog("IO_12BitsPerPixel");
		break;
	case IO_15BitsPerPixel:
		IOLog("IO_15BitsPerPixel");
		break;
	case IO_24BitsPerPixel:
		IOLog("IO_24BitsPerPixel");
		break;
	case IO_VGA:
		IOLog("IO_VGA");
		break;
	default:
		IOLog("Strange[%d]", displayInfo->bitsPerPixel);
		break;
	}
	IOLog("\n");
	IOLog("pixel encoding: \"%s\"\n", displayInfo->pixelEncoding);
	IOLog("--------------------------------------------\n");

	return;
}


/*
 * Set the pixel encoding using the given bits per pixel,
 * and color masks.
 * The bits per pixel must be less than or equal to IO_MAX_PIXEL_BITS.
 * The color masks specify where in the pixel the color is placed.
 * Return YES on success or NO on error.
 */
- (BOOL) setPixelEncoding: (IOPixelEncoding) pixelEncoding
						 bitsPerPixel: (int) bitsPerPixel
									redMask: (int) redMask
								greenMask: (int) greenMask
								 blueMask: (int) blueMask
{
	int loop;

	if(bitsPerPixel <= 0 || bitsPerPixel > IO_MAX_PIXEL_BITS) 
	{
		IOLog("VMWareFB: bad bits per pixel [%d]\n", bitsPerPixel);
		return NO;
	}
	
	for(loop = 0; loop < bitsPerPixel; loop++) 
	{
		if( (redMask >> loop) & 1) 
		{
			// red bit
			pixelEncoding[bitsPerPixel - 1 - loop] = IO_SampleTypeRed;
		}
		else if( (greenMask >> loop) & 1)
		{
			// green bit
			pixelEncoding[bitsPerPixel - 1 - loop] = IO_SampleTypeGreen;
		}
		else if( (blueMask >> loop) & 1) 
		{
			// blue bit
			pixelEncoding[bitsPerPixel - 1 - loop] = IO_SampleTypeBlue;
		}
		else
		{
			pixelEncoding[bitsPerPixel - 1 - loop] = IO_SampleTypeSkip;
		}
	}
	// end of string
	pixelEncoding[bitsPerPixel] = IO_SampleTypeEnd;
	return YES;
}

@end
 
