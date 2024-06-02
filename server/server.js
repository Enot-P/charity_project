const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const app = express();
const port = 3000;
const path = require('path');

// Использование CORS для разрешения кросс-доменных запросов
app.use(cors());

// Позволяет серверу понимать JSON тела запросов
app.use(express.json());

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

// Маршрут для регистрации пользователя
app.post('/register', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Сохраняем пользователя в базу данных без хеширования пароля
    const result = await pool.query(
      'INSERT INTO Users (email, password) VALUES ($1, $2) RETURNING *',
      [email, password]
    );

    res.json({ message: 'User registered successfully', user: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для входа пользователя
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Находим пользователя по email
    const result = await pool.query('SELECT * FROM Users WHERE email = $1', [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const user = result.rows[0];

    // Проверяем пароль напрямую
    if (password !== user.password) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    res.json({ message: 'User logged in successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Запуск сервера
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});