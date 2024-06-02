     const express = require('express');
     const { Pool } = require('pg');
     const app = express();
     const port = 3000;

     // Настройка подключения к базе данных PostgreSQL
     const pool = new Pool({
       user: 'postgres',
       host: 'localhost',
       database: 'charity_project',
       password: 'risimo66',
       port: 5432,
     });

     // Маршрут для получения всех пользователей
     app.get('/users', async (req, res) => {
       try {
         const result = await pool.query('SELECT * FROM Users');
         res.json(result.rows);
       } catch (err) {
         console.error(err);
         res.status(500).json({ error: 'Internal Server Error' });
       }
     });

     // Маршрут для получения всех фондов
     app.get('/fonds', async (req, res) => {
       try {
         const result = await pool.query('SELECT * FROM Fonds');
         res.json(result.rows);
       } catch (err) {
         console.error(err);
         res.status(500).json({ error: 'Internal Server Error' });
       }
     });

     // Запуск сервера
     app.listen(port, () => {
       console.log(`Server is running on http://localhost:${port}`);
     });