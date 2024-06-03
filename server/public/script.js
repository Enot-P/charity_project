function addFond() {
    const name = document.getElementById('add-name').value;
    const balance = document.getElementById('add-balance').value;
    const id_tag = document.getElementById('add-tag').value;
    const description = document.getElementById('add-description').value;
    const phone = document.getElementById('add-phone').value;
    const location = document.getElementById('add-location').value;
    const email = document.getElementById('add-email').value;
    const imageurl = document.getElementById('add-imageurl').value;

    fetch('/add-fond', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, balance, id_tag, description, phone, location, email, imageurl })
    })
        .then(response => response.json())
        .then(data => alert(data.message));
}

function deleteFond() {
    const id = document.getElementById('delete-id').value;

    fetch(`/delete-fond/${id}`, {
        method: 'DELETE'
    })
        .then(response => response.json())
        .then(data => alert(data.message));
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

    fetch(`/update-fond/${id}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name, balance, id_tag, description, phone, location, email, imageurl })
    })
        .then(response => response.json())
        .then(data => alert(data.message));
}