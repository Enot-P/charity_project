function addRole() {
    const name = document.getElementById('add-name').value;

    fetch('http://192.168.0.112:3000/add-role', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadRoles(); // Перезагружаем таблицу после добавления роли
        });
}

function deleteRole() {
    const id = document.getElementById('delete-id').value;

    fetch(`http://192.168.0.112:3000/delete-role/${id}`, {
        method: 'DELETE'
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadRoles(); // Перезагружаем таблицу после удаления роли
        });
}

function updateRole() {
    const id = document.getElementById('update-id').value;
    const name = document.getElementById('update-name').value;

    fetch(`http://192.168.0.112:3000/update-role/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadRoles(); // Перезагружаем таблицу после обновления роли
        });
}

function loadRoles() {
    fetch('http://192.168.0.112:3000/get-roles')
        .then(response => response.json())
        .then(data => {
            const tableBody = document.getElementById('roles-table').getElementsByTagName('tbody')[0];
            tableBody.innerHTML = ''; // Очищаем таблицу перед добавлением новых данных

            data.forEach(role => {
                const row = tableBody.insertRow();
                row.insertCell(0).textContent = role.id_role;
                row.insertCell(1).textContent = role.name;
            });
        });
}

// Загружаем роли при загрузке страницы
window.onload = loadRoles;