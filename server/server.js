const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const multer = require('multer');
const bcrypt = require('bcrypt');
const path = require('path');
const axios = require('axios');
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
    cb(null, path.join(__dirname, 'uploads'));
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

// Настройка статического сервера для обслуживания загруженных изображений
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Маршрут для создания платежа
app.post('/create-payment', async (req, res) => {
  const { amount, id_user, id_fond } = req.body;

  const url = 'https://api.yookassa.ru/v3/payments';
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Basic Mzk3ODgzOnRlc3RfTExtbnp5Qmt3eEMtM2FHalNNaURYUG1lLU5kTjJqVFVXOExkOGNlemRHMA==',
    'Idempotence-Key': Date.now().toString(),
  };
  const body = {
    amount: {
      value: amount,
      currency: 'RUB',
    },
    confirmation: {
      type: 'redirect',
      return_url: 'https://www.example.com/return_url',
    },
    capture: true,
    description: 'Заказ №1',
  };

  try {
    const response = await axios.post(url, body, { headers });
    if (response.status === 200) {
      const confirmationUrl = response.data.confirmation.confirmation_url;

      // Вставка данных в таблицу transactions
      const query = `
        INSERT INTO transactions (sum, data_transaction, id_fond, id_user)
        VALUES ($1, NOW(), $2, $3)
        RETURNING id_transaction
      `;
      const values = [amount, id_fond, id_user];

      try {
        const result = await pool.query(query, values);
        const transactionId = result.rows[0].id_transaction;
        console.log(`Transaction ID: ${transactionId}`);
      } catch (dbError) {
        console.error('Database error:', dbError);
        return res.status(500).json({ error: 'Database error' });
      }

      res.json({ confirmationUrl });
    } else {
      res.status(response.status).json({ error: response.data });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});
// Маршрут для создания выплаты
app.post('/create-payout', async (req, res) => {
  const { amount } = req.body;

  const url = 'https://api.yookassa.ru/v3/payouts';
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Basic NTA2MTM0OnRlc3RfKmdhLXltZFBlSUV5VEd1dHNPY09BUTc3TEZuM2otQkk1WU1NXy1qM2t1alg4',
    'Idempotence-Key': Date.now().toString(),
  };
  const body = {
    amount: {
      value: amount,
      currency: 'RUB',
    },
    payout_destination_data: {
      type: 'bank_card',
      card: {
        number: '5555555555554477',
      },
    },
    description: 'Выплата по заказу №1',
    metadata: {
      order_id: '1',
    },
  };

  try {
    const response = await axios.post(url, body, { headers });
    if (response.status === 200) {
      res.json({ message: 'Payout created successfully', data: response.data });
    } else {
      res.status(response.status).json({ error: response.data });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// Маршрут для регистрации пользователя с загрузкой изображения
app.post('/register', upload.single('profileImage'), async (req, res) => {
  const { name, surname, email, password } = req.body;
  const profileImage = req.file ? `http://192.168.0.112:3000/uploads/${req.file.filename}` : null;

  try {
    // Хешируем пароль
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log(`Hashed password: ${hashedPassword}`);

    // Сохраняем пользователя в базу данных с хешированным паролем и путем к изображению
    const result = await pool.query(
      'INSERT INTO Users (name, secondname, email, password,  imageurl, id_role) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [name, surname, email, hashedPassword, profileImage, 2]
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

// Маршрут для добавления подписки
app.post('/add-subscription', async (req, res) => {
  const { id_user, id_fond } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO subscriptions (id_user, id_fond) VALUES ($1, $2) RETURNING *',
      [id_user, id_fond]
    );
    res.json({ message: 'Subscription added successfully', subscription: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для получения последних 4 фондов, на которые пользователь сделал пожертвования
app.get('/user/:id/last-donations', async (req, res) => {
  const { id } = req.params;

  try {
    const query = `
      SELECT f.id_fond, f.imageurl, f.name AS fund_name, f.balance, t.name AS tag_name, f.description, f.phone, f.location, f.email
      FROM transactions tr
      JOIN fonds f ON tr.id_fond = f.id_fond
      LEFT JOIN tags t ON f.id_tag = t.id_tag
      WHERE tr.id_user = $1
      ORDER BY tr.data_transaction DESC
      LIMIT 4
    `;
    const values = [id];

    const result = await pool.query(query, values);
    const fonds = result.rows.map(fond => ({
      id: fond.id_fond,
      imageUrl: fond.imageurl,
      fundName: fond.fund_name,
      amount: fond.balance.toString(),
      tag: fond.tag_name,
      description: fond.description,
      contactInfo: `Телефон: ${fond.phone} \nАдрес: ${fond.location} \nE-mail: ${fond.email}`,
    }));
    res.json(fonds);
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

    res.json({
      id_user: user.id_user,
      name: user.name,
      email: user.email,
      secondname: user.secondname,
      card_number: user.card_number,
      imageurl: formattedImageUrl,
      id_role: user.id_role,
      roleName: roleName
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


app.get('/fonds', async (req, res) => {
  try {
    const tag = req.query.tag; // Получаем тег из параметров запроса
    let query = `
      SELECT f.id_fond, f.imageurl, f.name AS fund_name, f.balance, t.name AS tag_name, f.description, f.phone, f.location, f.email
      FROM Fonds f
      LEFT JOIN Tags t ON f.id_tag = t.id_tag
    `;

    if (tag) {
      query += ` WHERE t.name = $1`;
    }

    const result = await pool.query(query, tag ? [tag] : []);
    const fonds = result.rows.map(fond => ({
      id: fond.id_fond,
      imageUrl: fond.imageurl,
      fundName: fond.fund_name,
      amount: fond.balance.toString(),
      tag: fond.tag_name,
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

app.use(express.static(path.join(__dirname, 'public')));

// Маршрут для получения всех фондов
app.get('/get-fonds', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM Fonds');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для добавления фонда
app.post('/add-fond', async (req, res) => {
  const { name, balance, id_tag, description, phone, location, email, imageurl, id_owneruser, requisites } = req.body;

  try {
    const result = await pool.query(
        'INSERT INTO Fonds (name, balance, id_tag, description, phone, location, email, imageurl, id_owneruser, requisites) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *',
        [name, balance, id_tag, description, phone, location, email, imageurl, id_owneruser, requisites]
    );
    res.json({ message: 'Fond added successfully', fond: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для удаления фонда
app.delete('/delete-fond/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM Fonds WHERE id_fond = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Fond not found' });
    }
    res.json({ message: 'Fond deleted successfully', fond: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для обновления фонда
app.put('/update-fond/:id', async (req, res) => {
  const { id } = req.params;
  const { name, balance, id_tag, description, phone, location, email, imageurl, id_owneruser, requisites } = req.body;

  try {
    const result = await pool.query(
        'UPDATE Fonds SET name = $1, balance = $2, id_tag = $3, description = $4, phone = $5, location = $6, email = $7, imageurl = $8, id_owneruser = $9, requisites = $10 WHERE id_fond = $11 RETURNING *',
        [name, balance, id_tag, description, phone, location, email, imageurl, id_owneruser, requisites, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Fond not found' });
    }
    res.json({ message: 'Fond updated successfully', fond: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});
// Маршрут для получения всех ивентов
app.get('/get-events', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM Events');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.post('/create-event', upload.single('imageurl'), async (req, res) => {
  const { name, description, location, date, user_id } = req.body;
  const imageUrl = req.file ? `http://192.168.0.112:3000/uploads/${req.file.filename}` : null;

  console.log('Received data:', { name, description, location, date, user_id, imageUrl });


  try {
    // Получаем id_fond по id_user
    const fondResult = await pool.query('SELECT id_fond FROM fonds WHERE id_owneruser = $1', [user_id]);
    if (fondResult.rows.length === 0) {
      console.log('Фонд не найден для данного пользователя');
      return res.status(404).json({ message: 'Фонд не найден для данного пользователя' });
    }
    const fond_id = fondResult.rows[0].id_fond;

    // Вставляем данные ивента
    const result = await pool.query(
      'INSERT INTO Events (name, description, location, data_start, imageurl, id_ownerfond) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [name, description, location, date, imageUrl, fond_id]
    );
    res.json({ message: 'Ивент успешно добавлен', event: result.rows[0] });
  } catch (err) {
    console.error('Ошибка при добавлении ивента:', err);
    res.status(500).json({ error: 'Внутренняя ошибка сервера' });
  }
});


// Маршрут для добавления ивента
app.post('/add-event', async (req, res) => {
  const { name, description, location, date, imageurl, fond_id } = req.body;

  try {
    const result = await pool.query(
        'INSERT INTO Events (name, description, location, data_start, imageurl, id_ownerfond) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
        [name, description, location, date, imageurl, fond_id]
    );
    res.json({ message: 'Event added successfully', event: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для удаления ивента
app.delete('/delete-event/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM Events WHERE id_event = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Event not found' });
    }
    res.json({ message: 'Event deleted successfully', event: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для изменения ивента
app.put('/update-event/:id', async (req, res) => {
  const { id } = req.params;
  const { name, description, location, date, imageurl, fond_id } = req.body;

  try {
    const result = await pool.query(
        'UPDATE Events SET name = $1, description = $2, location = $3, data_start = $4, imageurl = $5, id_ownerfond = $6 WHERE id_event = $7 RETURNING *',
        [name, description, location, date, imageurl, fond_id, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Event not found' });
    }
    res.json({ message: 'Event updated successfully', event: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для получения всех ролей
app.get('/get-roles', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM Roles');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для добавления роли
app.post('/add-role', async (req, res) => {
  const { name } = req.body;

  try {
    const result = await pool.query(
        'INSERT INTO Roles (name) VALUES ($1) RETURNING *',
        [name]
    );
    res.json({ message: 'Role added successfully', role: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для удаления роли
app.delete('/delete-role/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM Roles WHERE id_role = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Role not found' });
    }
    res.json({ message: 'Role deleted successfully', role: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для изменения роли
app.put('/update-role/:id', async (req, res) => {
  const { id } = req.params;
  const { name } = req.body;

  try {
    const result = await pool.query(
        'UPDATE Roles SET name = $1 WHERE id_role = $2 RETURNING *',
        [name, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Role not found' });
    }
    res.json({ message: 'Role updated successfully', role: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для получения всех подписок
app.get('/get-subscriptions', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM Subscriptions');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для добавления подписки
app.post('/add-subscription', async (req, res) => {
  const { user_id: id_user, fond_id: id_fond } = req.body;

  try {
    const result = await pool.query(
        'INSERT INTO Subscriptions (user_id, fond_id) VALUES ($1, $2) RETURNING *',
        [id_user, id_fond]
    );
    res.json({ message: 'Subscription added successfully', subscription: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для удаления подписки
app.delete('/delete-subscription/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM Subscriptions WHERE id_subscription = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Subscription not found' });
    }
    res.json({ message: 'Subscription deleted successfully', subscription: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для изменения подписки
app.put('/update-subscription/:id', async (req, res) => {
  const { id } = req.params;
  const { user_id: id_user, fond_id: id_fond } = req.body;

  try {
    const result = await pool.query(
        'UPDATE Subscriptions SET user_id = $1, fond_id = $2 WHERE id_subscription = $3 RETURNING *',
        [id_user, id_fond, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Subscription not found' });
    }
    res.json({ message: 'Subscription updated successfully', subscription: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для получения всех тегов
app.get('/get-tags', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM Tags');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для добавления тега
app.post('/add-tag', async (req, res) => {
  const { name } = req.body;

  try {
    const result = await pool.query(
        'INSERT INTO Tags (name) VALUES ($1) RETURNING *',
        [name]
    );
    res.json({ message: 'Tag added successfully', tag: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для удаления тега
app.delete('/delete-tag/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM Tags WHERE id_tag = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Tag not found' });
    }
    res.json({ message: 'Tag deleted successfully', tag: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для изменения тега
app.put('/update-tag/:id', async (req, res) => {
  const { id } = req.params;
  const { name } = req.body;

  try {
    const result = await pool.query(
        'UPDATE Tags SET name = $1 WHERE id_tag = $2 RETURNING *',
        [name, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Tag not found' });
    }
    res.json({ message: 'Tag updated successfully', tag: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для получения всех транзакций
app.get('/get-transactions', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM Transactions');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для добавления транзакции
app.post('/add-transaction', async (req, res) => {
  const { sum, date, fond_id, user_id } = req.body;

  try {
    const result = await pool.query(
        'INSERT INTO Transactions (sum, data_transaction, id_fond, id_user) VALUES ($1, $2, $3, $4) RETURNING *',
        [sum, date, fond_id, user_id]
    );
    res.json({ message: 'Transaction added successfully', transaction: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для удаления транзакции
app.delete('/delete-transaction/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM Transactions WHERE id_transaction = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Transaction not found' });
    }
    res.json({ message: 'Transaction deleted successfully', transaction: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для изменения транзакции
app.put('/update-transaction/:id', async (req, res) => {
  const { id } = req.params;
  const { sum, date, fond_id, user_id } = req.body;

  try {
    const result = await pool.query(
        'UPDATE Transactions SET sum = $1, data_transaction = $2, id_fond = $3, id_user = $4 WHERE id_transaction = $5 RETURNING *',
        [sum, date, fond_id, user_id, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Transaction not found' });
    }
    res.json({ message: 'Transaction updated successfully', transaction: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для получения всех пользователей
app.get('/get-users', async (req, res) => {
  try {
    const result = await pool.query('SELECT id_user, name, secondname, email, imageurl, id_role FROM Users');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Маршрут для добавления пользователя
app.post('/add-user', async (req, res) => {
  const { name, secondname, email, imageurl, id_role, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
        'INSERT INTO Users (name, secondname, email, imageurl, id_role, password) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
        [name, secondname, email, imageurl, id_role, hashedPassword]
    );
    res.json({ message: 'User added successfully', user: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

app.delete('/delete-user/:id', async (req, res) => {
  const { id } = req.params;

  try {
    // Начинаем транзакцию
    await pool.query('BEGIN');

    // Удаляем зависимости в таблице subscriptions
    await pool.query('DELETE FROM subscriptions WHERE id_user = $1', [id]);

    // Удаляем зависимости в таблице transactions
    await pool.query('DELETE FROM transactions WHERE id_user = $1', [id]);

    // Получаем все фонды, связанные с пользователем
    const fonds = await pool.query('SELECT id_fond FROM fonds WHERE id_owneruser = $1', [id]);

    // Удаляем зависимости в таблице events для каждого фонда
    for (let fond of fonds.rows) {
      await pool.query('DELETE FROM events WHERE id_ownerfond = $1', [fond.id_fond]);
    }

    // Удаляем фонды, связанные с пользователем
    await pool.query('DELETE FROM fonds WHERE id_owneruser = $1', [id]);

    // Удаляем пользователя
    const result = await pool.query('DELETE FROM Users WHERE id_user = $1 RETURNING *', [id]);

    // Проверяем, был ли пользователь найден и удален
    if (result.rows.length === 0) {
      await pool.query('ROLLBACK');
      return res.status(404).json({ message: 'User not found' });
    }

    // Завершаем транзакцию
    await pool.query('COMMIT');
    res.json({ message: 'User deleted successfully', user: result.rows[0] });
  } catch (err) {
    // Откатываем транзакцию в случае ошибки
    await pool.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// Маршрут для изменения пользователя
app.put('/update-user/:id', async (req, res) => {
  const { id } = req.params;
  const { name, secondname, email, imageurl, id_role, password } = req.body;

  try {
    let hashedPassword = null;
    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    const result = await pool.query(
        'UPDATE Users SET name = $1, secondname = $2, email = $3, imageurl = $4, id_role = $5, password = COALESCE($6, password) WHERE id_user = $7 RETURNING *',
        [name, secondname, email, imageurl, id_role, hashedPassword, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({ message: 'User updated successfully', user: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Запуск сервера
app.listen(port, () => {
  console.log(`Server is running on http://192.168.0.112:${port}`);
});