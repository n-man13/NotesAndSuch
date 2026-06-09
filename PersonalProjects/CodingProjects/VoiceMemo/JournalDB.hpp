#pragma once
#include <sqlite3.h>
#include <string>
#include <vector>
#include <iostream>

class JournalDB {
public:
    JournalDB(const std::string& dbPath) : dbPath(dbPath), db(nullptr) {}
    
    bool init() {
        if (sqlite3_open(dbPath.c_str(), &db) != SQLITE_OK) return false;

        const char* sql = 
            "CREATE TABLE IF NOT EXISTS entries ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,"
            "audio_path TEXT,"
            "transcript TEXT);"
            "CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts USING fts5(transcript, content='entries', content_rowid='id');";

        return sqlite3_exec(db, sql, nullptr, nullptr, nullptr) == SQLITE_OK;
    }

    bool saveEntry(const std::string& audioPath, const std::string& text) {
        sqlite3_stmt* stmt;
        const char* sql = "INSERT INTO entries (audio_path, transcript) VALUES (?, ?);";
        
        if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) return false;
        
        sqlite3_bind_text(stmt, 1, audioPath.c_str(), -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 2, text.c_str(), -1, SQLITE_STATIC);
        
        bool success = (sqlite3_step(stmt) == SQLITE_DONE);
        sqlite3_finalize(stmt);

        // Update FTS index here if needed or use triggers
        return success;
    }

    ~JournalDB() {
        if (db) sqlite3_close(db);
    }

private:
    std::string dbPath;
    sqlite3* db;
};