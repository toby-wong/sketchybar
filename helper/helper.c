#include "cpu.h"
#include "memory.h"
#include "sketchybar.h"

struct cpu g_cpu;
struct memory g_memory;

void handler(env env) {
  // Environment variables passed from sketchybar can be accessed as seen below
  char* name = env_get_value_for_key(env, "NAME");
  char* sender = env_get_value_for_key(env, "SENDER");
  char* info = env_get_value_for_key(env, "INFO");
  char* selected = env_get_value_for_key(env, "SELECTED");

  if ((strcmp(sender, "routine") == 0)
            || (strcmp(sender, "forced") == 0)) {
    // sketchybar() returns a heap-allocated reply (or NULL) that we must free;
    // these commands are fire-and-forget so the reply is discarded. free(NULL)
    // is a no-op, so the unwrapped call is safe.
    // CPU graph updates
    cpu_update(&g_cpu);
    if (strlen(g_cpu.command) > 0) free(sketchybar(g_cpu.command));

    // Memory graph updates
    memory_update(&g_memory);
    if (strlen(g_memory.command) > 0) free(sketchybar(g_memory.command));
  }
}

int main (int argc, char** argv) {
  cpu_init(&g_cpu);
  memory_init(&g_memory);

  if (argc < 2) {
    printf("Usage: provider \"<bootstrap name>\"\n");
    exit(1);
  }

  event_server_begin(handler, argv[1]);
  return 0;
}
