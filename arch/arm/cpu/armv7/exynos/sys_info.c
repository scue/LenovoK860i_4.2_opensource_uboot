/*
 * Copyright (C) 2009 Samsung Electronics
 * Minkyu Kang <mk7.kang@samsung.com>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */
#include <common.h>
#include <asm/io.h>
#include <asm/arch/clk.h>
#include <asm/arch/cpu.h>

/* Default is s5pc100 */
unsigned int s5p_cpu_id = 0xC100;

/* jeff, exynos4412_rev*/
#ifdef CONFIG_EXYNOS4412
static int exynos4412_rev_print(void)
{
	unsigned int exynos4412_cpu_id = 0;
        exynos4412_cpu_id = readl(0x10000000);
	
	printf("CPU : E%04x_%d.%d\n",
		(exynos4412_cpu_id>>12)&0xFFFF, ((exynos4412_cpu_id>>4) & 0xF), (exynos4412_cpu_id & 0xF));
}

unsigned int is_exynos4412_rev20(void)
{
        unsigned int exynos4412_cpu_id = 0;

        exynos4412_cpu_id = readl(0x10000000);
        exynos4412_cpu_id &= 0xFF;
	return (exynos4412_cpu_id == 0x20);
}
#endif

#ifdef CONFIG_ARCH_CPU_INIT
int arch_cpu_init(void)
{
	s5p_set_cpu_id();

	s5p_clock_init();

	return 0;
}
#endif

u32 get_device_type(void)
{
	return s5p_cpu_id;
}

#ifdef CONFIG_DISPLAY_CPUINFO
int print_cpuinfo(void)
{
	char buf[32];
	unsigned int cpuid;

#ifdef CONFIG_ARCH_EXYNOS5

	__asm__ __volatile__("mrc p15, 0, %0, c0, c0, 0":"=r"(cpuid));

	printf("\nCPU: S5PC%x [Samsung SOC on SMP Platform Base on ARM CortexA%d]\n",((PRO_ID >> 12) & 0xfff),((cpuid >> 4) & 0xf));

#elif defined(CONFIG_SMDKC220)||defined(CONFIG_STUTTGART)
	printf("\nCPU: S5PC220 [Samsung SOC on SMP Platform Base on ARM CortexA9]\n");
#else
	if(((PRO_ID & 0x300) >> 8) == 2){
		printf("\nCPU: S5PC210 [Samsung SOC on SMP Platform Base on ARM CortexA9]\n");
	}
	else{
		printf("\nCPU: S5PV310 [Samsung SOC on SMP Platform Base on ARM CortexA9]\n");
	}
#endif

	printf("APLL = %ldMHz, MPLL = %ldMHz\n", get_APLL_CLK()/1000000, get_MPLL_CLK()/1000000);

#ifdef CONFIG_EXYNOS4412
	exynos4412_rev_print();
#endif

	return 0;
}
#endif
