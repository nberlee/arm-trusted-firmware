/*
 * Copyright (c) 2016-2023, Arm Limited and Contributors. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <asm_macros.S>
#include <lib/psci/psci.h>
#include <platform_def.h>

	.globl	psci_do_pwrdown_cache_maintenance
	.globl	psci_do_pwrup_cache_maintenance
	.globl	psci_power_down_wfi

/* -----------------------------------------------------------------------
 * void psci_do_pwrdown_cache_maintenance(unsigned int power level);
 *
 * This function performs cache maintenance for the specified power
 * level. The levels of cache affected are determined by the power
 * level which is passed as the argument i.e. level 0 results
 * in a flush of the L1 cache. Both the L1 and L2 caches are flushed
 * for a higher power level.
 *
 * Additionally, this function also ensures that stack memory is correctly
 * flushed out to avoid coherency issues due to a change in its memory
 * attributes after the data cache is disabled.
 * -----------------------------------------------------------------------
 */
func psci_do_pwrdown_cache_maintenance
	push	{r4, lr}

	/* ----------------------------------------------
	 * Turn OFF cache and do stack maintenance
	 * prior to cpu operations . This sequence is
	 * different from AArch64 because in AArch32 the
	 * assembler routines for cpu operations utilize
	 * the stack whereas in AArch64 it doesn't.
	 * ----------------------------------------------
	 */
	mov	r4, r0
	bl	do_stack_maintenance

	/* ---------------------------------------------
	 * Invoke CPU-specifc power down operations for
	 * the appropriate level
	 * ---------------------------------------------
	 */
	mov	r0, r4
	pop	{r4, lr}
	b	prepare_cpu_pwr_dwn
endfunc psci_do_pwrdown_cache_maintenance


/* -----------------------------------------------------------------------
 * void psci_do_pwrup_cache_maintenance(void);
 *
 * This function performs cache maintenance after this cpu is powered up.
 * Currently, this involves managing the used stack memory before turning
 * on the data cache.
 * -----------------------------------------------------------------------
 */
func psci_do_pwrup_cache_maintenance
	/* r12 is pushed to meet the 8 byte stack alignment requirement */
	push	{r12, lr}

	/* ---------------------------------------------
	 * Ensure any inflight stack writes have made it
	 * to main memory.
	 * ---------------------------------------------
	 */
	dmb	st

	/* ---------------------------------------------
	 * Calculate and store the size of the used
	 * stack memory in r1. Calculate and store the
	 * stack base address in r0.
	 * ---------------------------------------------
	 */
	bl	plat_get_my_stack
	mov	r1, sp
	sub	r1, r0, r1
	mov	r0, sp
	bl	inv_dcache_range

	/* ---------------------------------------------
	 * Enable the data cache.
	 * ---------------------------------------------
	 */
	ldcopr	r0, SCTLR
	orr	r0, r0, #SCTLR_C_BIT
	stcopr	r0, SCTLR
	isb

	pop	{r12, pc}
endfunc psci_do_pwrup_cache_maintenance

	/* ---------------------------------------------
	 * void do_stack_maintenance(void)
	 * Do stack maintenance by flushing the used
	 * stack to the main memory and invalidating the
	 * remainder.
	 * ---------------------------------------------
	 */
func do_stack_maintenance
	push	{r4, lr}
	bl	plat_get_my_stack

	/* Turn off the D-cache */
	ldcopr	r1, SCTLR
	bic	r1, #SCTLR_C_BIT
	stcopr	r1, SCTLR
	isb

	/* ---------------------------------------------
	 * Calculate and store the size of the used
	 * stack memory in r1.
	 * ---------------------------------------------
	 */
	mov	r4, r0
	mov	r1, sp
	sub	r1, r0, r1
	mov	r0, sp
	bl	flush_dcache_range

	/* ---------------------------------------------
	 * Calculate and store the size of the unused
	 * stack memory in r1. Calculate and store the
	 * stack base address in r0.
	 * ---------------------------------------------
	 */
	sub	r0, r4, #PLATFORM_STACK_SIZE
	sub	r1, sp, r0
	bl	inv_dcache_range

	pop	{r4, pc}
endfunc do_stack_maintenance

/* -----------------------------------------------------------------------
 * This function is called to indicate to the power controller that it
 * is safe to power down this cpu. It should not exit the wfi and will
 * be released from reset upon power up.
 * -----------------------------------------------------------------------
 */
func psci_power_down_wfi
	dsb	sy		// ensure write buffer empty
1:
	wfi
	b	1b
endfunc psci_power_down_wfi
