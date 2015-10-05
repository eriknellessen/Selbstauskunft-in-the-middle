/* Include the required headers from httpd */
#include "httpd.h"
#include "http_core.h"
#include "http_protocol.h"
#include "http_request.h"
#include "http_config.h"

#include <stdio.h>
#include <string.h>
#define BUFFER_SIZE 1024

char Parser[] = "";
char eIDCCBinary[] = "";

/* Define prototypes of our functions in this module */
static void register_hooks(apr_pool_t *pool);
static int eIDClientCore_handler(request_rec *r);

/* Define our module as an entity and assign a function for registering hooks  */

module AP_MODULE_DECLARE_DATA   eIDClientCore_module =
{
    STANDARD20_MODULE_STUFF,
    NULL,            // Per-directory configuration handler
    NULL,            // Merge handler for per-directory configurations
    NULL,            // Per-server configuration handler
    NULL,            // Merge handler for per-server configurations
    NULL,            // Any directives we may have for httpd
    register_hooks   // Our hook registering function
};


/* register_hooks: Adds a hook to the httpd process */
static void register_hooks(apr_pool_t *pool) 
{
    
    /* Hook the request handler */
    ap_hook_handler(eIDClientCore_handler, NULL, NULL, APR_HOOK_LAST);
}

/* The handler function for our module.
 * This is where all the fun happens!
 */

static int eIDClientCore_handler(request_rec *r)
{
	/* First off, we need to check if this is a call for the "eIDClientCore" handler.
	* If it is, we accept it and do our things, it not, we simply return DECLINED,
	* and Apache will try somewhere else.
	*/
	if (!r->handler || strcmp(r->handler, "eidclientcore-handler")) return (DECLINED);
	
	char buffer[BUFFER_SIZE];
	char *data = NULL;
	int size;
	int pos = 0;
	
	char *cmd;
	if(asprintf(&cmd, "%s 2>&1 | %s", eIDCCBinary, Parser) == -1)
		return -1;
	FILE *pipe = popen(cmd, "r");
	
	if(pipe) {
		while(fgets(buffer, BUFFER_SIZE, pipe) != NULL) {
			size = strlen(buffer);
			data = realloc(data, pos + size);
			memcpy(&data[pos], buffer, size);
			pos += size;
		}
	}

	if(data) {
		ap_rputs(data, r);
	}
	
	free(data);
	
	return OK;
}
