const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const multer = require('multer');
const bcrypt = require('bcrypt');
const path = require('path');
const app = express();
const port = 3000;

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

// Настройка multer для загрузки изображений
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'server/uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

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

// Маршрут для регистрации пользователя с загрузкой изображения
app.post('/register', upload.single('profileImage'), async (req, res) => {
  const { name, surname, email, password } = req.body;
  const profileImage = req.file ? req.file.path : null;

  try {
    // Хешируем пароль
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log(`Hashed password: ${hashedPassword}`);

    // Сохраняем пользователя в базу данных с хешированным паролем и путем к изображению
    const result = await pool.query(
      'INSERT INTO Users (name, secondname, email, password, card_number, imageurl, id_role) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
      [name, surname, email, hashedPassword, '123456789', profileImage, 2]
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
    console.log(`User found: ${JSON.stringify(user)}`);
    console.log(`Entered password: ${password}`);
    console.log(`Stored hashed password: ${user.password}`);

    // Проверяем пароль с использованием bcrypt
    const isMatch = await bcrypt.compare(password, user.password);
    console.log(`Password match: ${isMatch}`);

    if (!isMatch) {
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
  console.log(`Server is running on http://192.168.0.112:${port}`);
});