/* Include the required headers from httpd */
#include "httpd.h"
#include "http_core.h"
#include "http_protocol.h"
#include "http_request.h"
#include "http_config.h"

#include <stdio.h>
#include <string.h>
#include "mod_eIDClientCore.h"
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

char allowedFirstNames [] = "Erik";
int showSecret(char *firstName){
	if(firstName != NULL && strcasestr(allowedFirstNames, firstName) != NULL){
		return 0;
	} else {
		return -1;
	}
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
	
	int eIDCCReturnValue = pclose(pipe);
	eIDInformation mEIDInformation = {0};
	//Get the data
	if(data && eIDCCReturnValue == 0) {
		//Fill data structure
		char *foundString = data, **valueToFill, *startCopy;
		char searchString[] = ":\n";
		int i, nextLineBreak;
		for(i = 0; ; i++){
			//Set pointer to correct value in data structure
			switch(i){
				case 0: valueToFill = &mEIDInformation.title;
					break;
				case 1: valueToFill = &mEIDInformation.artistName;
					break;
				case 2: valueToFill = &mEIDInformation.firstName;
					break;
				case 3: valueToFill = &mEIDInformation.lastName;
					break;
				case 4: valueToFill = &mEIDInformation.birthName;
					break;
				case 5: valueToFill = &mEIDInformation.placeOfResidence;
					break;
				case 6: valueToFill = &mEIDInformation.placeOfBirth;
					break;
				case 7: valueToFill = &mEIDInformation.documentType;
					break;
				case 8: valueToFill = &mEIDInformation.issuingState;
					break;
				case 9: valueToFill = &mEIDInformation.nationality;
					break;
				case 10: valueToFill = &mEIDInformation.residencePermit;
					break;
				default: break;
			}
			
			foundString = strstr(foundString, searchString);
			if(foundString == NULL)
				break;
			foundString += strlen(searchString);
			
			if(*foundString == '\n'){
				*valueToFill = NULL;
			} else {
				startCopy = foundString;
				nextLineBreak = strcspn(foundString, "\n");
				*valueToFill = malloc(sizeof(char) * (nextLineBreak + 1));
				strncpy(*valueToFill, startCopy, nextLineBreak);
				char *string = *valueToFill;
				string[nextLineBreak] = '\0';
			}
		}
	}
	
	if(showSecret(mEIDInformation.firstName) == 0){
		ap_rputs("The secret is: Soylent Green is people!\n", r);
	} else {
		if(data)
			ap_rputs(data, r);
	}
	
	free(data);
	
	return OK;
}
