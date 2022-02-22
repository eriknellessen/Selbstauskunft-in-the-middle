typedef struct eIDInformationStruct {
	char *title;
	char *artistName;
	char *firstName;
	char *lastName;
	char *birthName;
	char *placeOfResidence;
	char *placeOfBirth;
	char *dateOfBirth;
	char *documentType;
	char *issuingState;
	char *nationality;
	char *residencePermit;
} eIDInformation;

typedef struct {
    const char *eIDCCBinaryPath;
    const char *parserCommand;
    const char *eIDCCLibraryPath;
} eIDClientCoreConfig;
