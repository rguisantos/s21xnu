#pragma once
#include <stdint.h>

#define FB_BASE		0xfa000000UL	/* S-Boot framebuffer (bootloader_fb) */
#if defined(SWEET_BOARD_P3S)
/* S21 Ultra (p3s): S6E3HAD WQHD+ panel; LK reserves 0x1194000 = 1440*3200*4 */
#define FB_W		1440
#define FB_H		3200
#define FB_STRIDE	(1440 * 4)
#elif defined(SWEET_BOARD_P3S_WINDOW)
/* S21 Ultra, 1080x2400 window in the top-left of the 1440x3200 scanout, so the
 * t2s display/touch geometry in XNU can be reused unchanged for a first boot. */
#define FB_W		1080
#define FB_H		2400
#define FB_STRIDE	(1440 * 4)
#else
/* S21+ (t2s): 1080x2400 */
#define FB_W		1080
#define FB_H		2400
#define FB_STRIDE	(FB_W * 4)	/* a8r8g8b8, matches mainline simplefb */
#endif

#define RED	0xffff0000U
#define BLUE	0xff0000a0U
#define WHITE	0xffffffffU
#define YELLOW	0xffffff00U
#define GREEN	0xff00ff00U

extern volatile uint32_t *con_fb;

void con_clear(uint32_t bg);
void con_skip(void);
void con_str(const char *label, const char *s);
void con_hex(const char *label, uint64_t v);
/* label, then "a=xxxxxxxx b=xxxxxxxx" style pairs of 32-bit values */
void con_hex2(const char *label, const char *a, uint32_t va, const char *b, uint32_t vb);
