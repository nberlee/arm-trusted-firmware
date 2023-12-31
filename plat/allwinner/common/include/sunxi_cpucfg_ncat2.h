/*
 * Copyright (c) 2021 Sipeed
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef SUNXI_CPUCFG_H
#define SUNXI_CPUCFG_H

#include <sunxi_mmap.h>

/* c = cluster, n = core */
#define SUNXI_CPUCFG_CLS_CTRL_REG0(c)	(SUNXI_C0_CPUXCFG_BASE + 0x0010)
#define SUNXI_CPUCFG_CLS_CTRL_REG1(c)	(SUNXI_C0_CPUXCFG_BASE + 0x0014)
#define SUNXI_CPUCFG_CACHE_CFG_REG	(SUNXI_C0_CPUXCFG_BASE + 0x0024)
#define SUNXI_CPUCFG_DBG_REG0		(SUNXI_C0_CPUXCFG_BASE + 0x00c0)

#define SUNXI_CPUCFG_RST_CTRL_REG(c)	(SUNXI_C0_CPUXCFG_BASE + 0x0000)
#define SUNXI_CPUCFG_GEN_CTRL_REG0(c)	(SUNXI_CPUCFG_BASE + 0x0000)
#define SUNXI_CPUCFG_RVBAR_LO_REG(n)	(SUNXI_CPUCFG_BASE + 0x0040 + (n) * 8)
#define SUNXI_CPUCFG_RVBAR_HI_REG(n)	(SUNXI_CPUCFG_BASE + 0x0044 + (n) * 8)

#define SUNXI_POWERON_RST_REG(c)	(SUNXI_R_CPUCFG_BASE + 0x0040 + (c) * 4)
#define SUNXI_POWEROFF_GATING_REG(c)	(SUNXI_R_CPUCFG_BASE + 0x0044 + (c) * 4)
#define SUNXI_CPU_POWER_CLAMP_REG(c, n)	(SUNXI_R_CPUCFG_BASE + 0x0050 + \
					(c) * 0x10 + (n) * 4)

#define SUNXI_AA64nAA32_REG		SUNXI_CPUCFG_GEN_CTRL_REG0
#define SUNXI_AA64nAA32_OFFSET		4

static inline bool sunxi_cpucfg_has_per_cluster_regs(void)
{
	return true;
}

#endif /* SUNXI_CPUCFG_H */
