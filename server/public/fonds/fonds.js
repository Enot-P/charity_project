function addFond() {
    const name = document.getElementById('add-name').value;
    const balance = document.getElementById('add-balance').value;
    const id_tag = document.getElementById('add-tag').value;
    const description = document.getElementById('add-description').value;
    const phone = document.getElementById('add-phone').value;
    const location = document.getElementById('add-location').value;
    const email = document.getElementById('add-email').value;
    const imageurl = document.getElementById('add-imageurl').value;
    const id_owneruser = document.getElementById('add-owneruser').value;
    const requisites = document.getElementById('add-requisites').value;

    fetch('http://192.168.0.112:3000/add-fond', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, balance, id_tag, description, phone, location, email, imageurl, id_owneruser, requisites })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadFonds(); // Перезагружаем таблицу после добавления фонда
        });
}

function deleteFond() {
    const id = document.getElementById('delete-id').value;

    fetch(`http://192.168.0.112:3000/delete-fond/${id}`, {
        method: 'DELETE'
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadFonds(); // Перезагружаем таблицу после удаления фонда
        });
}

function updateFond() {
    const id = document.getElementById('update-id').value;
    const name = document.getElementById('update-name').value;
    const balance = document.getElementById('update-balance').value;
    const id_tag = document.getElementById('update-tag').value;
    const description = document.getElementById('update-description').value;
    const phone = document.getElementById('update-phone').value;
    const location = document.getElementById('update-location').value;
    const email = document.getElementById('update-email').value;
    const imageurl = document.getElementById('update-imageurl').value;
    const id_owneruser = document.getElementById('update-owneruser').value;
    const requisites = document.getElementById('update-requisites').value;

    fetch(`http://192.168.0.112:3000/update-fond/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, balance, id_tag, description, phone, location, email, imageurl, id_owneruser, requisites })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadFonds(); // Перезагружаем таблицу после обновления фонда
        });
}

function loadFonds() {
    fetch('http://192.168.0.112:3000/get-fonds')
        .then(response => response.json())
        .then(data => {
            const tableBody = document.getElementById('fonds-table').getElementsByTagName('tbody')[0];
            tableBody.innerHTML = ''; // Очищаем таблицу перед добавлением новых данных

            data.forEach(fond => {
                const row = tableBody.insertRow();
                row.insertCell(0).textContent = fond.id_fond;
                row.insertCell(1).textContent = fond.name;
                row.insertCell(2).textContent = fond.requisites;
                row.insertCell(3).textContent = fond.imageurl;
                row.insertCell(4).textContent = fond.description;
                row.insertCell(5).textContent = fond.email;
                row.insertCell(6).textContent = fond.phone;
                row.insertCell(7).textContent = fond.location;
                row.insertCell(8).textContent = fond.balance;
                row.insertCell(9).textContent = fond.id_owneruser;
                row.insertCell(10).textContent = fond.id_tag;
            });
        });
}

// Загружаем фонды при загрузке страницы
window.onload = loadFonds;