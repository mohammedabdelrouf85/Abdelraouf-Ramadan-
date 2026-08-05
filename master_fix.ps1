$jsonText = Get-Content -Path 'd:\MY PC\Coding\Abdelraouf Ramadan\papers.json' -Raw
$papers = $jsonText | ConvertFrom-Json

Write-Host "Initial Count: $($papers.Count)"
$cleanList = @()

foreach ($p in $papers) {
    # Check if title is a URL, DOI, or fragment
    $t = $p.title.Trim()
    
    if ($t -match '^(https?://|doi:|DOI:|www\.)' -or $t -match '^10\.\d{4,9}/' -or $t.Length -lt 20 -or $t -match '^BIO Web of Conferences' -or $t -match '^Handbook of Environmental Chemistry') {
        Write-Host "DELETING Fragment/URL Paper: '$t'"
        continue
    }

    # Clean any embedded URLs or DOIs inside title
    $t = $t -replace 'https?://[^\s\)]+', ''
    $t = $t -replace 'www\.[^\s\)]+', ''
    $t = $t -replace 'DOI:\s*10\.\d{4,9}/[^\s\)]+', ''
    $t = $t -replace 'doi:\s*10\.\d{4,9}/[^\s\)]+', ''
    $t = $t -replace 'doi:.*', ''
    $t = $t -replace 'DOI:.*', ''
    $t = $t.Trim(' .,;:')

    if ($t.Length -lt 15) {
        Write-Host "DELETING Short Title Paper after cleaning: '$t'"
        continue
    }

    $p.title = $t

    # Clean journal & authors
    $p.journal = $p.journal -replace 'https?://[^\s\)]+', '' -replace 'www\.[^\s\)]+', '' -replace 'doi:.*', ''
    $p.journal = $p.journal.Trim(' .,;:')

    $p.authors = $p.authors -replace 'https?://[^\s\)]+', ''
    $p.authors = $p.authors.Trim(' .,;:')
    if ([string]::IsNullOrWhiteSpace($p.authors)) {
        $p.authors = "Prof. Dr. Abdelraouf Ramadan et al."
    }

    # Remove DOI link field
    $p.doi = ""

    $cleanList += $p
}

# Re-index clean IDs
$id = 1
foreach ($c in $cleanList) {
    $c.id = $id
    $id++
}

Write-Host "Final Cleaned Papers Count: $($cleanList.Count)"

$finalJsonText = $cleanList | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText('d:\MY PC\Coding\Abdelraouf Ramadan\papers.json', $finalJsonText, [System.Text.Encoding]::UTF8)

# Now rebuild script.js
$jsCode = @"
/**
 * Agricultural Portfolio - Prof. Dr. Abdelraouf Ramadan
 * Premium UI/UX & Interactive Logic
 * Total Research Papers Integrated: $($cleanList.Count)
 */

document.addEventListener('DOMContentLoaded', () => {
    // --- Research Papers Data Array ---
    const researchPapersData = $finalJsonText;

    // --- State Variables ---
    let currentPage = 1;
    const papersPerPage = 12;
    let currentFilterYear = 'all';
    let searchQuery = '';
    let filteredPapers = [...researchPapersData];

    // --- DOM Elements ---
    const papersGrid = document.getElementById('papersGrid');
    const papersCountBadge = document.getElementById('papersCountBadge');
    const searchInput = document.getElementById('paperSearchInput');
    const filterPills = document.querySelectorAll('.filter-pill');
    const paginationContainer = document.getElementById('paginationContainer');
    const prevPageBtn = document.getElementById('prevPageBtn');
    const nextPageBtn = document.getElementById('nextPageBtn');
    const pageNumbersContainer = document.getElementById('pageNumbersContainer');

    // --- Preloader Logic ---
    const preloader = document.getElementById('preloader');
    const preloaderPercent = document.getElementById('preloaderPercent');
    const preloaderBar = document.getElementById('preloaderBar');

    function dismissPreloader() {
        if (preloader && preloader.style.display !== 'none') {
            preloader.style.opacity = '0';
            preloader.style.visibility = 'hidden';
            setTimeout(() => {
                preloader.style.display = 'none';
                triggerScrollAnimations();
            }, 400);
        }
    }

    let progress = 0;
    const preloaderInterval = setInterval(() => {
        progress += Math.floor(Math.random() * 20) + 15;
        if (progress >= 100) {
            progress = 100;
            clearInterval(preloaderInterval);
            setTimeout(dismissPreloader, 200);
        }
        if (preloaderPercent) preloaderPercent.textContent = progress + '%';
        if (preloaderBar) preloaderBar.style.width = progress + '%';
    }, 40);

    setTimeout(dismissPreloader, 2500);

    // --- Navbar & Mobile Menu ---
    const navbar = document.getElementById('navbar');
    const hamburger = document.getElementById('hamburger');
    const navLinks = document.getElementById('navLinks');

    window.addEventListener('scroll', () => {
        if (window.scrollY > 40) {
            navbar?.classList.add('scrolled');
        } else {
            navbar?.classList.remove('scrolled');
        }
        
        const scrollTop = window.scrollY;
        const docHeight = document.documentElement.scrollHeight - window.innerHeight;
        const scrollPercent = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
        const progressBar = document.getElementById('scrollProgressBar');
        if (progressBar) progressBar.style.width = scrollPercent + '%';
    });

    if (hamburger && navLinks) {
        hamburger.addEventListener('click', () => {
            navLinks.classList.toggle('active');
            hamburger.classList.toggle('active');
        });

        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                navLinks.classList.remove('active');
                hamburger.classList.remove('active');
            });
        });
    }

    // --- Render Research Papers ---
    function renderPapers() {
        if (!papersGrid) return;

        filteredPapers = researchPapersData.filter(paper => {
            const matchesSearch = 
                paper.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                (paper.authors && paper.authors.toLowerCase().includes(searchQuery.toLowerCase())) ||
                (paper.journal && paper.journal.toLowerCase().includes(searchQuery.toLowerCase())) ||
                (paper.year && paper.year.toString().includes(searchQuery));

            let matchesYear = true;
            const y = parseInt(paper.year, 10);
            if (currentFilterYear === '2025') matchesYear = (y === 2025);
            else if (currentFilterYear === '2024') matchesYear = (y === 2024);
            else if (currentFilterYear === '2023') matchesYear = (y === 2023);
            else if (currentFilterYear === '2020-2022') matchesYear = (y >= 2020 && y <= 2022);
            else if (currentFilterYear === '2015-2019') matchesYear = (y >= 2015 && y <= 2019);
            else if (currentFilterYear === 'pre-2015') matchesYear = (y < 2015);

            return matchesSearch && matchesYear;
        });

        if (papersCountBadge) {
            papersCountBadge.textContent = "Showing " + filteredPapers.length + " of " + researchPapersData.length + " Papers";
        }

        const totalPages = Math.ceil(filteredPapers.length / papersPerPage) || 1;
        if (currentPage > totalPages) currentPage = 1;

        const startIndex = (currentPage - 1) * papersPerPage;
        const endIndex = startIndex + papersPerPage;
        const pagePapers = filteredPapers.slice(startIndex, endIndex);

        if (pagePapers.length === 0) {
            papersGrid.innerHTML = 
                '<div class="no-results-card">' +
                    '<i class="fa-solid fa-folder-open text-muted"></i>' +
                    '<h3>No matching research papers found</h3>' +
                    '<p>Try clearing your search query or selecting a different year range.</p>' +
                '</div>';
            if (paginationContainer) paginationContainer.style.display = 'none';
            return;
        }

        if (paginationContainer) paginationContainer.style.display = 'flex';

        papersGrid.innerHTML = pagePapers.map((paper, index) => {
            return '<article class="paper-card reveal-on-scroll">' +
                    '<div class="paper-card-header">' +
                        '<span class="paper-number">#' + paper.id + '</span>' +
                        '<span class="paper-year-tag"><i class="fa-regular fa-calendar"></i> ' + paper.year + '</span>' +
                    '</div>' +
                    '<h3 class="paper-title">' + escapeHtml(paper.title) + '</h3>' +
                    '<p class="paper-authors"><i class="fa-solid fa-users text-accent-green"></i> ' + escapeHtml(paper.authors || 'Prof. Dr. Abdelraouf Ramadan et al.') + '</p>' +
                    (paper.journal ? '<p class="paper-journal"><i class="fa-solid fa-book-bookmark text-accent-blue"></i> ' + escapeHtml(paper.journal) + '</p>' : '') +
                    '<div class="paper-card-footer">' +
                        '<span class="paper-category-pill"><i class="fa-solid fa-vial"></i> NRC Publication</span>' +
                    '</div>' +
                '</article>';
        }).join('');

        renderPaginationControls(totalPages);
        triggerScrollAnimations();
    }

    function renderPaginationControls(totalPages) {
        if (!pageNumbersContainer) return;
        pageNumbersContainer.innerHTML = '';

        for (let i = 1; i <= totalPages; i++) {
            const btn = document.createElement('button');
            btn.className = 'page-btn ' + (i === currentPage ? 'active' : '');
            btn.textContent = i;
            btn.addEventListener('click', () => {
                currentPage = i;
                renderPapers();
                document.getElementById('research-papers')?.scrollIntoView({ behavior: 'smooth' });
            });
            pageNumbersContainer.appendChild(btn);
        }

        if (prevPageBtn) {
            prevPageBtn.disabled = (currentPage === 1);
            prevPageBtn.onclick = () => {
                if (currentPage > 1) {
                    currentPage--;
                    renderPapers();
                    document.getElementById('research-papers')?.scrollIntoView({ behavior: 'smooth' });
                }
            };
        }

        if (nextPageBtn) {
            nextPageBtn.disabled = (currentPage === totalPages);
            nextPageBtn.onclick = () => {
                if (currentPage < totalPages) {
                    currentPage++;
                    renderPapers();
                    document.getElementById('research-papers')?.scrollIntoView({ behavior: 'smooth' });
                }
            };
        }
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
    }

    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            searchQuery = e.target.value;
            currentPage = 1;
            renderPapers();
        });
    }

    filterPills.forEach(pill => {
        pill.addEventListener('click', () => {
            filterPills.forEach(p => p.classList.remove('active'));
            pill.classList.add('active');
            currentFilterYear = pill.getAttribute('data-year') || 'all';
            currentPage = 1;
            renderPapers();
        });
    });

    renderPapers();

    const projectTabs = document.querySelectorAll('.project-tab-btn');
    const projectCards = document.querySelectorAll('.project-item');

    projectTabs.forEach(tab => {
        tab.addEventListener('click', () => {
            projectTabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            const targetCategory = tab.getAttribute('data-category');

            projectCards.forEach(card => {
                if (targetCategory === 'all' || card.getAttribute('data-category') === targetCategory) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    });

    function triggerScrollAnimations() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                }
            });
        }, { threshold: 0.08 });

        document.querySelectorAll('.reveal-on-scroll').forEach(el => observer.observe(el));
    }
    triggerScrollAnimations();

    const galleryItems = document.querySelectorAll('.gallery-item');
    const lightboxModal = document.getElementById('lightboxModal');
    const lightboxImg = document.getElementById('lightboxImg');
    const lightboxCaption = document.getElementById('lightboxCaption');
    const lightboxClose = document.getElementById('lightboxClose');

    galleryItems.forEach(item => {
        item.addEventListener('click', () => {
            const img = item.querySelector('img');
            const caption = item.querySelector('.gallery-caption')?.textContent || '';
            if (lightboxModal && lightboxImg && img) {
                lightboxImg.src = img.src;
                if (lightboxCaption) lightboxCaption.textContent = caption;
                lightboxModal.classList.add('active');
            }
        });
    });

    if (lightboxClose) {
        lightboxClose.addEventListener('click', () => {
            lightboxModal?.classList.remove('active');
        });
    }

    lightboxModal?.addEventListener('click', (e) => {
        if (e.target === lightboxModal) {
            lightboxModal.classList.remove('active');
        }
    });

    const contactForm = document.getElementById('contactForm');
    const formFeedback = document.getElementById('formFeedback');

    if (contactForm) {
        contactForm.addEventListener('submit', (e) => {
            e.preventDefault();
            if (formFeedback) {
                formFeedback.innerHTML = 
                    '<div class="feedback-alert success">' +
                        '<i class="fa-solid fa-circle-check"></i>' +
                        'Thank you for reaching out! Your message has been routed to Prof. Dr. Abdelraouf Ramadan.' +
                    '</div>';
                contactForm.reset();
            }
        });
    }
});
"@

$jsCode | Out-File -FilePath 'd:\MY PC\Coding\Portfolio\script.js' -Encoding utf8
$jsCode | Out-File -FilePath 'd:\MY PC\Coding\Abdelraouf Ramadan\script.js' -Encoding utf8
Write-Host "Master Fix complete! Pristine script.js updated."
