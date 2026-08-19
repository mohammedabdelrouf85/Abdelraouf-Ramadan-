const REPO_OWNER = 'mohammedabdelrouf85';
const REPO_NAME = 'Abdelraouf-Ramadan-';
const FILE_PATH = 'papers.json';

let currentSha = '';
let papersData = [];

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

    document.getElementById('btn-add-paper').addEventListener('click', async () => {
        const title = document.getElementById('p-title').value.trim();
        const authors = document.getElementById('p-authors').value.trim();
        const year = document.getElementById('p-year').value.trim();
        const doi = document.getElementById('p-doi').value.trim();
        const journal = document.getElementById('p-journal').value.trim();

        if (!title || !year) {
            showMsg('Title and Year are required!', 'error');
            return;
        }

        const newId = papersData.length > 0 ? Math.max(...papersData.map(p => p.id)) + 1 : 1;
        
        const newPaper = {
            id: newId,
            raw: `${authors} (${year}). ${title}. ${journal}`,
            authors: authors,
            year: year,
            title: title,
            journal: journal,
            doi: doi
        };

        // Add to array at the beginning
        papersData.unshift(newPaper);
        
        // Re-assign IDs just to be safe or leave as is
        
        await saveToGitHub(localStorage.getItem('gh_token'));
    });
});

async function showDashboard(token) {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('dashboard').style.display = 'block';
    
    try {
        const response = await fetch(`https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents/${FILE_PATH}`, {
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
        
        // Decode base64 content
        const decodedContent = decodeURIComponent(escape(window.atob(data.content)));
        papersData = JSON.parse(decodedContent);
        
        renderPapers();
    } catch (err) {
        console.error(err);
        document.getElementById('papers-list').innerHTML = `<div style="color:red">Failed to load papers. Check permissions.</div>`;
    }
}

function renderPapers() {
    document.getElementById('papers-count').innerText = papersData.length;
    const list = document.getElementById('papers-list');
    list.innerHTML = '';
    
    papersData.slice(0, 50).forEach(paper => { // Show last 50
        list.innerHTML += `
            <div class="paper-item">
                <div>
                    <strong>#${paper.id} - ${paper.title}</strong><br>
                    <small style="color:var(--color-text-subtle)">${paper.year} | ${paper.journal || 'No Journal'}</small>
                </div>
            </div>
        `;
    });
}

async function saveToGitHub(token) {
    const btn = document.getElementById('btn-add-paper');
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving to Database...';
    btn.disabled = true;

    try {
        const updatedContent = JSON.stringify(papersData, null, 4);
        
        // base64 encode using btoa but handle unicode
        const encodedContent = window.btoa(unescape(encodeURIComponent(updatedContent)));

        const body = {
            message: `admin: Added new research paper via Admin Panel`,
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
            currentSha = data.content.sha; // Update SHA for future saves
            showMsg('Paper added and Website updated successfully!', 'success');
            renderPapers();
            
            // clear form
            document.getElementById('p-title').value = '';
            document.getElementById('p-journal').value = '';
            document.getElementById('p-doi').value = '';
        } else {
            const err = await response.json();
            showMsg(`Error saving: ${err.message}`, 'error');
        }
    } catch (err) {
        showMsg('Network error while saving.', 'error');
    }

    btn.innerHTML = '<i class="fa-solid fa-cloud-arrow-up"></i> Add & Save to Website';
    btn.disabled = false;
}

function showMsg(text, type) {
    const msg = document.getElementById('status-msg');
    msg.innerText = text;
    msg.className = type;
    msg.style.display = 'block';
    setTimeout(() => { msg.style.display = 'none'; }, 5000);
}
