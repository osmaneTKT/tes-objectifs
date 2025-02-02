const mysql = require('mysql2');
require('dotenv').config();

const pool = mysql.createPool({
    host: 'mysql-data.cav82m4sgg3b.us-east-1.rds.amazonaws.com',
    user: 'admin',
    database: 'node-complete',
    password: process.env.DB_PASSWORD
});

module.exports = pool.promise();