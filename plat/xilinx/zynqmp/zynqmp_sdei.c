/*
 * Copyright (c) 2017-2020, Arm Limited and Contributors. All rights reserved.
 * Copyright (c) Siemens AG, 2020-2021
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

/* SDEI configuration for ARM platforms */

#include <bl31/ehf.h>
#include <common/debug.h>
#include <plat/common/platform.h>
#include <services/sdei.h>

#include <platform_def.h>

int arm_validate_ns_entrypoint(uintptr_t entrypoint)
{
	uint64_t base = BL31_BASE;
	uint64_t limit = BL31_LIMIT;

	return (entrypoint < base || entrypoint > limit) ? 0 : -1;
}

/* Private event mappings */
static sdei_ev_map_t zynqmp_sdei_private[] = {
	SDEI_DEFINE_EVENT_0(ZYNQMP_SDEI_SGI_PRIVATE),
};

/* Shared event mappings */
static sdei_ev_map_t zynqmp_sdei_shared[] = {
};

void plat_sdei_setup(void)
{
	INFO("SDEI platform setup\n");
}

/* Export ARM SDEI events */
REGISTER_SDEI_MAP(zynqmp_sdei_private, zynqmp_sdei_shared);
