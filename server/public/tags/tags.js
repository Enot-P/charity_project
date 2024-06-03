function addTag() {
    const name = document.getElementById('add-name').value;

    fetch('http://192.168.0.112:3000/add-tag', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadTags(); // Перезагружаем таблицу после добавления тега
        });
}

function deleteTag() {
    const id = document.getElementById('delete-id').value;

    fetch(`http://192.168.0.112:3000/delete-tag/${id}`, {
        method: 'DELETE'
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadTags(); // Перезагружаем таблицу после удаления тега
        });
}

function updateTag() {
    const id = document.getElementById('update-id').value;
    const name = document.getElementById('update-name').value;

    fetch(`http://192.168.0.112:3000/update-tag/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadTags(); // Перезагружаем таблицу после обновления тега
        });
}

function loadTags() {
    fetch('http://192.168.0.112:3000/get-tags')
        .then(response => response.json())
        .then(data => {
            const tableBody = document.getElementById('tags-table').getElementsByTagName('tbody')[0];
            tableBody.innerHTML = ''; // Очищаем таблицу перед добавлением новых данных

            data.forEach(tag => {
                const row = tableBody.insertRow();
                row.insertCell(0).textContent = tag.id_tag;
                row.insertCell(1).textContent = tag.name;
            });
        });
}

// Загружаем теги при загрузке страницы
window.onload = loadTags;