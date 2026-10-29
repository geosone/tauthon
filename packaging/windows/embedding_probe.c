/* Standalone Windows C-API smoke test. No import library or python27 alias. */
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <string.h>

typedef void (__cdecl *SET_HOME)(char *);
typedef void (__cdecl *INIT)(void);
typedef int (__cdecl *RUN)(const char *);
typedef void (__cdecl *FINALIZE)(void);

int main(void) {
    char home[MAX_PATH], dll[MAX_PATH];
    DWORD count = GetModuleFileNameA(NULL, home, sizeof(home));
    if(!count || count >= sizeof(home)) return 1;
    char *separator = strrchr(home, '\\');
    if(!separator) return 1;
    *separator = '\0';
    if(strlen(home) + sizeof("\\tauthon28.dll") > sizeof(dll)) return 1;
    strcpy(dll, home);
    strcat(dll, "\\tauthon28.dll");
    HMODULE module = LoadLibraryA(dll);
    if(!module) { printf("FAIL DLL load: %lu\n", GetLastError()); return 1; }
    SET_HOME set_home = (SET_HOME)GetProcAddress(module, "Py_SetPythonHome");
    INIT initialize = (INIT)GetProcAddress(module, "Py_Initialize");
    RUN run = (RUN)GetProcAddress(module, "PyRun_SimpleString");
    FINALIZE finalize = (FINALIZE)GetProcAddress(module, "Py_Finalize");
    if(!set_home || !initialize || !run || !finalize) {
        puts("FAIL missing C API exports"); FreeLibrary(module); return 1;
    }
    set_home(home);
    initialize();
    int status = run("import sys; sys.dont_write_bytecode=True; "
                     "import json, sqlite3, ssl, ctypes; "
                     "assert sys.version_info[:2] == (2,8); "
                     "assert sqlite3.connect(':memory:').execute('select 42').fetchone()[0] == 42; "
                     "assert ssl.create_default_context().verify_mode == ssl.CERT_REQUIRED");
    finalize();
    FreeLibrary(module);
    if(status) { puts("FAIL embedded interpreter execution"); return 1; }
    puts("PASS direct Tauthon DLL embedding and essential modules");
    return 0;
}
