const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'charity_project',
    password: 'risimo66',
    port: 5432,
});

module.exports = pool;