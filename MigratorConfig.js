module.exports = {
    database: {
        client: 'sqlite3',
        connection: {
            filename: '__DB_SQLITE_PATH__'
        }
    },
    migrationPath: process.cwd() + '/versions/__GHOST_NEW_VERSION__/core/server/data/migrations',
    currentVersion: '__DB_CURRENT_VERSION__'
}
