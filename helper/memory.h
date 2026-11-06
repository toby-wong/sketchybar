#include <stdio.h>
#include <stdlib.h>
#include <mach/mach.h>
#include <mach/vm_page_size.h>
#include <sys/sysctl.h>
#include <stdbool.h>

// Colour thresholds for "used" = App Memory + Wired + Compressed.
//
// The original .3/.5/.7 bands were calibrated against a value that was 4x too
// low (see the vm_page_size note in memory_update), so once that was corrected
// they fired far too early -- .7 tripped at what is really normal usage.
//
// Two properties of the corrected metric drive these numbers:
//   * Wired memory is an irreducible floor of roughly 22% and never frees.
//   * The compressor is sticky. It only shrinks as pages are freed or
//     decompressed, so a long-uptime machine idles much higher than a freshly
//     booted one (measured: ~25-35% after boot, ~61% floor after heavy swap).
//
//   < 62%  normal    -- headroom, includes the whole fresh-boot range
//   >= 62% busy      -- compressor carrying real weight
//   >= 78% heavy     -- sustained pressure, swap in active use
//   >= 90% critical  -- swap approaching exhaustion
#define MEM_BUSY     0.62
#define MEM_HEAVY    0.78
#define MEM_CRITICAL 0.90

// Fallback when the helper is started without colors.sh sourced into its
// environment. getenv would return NULL and "%s" would emit the literal
// string "(null)", which sketchybar rejects as a colour.
#define MEM_COLOR_FALLBACK "0xffffffff"

struct memory {
  host_t host;
  uint64_t total_memory;
  char command[512];
};

static inline void memory_init(struct memory* mem) {
  mem->host = mach_host_self();

  int mib[2] = { CTL_HW, HW_MEMSIZE };
  size_t length = sizeof(mem->total_memory);
  sysctl(mib, 2, &mem->total_memory, &length, NULL, 0);

  snprintf(mem->command, 512, "");
}

static inline void memory_update(struct memory* mem) {
  mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
  vm_statistics64_data_t vm_stat;

  kern_return_t error = host_statistics64(mem->host,
                                          HOST_VM_INFO64,
                                          (host_info64_t)&vm_stat,
                                          &count                   );

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read memory host statistics.\n");
    return;
  }

  // host_statistics64 reports page counts in KERNEL pages. Do NOT use
  // vm_page_size here: in a Rosetta-translated (x86_64) process that is 4096
  // while the Apple Silicon kernel uses 16384, which silently under-reports
  // memory by 4x. vm_kernel_page_size is correct on both architectures.
  uint64_t page_size = vm_kernel_page_size;

  // Match Activity Monitor's "Memory Used" = App Memory + Wired + Compressed.
  // App Memory is anonymous (internal) pages minus purgeable pages, NOT
  // active_count -- active_count omits the inactive anonymous pages that
  // Activity Monitor still counts against App Memory.
  uint64_t app_pages = (vm_stat.internal_page_count > vm_stat.purgeable_count)
                       ? (uint64_t)vm_stat.internal_page_count
                         - (uint64_t)vm_stat.purgeable_count
                       : 0;

  uint64_t app = app_pages * page_size;
  uint64_t wired = (uint64_t)vm_stat.wire_count * page_size;
  uint64_t compressed = (uint64_t)vm_stat.compressor_page_count * page_size;

  uint64_t used = app + wired + compressed;
  double total_perc = (double)used / (double)mem->total_memory;
  double wired_perc = (double)(wired + compressed) / (double)mem->total_memory;
  double app_perc = (double)app / (double)mem->total_memory;

  const char* color_key = (total_perc >= MEM_CRITICAL) ? "RED"
                        : (total_perc >= MEM_HEAVY)    ? "ORANGE"
                        : (total_perc >= MEM_BUSY)     ? "YELLOW"
                        :                                "LABEL_COLOR";

  const char* color_val = getenv(color_key);
  char color[16];
  snprintf(color, 16, "%s", color_val ? color_val : MEM_COLOR_FALLBACK);

  double used_gb = (double)used / (1024.0 * 1024.0 * 1024.0);
  double total_gb = (double)mem->total_memory / (1024.0 * 1024.0 * 1024.0);

  snprintf(mem->command, 512, "--push memory.wired %.2f "
                               "--push memory.app %.2f "
                               "--set memory.percent label=%.0f%% label.color=%s "
                               "--set memory.top label=\"%.1f/%.0fGB\"",
                               wired_perc,
                               app_perc,
                               total_perc * 100.,
                               color,
                               used_gb,
                               total_gb                                      );
}
