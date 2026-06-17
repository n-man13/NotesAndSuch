#pragma once

#include <string>
#include <filesystem>
#include <cstdlib>

#ifdef _WIN32
#include <windows.h>
#include <shlobj.h>
#endif

namespace PlatformUtils {

/**
 * Returns the standard local application data directory.
 * Windows: %LOCALAPPDATA%/LocalSpeechJournal
 * Linux: ~/.local/share/LocalSpeechJournal
 */
inline std::filesystem::path getAppDataDirectory() {
    std::filesystem::path appPath;

#ifdef _WIN32
    PWSTR path_tmp;
    if (SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, NULL, &path_tmp) == S_OK) {
        appPath = std::filesystem::path(path_tmp) / "LocalSpeechJournal";
        CoTaskMemFree(path_tmp);
    } else {
        appPath = std::filesystem::current_path() / "data";
    }
#else
    const char* xdg_data = std::getenv("XDG_DATA_HOME");
    if (xdg_data) {
        appPath = std::filesystem::path(xdg_data) / "LocalSpeechJournal";
    } else {
        const char* home = std::getenv("HOME");
        if (home) {
            appPath = std::filesystem::path(home) / ".local" / "share" / "LocalSpeechJournal";
        } else {
            appPath = std::filesystem::current_path() / "data";
        }
    }
#endif

    // Ensure directory exists
    if (!std::filesystem::exists(appPath)) {
        std::filesystem::create_directories(appPath);
    }

    return appPath;
}

} // namespace PlatformUtils