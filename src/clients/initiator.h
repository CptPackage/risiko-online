typedef struct _appConfig
{
    char *serverHostUrl;
    char *serverUsername;
    char *serverPasssword;
    int serverPort;
} AppConfig;

int initApp(AppConfig config);
