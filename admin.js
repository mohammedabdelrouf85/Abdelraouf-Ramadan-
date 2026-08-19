const REPO_OWNER = 'mohammedabdelrouf85';
const REPO_NAME = 'Abdelraouf-Ramadan-';
const FILE_PATH = 'index.html';

let currentSha = '';
let indexHtml = '';

document.addEventListener('DOMContentLoaded', () => {
    const token = localStorage.getItem('gh_token');
    if (token) {
        showDashboard(token);
    }

    document.getElementById('btn-login').addEventListener('click', () => {
        const t = document.getElementById('gh-token').value.trim();
        if (t) {
            localStorage.setItem('gh_token', t);
            showDashboard(t);
        }
    });

    document.getElementById('btn-logout').addEventListener('click', () => {
        localStorage.removeItem('gh_token');
        document.getElementById('login-screen').style.display = 'block';
        document.getElementById('dashboard').style.display = 'none';
    });

    document.getElementById('btn-save').addEventListener('click', async () => {
        await saveToGitHub(localStorage.getItem('gh_token'));
    });
});

async function showDashboard(token) {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('dashboard').style.display = 'block';
    
    try {
        const response = await fetch(`https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents/${FILE_PATH}?timestamp=${new Date().getTime()}`, {
            headers: { 'Authorization': `token ${token}` }
        });
        
        if (response.status === 401) {
            localStorage.removeItem('gh_token');
            alert('Invalid Token!');
            window.location.reload();
            return;
        }

        const data = await response.json();
        currentSha = data.sha;
        
        // Decode base64 HTML
        indexHtml = decodeURIComponent(escape(window.atob(data.content)));
        
        // Extract current values using simple regex mapping
        populateField('s-hindex', 'scopus-hindex');
        populateField('s-docs', 'scopus-docs');
        populateField('s-citations', 'scopus-citations');
        
        populateField('r-hindex', 'rg-hindex');
        populateField('r-docs', 'rg-docs');
        populateField('r-citations', 'rg-citations');
        
        populateField('g-hindex', 'gs-hindex');
        populateField('g-docs', 'gs-docs');
        populateField('g-citations', 'gs-citations');
        
        populateFieldSpan('t-citations', 'hero-total-citations');
        
    } catch (err) {
        console.error(err);
        showMsg('Failed to load metrics from GitHub.', 'error');
    }
}

function populateField(inputId, domId) {
    const regex = new RegExp(`id="${domId}"[^>]*>([^<]*)</div>`);
    const match = indexHtml.match(regex);
    if (match) {
        document.getElementById(inputId).value = match[1].trim();
    }
}

function populateFieldSpan(inputId, domId) {
    const regex = new RegExp(`id="${domId}"[^>]*>([^<]*)</span>`);
    const match = indexHtml.match(regex);
    if (match) {
        document.getElementById(inputId).value = match[1].trim();
    }
}

function replaceInHtml(domId, val, tag="div") {
    const regex = new RegExp(`(id="${domId}"[^>]*>)[^<]*(</${tag}>)`);
    indexHtml = indexHtml.replace(regex, `$1${val}$2`);
}

async function saveToGitHub(token) {
    const btn = document.getElementById('btn-save');
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving to Website...';
    btn.disabled = true;

    try {
        // Update indexHtml with new values
        replaceInHtml('scopus-hindex', document.getElementById('s-hindex').value);
        replaceInHtml('scopus-docs', document.getElementById('s-docs').value);
        replaceInHtml('scopus-citations', document.getElementById('s-citations').value);
        replaceInHtml('hero-scopus-hindex', document.getElementById('s-hindex').value, "span");
        
        replaceInHtml('rg-hindex', document.getElementById('r-hindex').value);
        replaceInHtml('rg-docs', document.getElementById('r-docs').value);
        replaceInHtml('rg-citations', document.getElementById('r-citations').value);
        replaceInHtml('hero-rg-hindex', document.getElementById('r-hindex').value, "span");
        
        replaceInHtml('gs-hindex', document.getElementById('g-hindex').value);
        replaceInHtml('gs-docs', document.getElementById('g-docs').value);
        replaceInHtml('gs-citations', document.getElementById('g-citations').value);
        
        replaceInHtml('hero-total-citations', document.getElementById('t-citations').value, "span");

        // base64 encode using btoa
        const encodedContent = window.btoa(unescape(encodeURIComponent(indexHtml)));

        const body = {
            message: `admin: Updated metrics via Admin Panel`,
            content: encodedContent,
            sha: currentSha,
            branch: 'main'
        };

        const response = await fetch(`https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents/${FILE_PATH}`, {
            method: 'PUT',
            headers: {
                'Authorization': `token ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(body)
        });

        if (response.ok) {
            const data = await response.json();
            currentSha = data.content.sha; // Update SHA
            showMsg('Metrics updated successfully on live website!', 'success');
        } else {
            const err = await response.json();
            showMsg(`Error saving: ${err.message}`, 'error');
        }
    } catch (err) {
        showMsg('Network error while saving.', 'error');
    }

    btn.innerHTML = '<i class="fa-solid fa-cloud-arrow-up"></i> Save Metrics to Website';
    btn.disabled = false;
}

function showMsg(text, type) {
    const msg = document.getElementById('status-msg');
    msg.innerText = text;
    msg.className = type;
    msg.style.display = 'block';
    setTimeout(() => { msg.style.display = 'none'; }, 5000);
}
