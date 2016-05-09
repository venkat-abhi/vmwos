#include <stddef.h>
#include <stdint.h>

#include "lib/printk.h"
#include "lib/string.h"

#include "process.h"

void exit(int32_t status) {

        process[current_process].status=PROCESS_STATUS_EXITED;
	process[current_process].exit_value=status;

	/* Free resources now? */
	/* process_destroy(current_process); */

	/* Reschedule? */
}

