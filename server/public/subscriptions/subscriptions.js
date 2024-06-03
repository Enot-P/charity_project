function addSubscription() {
    const user_id = document.getElementById('add-user-id').value;
    const fond_id = document.getElementById('add-fond-id').value;

    fetch('http://192.168.0.112:3000/add-subscription', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ user_id, fond_id })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadSubscriptions(); // Перезагружаем таблицу после добавления подписки
        });
}

function deleteSubscription() {
    const id = document.getElementById('delete-id').value;

    fetch(`http://192.168.0.112:3000/delete-subscription/${id}`, {
        method: 'DELETE'
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadSubscriptions(); // Перезагружаем таблицу после удаления подписки
        });
}

function updateSubscription() {
    const id = document.getElementById('update-id').value;
    const user_id = document.getElementById('update-user-id').value;
    const fond_id = document.getElementById('update-fond-id').value;

    fetch(`http://192.168.0.112:3000/update-subscription/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ user_id, fond_id })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadSubscriptions(); // Перезагружаем таблицу после обновления подписки
        });
}

function loadSubscriptions() {
    fetch('http://192.168.0.112:3000/get-subscriptions')
        .then(response => response.json())
        .then(data => {
            const tableBody = document.getElementById('subscriptions-table').getElementsByTagName('tbody')[0];
            tableBody.innerHTML = ''; // Очищаем таблицу перед добавлением новых данных

            data.forEach(subscription => {
                const row = tableBody.insertRow();
                row.insertCell(0).textContent = subscription.id_subscription;
                row.insertCell(1).textContent = subscription.id_user;
                row.insertCell(2).textContent = subscription.id_fond;
            });
        });
}

// Загружаем подписки при загрузке страницы
window.onload = loadSubscriptions;