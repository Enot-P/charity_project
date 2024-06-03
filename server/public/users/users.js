function addUser() {
    const name = document.getElementById('add-name').value;
    const secondname = document.getElementById('add-secondname').value;
    const email = document.getElementById('add-email').value;
    const imageurl = document.getElementById('add-imageurl').value;
    const id_role = document.getElementById('add-role-id').value;
    const password = document.getElementById('add-password').value;

    fetch('http://192.168.0.112:3000/add-user', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, secondname, email, imageurl, id_role, password })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadUsers(); // Перезагружаем таблицу после добавления пользователя
        });
}

function deleteUser() {
    const id = document.getElementById('delete-id').value;

    fetch(`http://192.168.0.112:3000/delete-user/${id}`, {
        method: 'DELETE'
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadUsers(); // Перезагружаем таблицу после удаления пользователя
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Failed to delete user');
        });
}

function updateUser() {
    const id = document.getElementById('update-id').value;
    const name = document.getElementById('update-name').value;
    const secondname = document.getElementById('update-secondname').value;
    const email = document.getElementById('update-email').value;
    const imageurl = document.getElementById('update-imageurl').value;
    const id_role = document.getElementById('update-role-id').value;
    const password = document.getElementById('update-password').value;

    fetch(`http://192.168.0.112:3000/update-user/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, secondname, email, imageurl, id_role, password })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadUsers(); // Перезагружаем таблицу после обновления пользователя
        });
}

function loadUsers() {
    fetch('http://192.168.0.112:3000/get-users')
        .then(response => response.json())
        .then(data => {
            const tableBody = document.getElementById('users-table').getElementsByTagName('tbody')[0];
            tableBody.innerHTML = ''; // Очищаем таблицу перед добавлением новых данных

            data.forEach(user => {
                const row = tableBody.insertRow();
                row.insertCell(0).textContent = user.id_user;
                row.insertCell(1).textContent = user.name;
                row.insertCell(2).textContent = user.secondname;
                row.insertCell(3).textContent = user.email;
                row.insertCell(4).textContent = user.imageurl;
                row.insertCell(5).textContent = user.id_role;
            });
        });
}

// Загружаем пользователей при загрузке страницы
window.onload = loadUsers;