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
    cb(null, path.join(__dirname, 'uploads')); // Убедитесь, что путь корректен
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

// Настройка статического сервера для обслуживания загруженных изображений
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


// Маршрут для регистрации пользователя с загрузкой изображения
app.post('/register', upload.single('profileImage'), async (req, res) => {
  const { name, surname, email, password } = req.body;
  const profileImage = req.file ? `uploads/${req.file.filename}` : null;

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

    // Возвращаем данные пользователя
    res.json({
      message: 'User logged in successfully',
      user: {
        id_user: user.id_user,
        name: user.name,
        email: user.email,
        secondname: user.secondname,
        card_number: user.card_number,
        imageurl: `http://192.168.0.112:3000/${user.imageurl.replace(/\\/g, '/').replace('server/', '')}`, // Полный URL изображения
        id_role: user.id_role
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для получения данных пользователя по id
app.get('/user/:id', async (req, res) => {
  const { id } = req.params;

  try {
    // Получаем данные пользователя
    const userResult = await pool.query('SELECT * FROM Users WHERE id_user = $1', [id]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = userResult.rows[0];

    // Получаем имя роли на основе id_role пользователя
    const roleResult = await pool.query('SELECT name FROM Roles WHERE id_role = $1', [user.id_role]);

    if (roleResult.rows.length === 0) {
      return res.status(404).json({ message: 'Role not found' });
    }

    const roleName = roleResult.rows[0].name;

    // Форматируем URL изображения
    const formattedImageUrl = `http://192.168.0.112:3000/${user.imageurl.replace(/\\/g, '/').replace('server/', '')}`;

    // Формируем ответ с user данными и roleName
    res.json({
      id_user: user.id_user,
      name: user.name,
      email: user.email,
      secondname: user.secondname,
      card_number: user.card_number,
      imageurl: formattedImageUrl,
      roleName: roleName
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// Маршрут для получения всех фондов
app.get('/fonds', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM Fonds');
    const fonds = result.rows.map(fond => ({
      id: fond.id_fond,
      imageUrl: fond.imageurl,
      fundName: fond.name,
      amount: fond.balance.toString(),
      tag: fond.id_tag.toString(), // Предполагается, что тег хранится как строка
      description: fond.description,
      contactInfo: `Телефон: ${fond.phone} \nАдрес: ${fond.location} \nE-mail: ${fond.email}`,
    }));
    res.json(fonds);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.get('/events', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        e.id_event,
        e.name AS event_name,
        e.description AS event_description,
        e.location AS event_location,
        e.data_start AS event_start_date,
        e.imageurl AS event_image_url,
        f.id_fond,
        f.name AS fond_name,
        f.imageurl AS ownerFondLogoUrl -- Используем imageurl для логотипа фонда
      FROM
        events e
      JOIN
        fonds f ON e.id_ownerfond = f.id_fond
    `);
    const events = result.rows.map(event => ({
      id: event.id_event,
      name: event.event_name,
      description: event.event_description,
      location: event.event_location,
      data_start: event.event_start_date,
      imageUrl: event.event_image_url,
      ownerFondID: event.id_fond,
      ownerFondLogoUrl: event.ownerfondlogourl,
    }));
    res.json(events);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// Запуск сервера
app.listen(port, () => {
  console.log(`Server is running on http://192.168.0.112:${port}`);
});