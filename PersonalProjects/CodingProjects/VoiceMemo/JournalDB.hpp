#pragma once

#include <sqlite3.h>
#include <string>
#include <vector>
#include <iostream>
#include <filesystem>

struct JournalEntry {
    int id;
    std::string timestamp;
    std::string audioPath;
    std::string transcript;
};

class JournalDB {
public:
    JournalDB(const std::string& dbPath) : dbFilePath(dbPath), db(nullptr) {}
    
    ~JournalDB() {
        close();
    }

    bool init() {
        if (sqlite3_open(dbFilePath.c_str(), &db) != SQLITE_OK) {
            std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
            return false;
        }

        const char* sql = 
            "CREATE TABLE IF NOT EXISTS entries ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,"
            "audio_path TEXT,"
            "transcript TEXT"
            ");"
            "CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts USING fts5("
            "transcript, content='entries', content_rowid='id');";

        char* errMsg = nullptr;
        if (sqlite3_exec(db, sql, nullptr, nullptr, &errMsg) != SQLITE_OK) {
            std::cerr << "SQL error: " << errMsg << std::endl;
            sqlite3_free(errMsg);
            return false;
        }
        return true;
    }

    bool saveEntry(const std::string& audioPath, const std::string& transcript) {
        const char* sql = "INSERT INTO entries (audio_path, transcript) VALUES (?, ?);";
        sqlite3_stmt* stmt;
        
        if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) return false;
        
        sqlite3_bind_text(stmt, 1, audioPath.c_str(), -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 2, transcript.c_str(), -1, SQLITE_STATIC);
        
        bool success = (sqlite3_step(stmt) == SQLITE_DONE);
        
        // Also update FTS index
        if (success) {
            sqlite3_int64 lastId = sqlite3_last_insert_rowid(db);
            const char* ftsSql = "INSERT INTO entries_fts(rowid, transcript) VALUES (?, ?);";
            sqlite3_stmt* ftsStmt;
            if (sqlite3_prepare_v2(db, ftsSql, -1, &ftsStmt, nullptr) == SQLITE_OK) {
                sqlite3_bind_int64(ftsStmt, 1, lastId);
                sqlite3_bind_text(ftsStmt, 2, transcript.c_str(), -1, SQLITE_STATIC);
                sqlite3_step(ftsStmt);
                sqlite3_finalize(ftsStmt);
            }
        }

        sqlite3_finalize(stmt);
        return success;
    }

    std::vector<JournalEntry> getAllEntries() {
        std::vector<JournalEntry> entries;
        const char* sql = "SELECT id, timestamp, audio_path, transcript FROM entries ORDER BY timestamp DESC;";
        sqlite3_stmt* stmt;

        if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                entries.push_back({
                    sqlite3_column_int(stmt, 0),
                    reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1)),
                    reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2)),
                    reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))
                });
            }
        }
        sqlite3_finalize(stmt);
        return entries;
    }

    void close() {
        if (db) sqlite3_close(db);
    }

private:
    std::string dbFilePath;
    sqlite3* db;
};