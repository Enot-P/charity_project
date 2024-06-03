function addTransaction() {
    const sum = document.getElementById('add-sum').value;
    const date = document.getElementById('add-date').value;
    const fond_id = document.getElementById('add-fond-id').value;
    const user_id = document.getElementById('add-user-id').value;

    fetch('http://192.168.0.112:3000/add-transaction', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ sum, date, fond_id, user_id })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadTransactions(); // Перезагружаем таблицу после добавления транзакции
        });
}

function deleteTransaction() {
    const id = document.getElementById('delete-id').value;

    fetch(`http://192.168.0.112:3000/delete-transaction/${id}`, {
        method: 'DELETE'
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadTransactions(); // Перезагружаем таблицу после удаления транзакции
        });
}

function updateTransaction() {
    const id = document.getElementById('update-id').value;
    const sum = document.getElementById('update-sum').value;
    const date = document.getElementById('update-date').value;
    const fond_id = document.getElementById('update-fond-id').value;
    const user_id = document.getElementById('update-user-id').value;

    fetch(`http://192.168.0.112:3000/update-transaction/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ sum, date, fond_id, user_id })
    })
        .then(response => response.json())
        .then(data => {
            alert(data.message);
            loadTransactions(); // Перезагружаем таблицу после обновления транзакции
        });
}

function loadTransactions() {
    fetch('http://192.168.0.112:3000/get-transactions')
        .then(response => response.json())
        .then(data => {
            const tableBody = document.getElementById('transactions-table').getElementsByTagName('tbody')[0];
            tableBody.innerHTML = ''; // Очищаем таблицу перед добавлением новых данных

            data.forEach(transaction => {
                const row = tableBody.insertRow();
                row.insertCell(0).textContent = transaction.id_transaction;
                row.insertCell(1).textContent = transaction.sum;
                row.insertCell(2).textContent = transaction.data_transaction;
                row.insertCell(3).textContent = transaction.id_fond;
                row.insertCell(4).textContent = transaction.id_user;
            });
        });
}

// Загружаем транзакции при загрузке страницы
window.onload = loadTransactions;