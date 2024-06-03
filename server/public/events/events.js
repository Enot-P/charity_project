function addEvent() {
    const name = document.getElementById('add-name').value;
    const description = document.getElementById('add-description').value;
    const location = document.getElementById('add-location').value;
    const date = document.getElementById('add-date').value;
    const imageurl = document.getElementById('add-imageurl').value;
    const fond_id = document.getElementById('add-fond-id').value;

    fetch('/add-event', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, description, location, date, imageurl, fond_id })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadEvents(); // Перезагружаем таблицу после добавления ивента
        });
}

function deleteEvent() {
    const id = document.getElementById('delete-id').value;

    fetch(`/delete-event/${id}`, {
        method: 'DELETE'
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadEvents(); // Перезагружаем таблицу после удаления ивента
        });
}

function updateEvent() {
    const id = document.getElementById('update-id').value;
    const name = document.getElementById('update-name').value;
    const description = document.getElementById('update-description').value;
    const location = document.getElementById('update-location').value;
    const date = document.getElementById('update-date').value;
    const imageurl = document.getElementById('update-imageurl').value;
    const fond_id = document.getElementById('update-fond-id').value;

    fetch(`/update-event/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, description, location, date, imageurl, fond_id })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadEvents(); // Перезагружаем таблицу после обновления ивента
        });
}

function loadEvents() {
    fetch('/get-events')
        .then(response => response.json())
        .then(data => {
            const tableBody = document.getElementById('events-table').getElementsByTagName('tbody')[0];
            tableBody.innerHTML = ''; // Очищаем таблицу перед добавлением новых данных

            data.forEach(event => {
                const row = tableBody.insertRow();
                row.insertCell(0).textContent = event.id_event;
                row.insertCell(1).textContent = event.name;
                row.insertCell(2).textContent = event.description;
                row.insertCell(3).textContent = event.location;
                row.insertCell(4).textContent = event.data_start;
                row.insertCell(5).textContent = event.imageurl;
                row.insertCell(6).textContent = event.id_ownerfond;
            });
        });
}

// Загружаем ивенты при загрузке страницы
window.onload = loadEvents;