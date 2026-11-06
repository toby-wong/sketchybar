#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mach/mach.h>
#include <stdbool.h>
#include <string.h>

struct cpu {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev_load;
  uint32_t tick;
  char topproc[32];
  char command[256];
};

static inline void cpu_init(struct cpu* cpu) {
  cpu->host = mach_host_self();
  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
  cpu->has_prev_load = false;
  cpu->tick = 0;
  snprintf(cpu->topproc, 32, "?");
  snprintf(cpu->command, 100, "");
}

static inline void cpu_update(struct cpu* cpu) {
  kern_return_t error = host_statistics(cpu->host,
                                        HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu->load,
                                        &cpu->count                );

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read cpu host statistics.\n");
    return;
  }

  if (cpu->has_prev_load) {
    uint32_t delta_user = cpu->load.cpu_ticks[CPU_STATE_USER]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_USER];

    uint32_t delta_system = cpu->load.cpu_ticks[CPU_STATE_SYSTEM]
                            - cpu->prev_load.cpu_ticks[CPU_STATE_SYSTEM];

    uint32_t delta_idle = cpu->load.cpu_ticks[CPU_STATE_IDLE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_IDLE];

    uint32_t delta_nice = cpu->load.cpu_ticks[CPU_STATE_NICE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_NICE];

    double total = (double)(delta_user + delta_system + delta_idle + delta_nice);
    if (total <= 0) total = 1;

    double user_perc = (double)(delta_user + delta_nice) / total;
    double sys_perc = (double)delta_system / total;
    double total_perc = user_perc + sys_perc;

    // Update top process only every 10 ticks (~20s)
    if (cpu->tick % 10 == 0) {
      FILE* file = popen("/bin/ps -Aceo pcpu,comm -r", "r");
      if (file) {
        char line[256];
        fgets(line, sizeof(line), file); // skip header
        if (fgets(line, sizeof(line), file)) {
          // Find process name after the CPU% field
          char* p = line;
          while (*p == ' ') p++;
          while (*p && *p != ' ') p++; // skip cpu%
          while (*p == ' ') p++;
          // Strip com.apple. prefix
          char* apple = strstr(p, "com.apple.");
          if (apple) p = apple + 10;
          // Trim newline and truncate
          char* nl = strchr(p, '\n');
          if (nl) *nl = '\0';
          snprintf(cpu->topproc, 32, "%s", p);
        }
        pclose(file);
      }
    }
    cpu->tick++;

    char color[16];
    if (total_perc >= .7) {
      snprintf(color, 16, "%s", getenv("RED"));
    } else if (total_perc >= .3) {
      snprintf(color, 16, "%s", getenv("ORANGE"));
    } else if (total_perc >= .1) {
      snprintf(color, 16, "%s", getenv("YELLOW"));
    } else {
      snprintf(color, 16, "%s", getenv("LABEL_COLOR"));
    }

    snprintf(cpu->command, 256, "--push cpu.sys %.2f "
                                "--push cpu.user %.2f "
                                "--set cpu.percent label=%.0f%% label.color=%s "
                                "--set cpu.top label=\"%s\"",
                                sys_perc,
                                user_perc,
                                total_perc*100.,
                                color,
                                cpu->topproc                                    );
  }
  else {
    snprintf(cpu->command, 256, "");
  }

  cpu->prev_load = cpu->load;
  cpu->has_prev_load = true;
}
