/*
 * Copyright (c) 2002 by Atomic Object LLC
 * All rights reserved.
 *
 * VMWareFBAccel.m -- accel methods for VMWare display driver
 *
 * Created by Bill Bereza 2001/01/17
 * $Id$
 */

#import "VMWareFB.h"
#import <driverkit/i386/IOPCIDeviceDescription.h>
#import <driverkit/i386/IOPCIDirectDevice.h>

#include <string.h>

/* The 'VMWareFBAccell' category of 'VMWareFB' */
@implementation VMWareFB (Accel)

/*
 * Do accelerated FIFO commands based on parameters.
 * Print out unknown params before passing to super, for debug.
 */
- (IOReturn) setIntValues: (unsigned int *) array
						 forParameter: (IOParameterName) parameter
										count: (unsigned int) count
{
	VMLog("VMWareFB: setIntValues for param: %s\n", parameter);

	if(strcmp(parameter, VMWAREUPDATE_PARAM) == 0)
	{
		[self updateFullScreen];
		return IO_R_SUCCESS;
	}
	else 
	{
		return [super setIntValues: array
									forParameter: parameter
									count: count];
	}
}


- (IOReturn) getIntValues: (unsigned int *)array
						 forParameter: (IOParameterName) parameter
										count: (unsigned int *)count 
{
	VMLog("VMWareFB: getIntValues for param: %s\n", parameter);

	return [super getIntValues: array
								forParameter: parameter
								count: count];
}



- (IOReturn) getCharValues: (unsigned char *) array
							forParameter: (IOParameterName) parameter
										 count: (unsigned int *)count
{
	VMLog("VMWareFB: getCharValues for param: %s\n", parameter);

	return [super getCharValues: array
								forParameter: parameter
								count: count];
}


- (IOReturn) setCharValues: (unsigned char *)array
							forParameter: (IOParameterName) parameter
										 count: (unsigned int) count
{
	VMLog("VMWareFB: setCharValues for param: %s\n", parameter);

	return [super setCharValues: array
								forParameter: parameter
								count: count];
}


@end
 
