typedef struct _appConfig
{
    char *serverHostUrl;
    char *serverUsername;
    char *serverPasssword;
    int serverPort;
} AppConfig;

void initApp(AppConfig config);
